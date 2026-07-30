import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_projects/model/customer_model.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/customer_repository.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:intl/intl.dart';

enum PdfExportSection { production, orders, customers, everything }

extension PdfExportSectionX on PdfExportSection {
  String get title {
    switch (this) {
      case PdfExportSection.production:
        return 'Daily Production';
      case PdfExportSection.orders:
        return 'Order List';
      case PdfExportSection.customers:
        return 'Customer List';
      case PdfExportSection.everything:
        return 'Complete Business Report';
    }
  }

  String get shortLabel {
    switch (this) {
      case PdfExportSection.production:
        return 'production';
      case PdfExportSection.orders:
        return 'orders';
      case PdfExportSection.customers:
        return 'customers';
      case PdfExportSection.everything:
        return 'everything';
    }
  }
}

class PdfExportResult {
  const PdfExportResult({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

class PdfExportService {
  static final PdfColor _primary = PdfColor.fromHex('#163F7A');
  static final PdfColor _primaryDark = PdfColor.fromHex('#0B2446');
  static final PdfColor _accent = PdfColor.fromHex('#D9A441');
  static final PdfColor _surface = PdfColor.fromHex('#F4F7FB');
  static final PdfColor _muted = PdfColor.fromHex('#5F7188');
  static final PdfColor _border = PdfColor.fromHex('#D7E3F2');
  Future<PdfExportResult> createReport({
    required PdfExportSection section,
    required DateTime start,
    required DateTime end,
    required ProductionRepository productionRepository,
    required OrderRepository orderRepository,
    required CustomerRepository customerRepository,
  }) async {
    final normalizedStart = _startOfDay(start);
    final normalizedEnd = _endOfDay(end);

    final productionFuture =
        section == PdfExportSection.production ||
            section == PdfExportSection.everything
        ? productionRepository.getProductionLogsInRange(
            start: normalizedStart,
            end: normalizedEnd,
          )
        : Future.value(<ProductionModel>[]);

    final orderFuture =
        section == PdfExportSection.orders ||
            section == PdfExportSection.customers ||
            section == PdfExportSection.everything
        ? orderRepository.getOrdersInRange(
            start: normalizedStart,
            end: normalizedEnd,
          )
        : Future.value(<OrderModel>[]);

    final customerFuture =
        section == PdfExportSection.customers ||
            section == PdfExportSection.everything
        ? customerRepository.getCustomersOnce()
        : Future.value(<CustomerModel>[]);

    final productions = await productionFuture;
    final orders = await orderFuture;
    final manualCustomers = await customerFuture;
    final customers = _buildCustomerExportProfiles(
      manualCustomers: manualCustomers,
      filteredOrders: orders,
      start: normalizedStart,
      end: normalizedEnd,
    );

    final bytes = await _buildPdf(
      section: section,
      start: normalizedStart,
      end: normalizedEnd,
      productions: productions,
      orders: orders,
      customers: customers,
    );

    return PdfExportResult(
      bytes: bytes,
      fileName:
          '${section.shortLabel}_${DateFormat('yyyyMMdd').format(normalizedStart)}_${DateFormat('yyyyMMdd').format(normalizedEnd)}.pdf',
    );
  }

  List<CustomerModel> _buildCustomerExportProfiles({
    required List<CustomerModel> manualCustomers,
    required List<OrderModel> filteredOrders,
    required DateTime start,
    required DateTime end,
  }) {
    if (manualCustomers.isEmpty && filteredOrders.isEmpty) {
      return const [];
    }

    final customerSeed = manualCustomers.map((customer) {
      return customer.copyWith(
        totalSales: 0,
        totalPaid: 0,
        totalDue: 0,
        orderCount: 0,
        lastOrderDate: null,
        orders: const [],
      );
    }).toList();

    final profiles = buildCustomerProfiles(customerSeed, filteredOrders);

    final filtered =
        profiles.where((customer) {
          if (customer.orders.isNotEmpty) {
            return true;
          }

          return _isWithinRange(customer.registrationDate, start, end);
        }).toList()..sort((left, right) {
          final leftDate = left.lastOrderDate ?? left.registrationDate;
          final rightDate = right.lastOrderDate ?? right.registrationDate;
          return rightDate.compareTo(leftDate);
        });

    return filtered;
  }

  Future<Uint8List> _buildPdf({
    required PdfExportSection section,
    required DateTime start,
    required DateTime end,
    required List<ProductionModel> productions,
    required List<OrderModel> orders,
    required List<CustomerModel> customers,
  }) async {
    final document = pw.Document(
      title: section.title,
      author: 'Mighty Hollow Blocks',
      subject: 'Business export report',
    );

    final generatedAt = DateTime.now();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ),
        build: (context) {
          final content = <pw.Widget>[
            _buildReportHeader(
              title: section.title,
              section: section,
              start: start,
              end: end,
              generatedAt: generatedAt,
            ),
            pw.SizedBox(height: 18),
          ];

          if (section == PdfExportSection.production ||
              section == PdfExportSection.everything) {
            content.addAll(_buildProductionSection(productions));
          }

          if (section == PdfExportSection.orders ||
              section == PdfExportSection.everything) {
            if (content.length > 2) {
              content.add(pw.SizedBox(height: 18));
            }
            content.addAll(_buildOrdersSection(orders));
          }

          if (section == PdfExportSection.customers ||
              section == PdfExportSection.everything) {
            if (content.length > 2) {
              content.add(pw.SizedBox(height: 18));
            }
            content.addAll(_buildCustomersSection(customers));
          }

          return content;
        },
      ),
    );

    return document.save();
  }

  pw.Widget _buildReportHeader({
    required String title,
    required PdfExportSection section,
    required DateTime start,
    required DateTime end,
    required DateTime generatedAt,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _primary,
        borderRadius: pw.BorderRadius.circular(24),
      ),
      padding: const pw.EdgeInsets.all(24),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Mighty Hollow Blocks',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Report period: ${_formatDate(start)} to ${_formatDate(end)}',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white.shade(0.15),
                  borderRadius: pw.BorderRadius.circular(18),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Generated on',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(generatedAt),
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.white.shade(0.10),
              borderRadius: pw.BorderRadius.circular(16),
            ),
            child: pw.Row(
              children: [
                _buildInfoChip(
                  label: 'Duration',
                  value: '${end.difference(start).inDays + 1} day(s)',
                ),
                pw.SizedBox(width: 12),
                _buildInfoChip(
                  label: 'Coverage',
                  value: _coverageLabel(section),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoChip({required String label, required String value}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white.shade(0.07),
          borderRadius: pw.BorderRadius.circular(14),
          border: pw.Border.all(color: PdfColors.white.shade(0.12)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  List<pw.Widget> _buildProductionSection(List<ProductionModel> productions) {
    final netBlocks = productions.fold<int>(
      0,
      (sum, item) => sum + item.totalProduction,
    );
    final addedBlocks = productions
        .where((item) => item.totalProduction > 0)
        .fold<int>(0, (sum, item) => sum + item.totalProduction);
    final removedBlocks = productions
        .where((item) => item.totalProduction < 0)
        .fold<int>(0, (sum, item) => sum + item.totalProduction.abs());
    final totalFourInch = productions.fold<int>(
      0,
      (sum, item) => sum + item.fourInch,
    );
    final totalSixInch = productions.fold<int>(
      0,
      (sum, item) => sum + item.sixInch,
    );
    final totalEightInch = productions.fold<int>(
      0,
      (sum, item) => sum + item.eightInch,
    );

    return [
      _buildSectionHeader(
        title: 'Daily Production',
        subtitle:
            'Batch-wise production logs and manual stock adjustments for the selected duration.',
      ),
      pw.SizedBox(height: 12),
      _buildMetricGrid([
        _MetricData(label: 'Entries', value: '${productions.length}'),
        _MetricData(label: 'Added blocks', value: _formatNumber(addedBlocks)),
        _MetricData(
          label: 'Removed blocks',
          value: _formatNumber(removedBlocks),
        ),
        _MetricData(label: 'Net blocks', value: _formatNumber(netBlocks)),
        _MetricData(label: '4 inch', value: _formatNumber(totalFourInch)),
        _MetricData(label: '6 inch', value: _formatNumber(totalSixInch)),
        _MetricData(label: '8 inch', value: _formatNumber(totalEightInch)),
      ]),
      pw.SizedBox(height: 14),
      if (productions.isEmpty)
        _buildEmptyState('No production logs found for the selected duration.')
      else
        _buildTable(
          headers: const [
            'Date',
            'Type',
            'Total',
            '4 inch',
            '6 inch',
            '8 inch',
            'Description',
          ],
          data: productions.map((production) {
            return [
              _formatDate(production.date),
              production.totalProduction >= 0 ? 'Added' : 'Removed',
              _formatNumber(production.totalProduction),
              _formatNumber(production.fourInch),
              _formatNumber(production.sixInch),
              _formatNumber(production.eightInch),
              production.description.trim().isEmpty
                  ? '-'
                  : production.description.trim(),
            ];
          }).toList(),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.2),
            6: const pw.FlexColumnWidth(2.3),
          },
        ),
    ];
  }

  List<pw.Widget> _buildOrdersSection(List<OrderModel> orders) {
    final totalValue = orders.fold<int>(
      0,
      (sum, order) => sum + order.orderValue,
    );
    final totalPaid = orders.fold<int>(
      0,
      (sum, order) => sum + order.paidAmount,
    );
    final totalDue = orders.fold<int>(0, (sum, order) => sum + order.dueAmount);
    final deliveredCount = orders.where((order) => order.isDelivered).length;

    return [
      _buildSectionHeader(
        title: 'Order List',
        subtitle:
            'Commercial activity, payment collection and delivery status.',
      ),
      pw.SizedBox(height: 12),
      _buildMetricGrid([
        _MetricData(label: 'Orders', value: '${orders.length}'),
        _MetricData(label: 'Order value', value: _formatCurrency(totalValue)),
        _MetricData(label: 'Collected', value: _formatCurrency(totalPaid)),
        _MetricData(label: 'Outstanding', value: _formatCurrency(totalDue)),
        _MetricData(label: 'Delivered', value: '$deliveredCount'),
      ]),
      pw.SizedBox(height: 14),
      if (orders.isEmpty)
        _buildEmptyState('No orders found for the selected duration.')
      else
        _buildTable(
          headers: const [
            'Order ID',
            'Customer',
            'Date',
            'Qty',
            'Value',
            'Paid',
            'Due',
            'Delivery',
            'Payment',
          ],
          data: orders.map((order) {
            return [
              order.orderId,
              _buildCustomerLabel(order),
              _formatDate(order.orderDate),
              _formatNumber(order.totalQuantity),
              _formatCurrency(order.orderValue),
              _formatCurrency(order.paidAmount),
              _formatCurrency(order.dueAmount),
              order.isDelivered ? 'Delivered' : 'Pending',
              _paymentStatusLabel(order),
            ];
          }).toList(),
          columnWidths: {
            1: const pw.FlexColumnWidth(2.4),
            4: const pw.FlexColumnWidth(1.1),
            5: const pw.FlexColumnWidth(1.1),
            6: const pw.FlexColumnWidth(1.1),
          },
        ),
    ];
  }

  List<pw.Widget> _buildCustomersSection(List<CustomerModel> customers) {
    final totalSales = customers.fold<int>(
      0,
      (sum, customer) => sum + customer.totalSales,
    );
    final totalDue = customers.fold<int>(
      0,
      (sum, customer) => sum + customer.totalDue,
    );
    final totalOrders = customers.fold<int>(
      0,
      (sum, customer) => sum + customer.orderCount,
    );

    return [
      _buildSectionHeader(
        title: 'Customer List',
        subtitle:
            'Customer accounts with activity or registration in the selected range.',
      ),
      pw.SizedBox(height: 12),
      _buildMetricGrid([
        _MetricData(label: 'Customers', value: '${customers.length}'),
        _MetricData(label: 'Orders in range', value: '$totalOrders'),
        _MetricData(
          label: 'Sales in range',
          value: _formatCurrency(totalSales),
        ),
        _MetricData(label: 'Outstanding', value: _formatCurrency(totalDue)),
      ]),
      pw.SizedBox(height: 14),
      if (customers.isEmpty)
        _buildEmptyState('No customer records found for the selected duration.')
      else
        _buildTable(
          headers: const [
            'Customer',
            'Phone',
            'Registered',
            'Orders',
            'Sales',
            'Due',
            'Address',
          ],
          data: customers.map((customer) {
            return [
              customer.companyName,
              customer.phoneNumber.isEmpty ? '-' : customer.phoneNumber,
              _formatDate(customer.registrationDate),
              '${customer.orderCount}',
              _formatCurrency(customer.totalSales),
              _formatCurrency(customer.totalDue),
              customer.address.trim().isEmpty ? '-' : customer.address.trim(),
            ];
          }).toList(),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.7),
            6: const pw.FlexColumnWidth(2.4),
          },
        ),
    ];
  }

  pw.Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(18),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 6,
            height: 42,
            decoration: pw.BoxDecoration(
              color: _accent,
              borderRadius: pw.BorderRadius.circular(10),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryDark,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 10, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMetricGrid(List<_MetricData> metrics) {
    return pw.Wrap(
      spacing: 10,
      runSpacing: 10,
      children: metrics.map(_buildMetricCard).toList(),
    );
  }

  pw.Widget _buildMetricCard(_MetricData metric) {
    return pw.Container(
      width: 140,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(16),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            metric.label,
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            metric.value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEmptyState(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(24),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: pw.BorderRadius.circular(18),
        border: pw.Border.all(color: _border),
      ),
      child: pw.Text(message, style: pw.TextStyle(color: _muted, fontSize: 11)),
    );
  }

  pw.Widget _buildTable({
    required List<String> headers,
    required List<List<String>> data,
    Map<int, pw.TableColumnWidth>? columnWidths,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(18),
        border: pw.Border.all(color: _border),
      ),
      child: pw.TableHelper.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        columnWidths: columnWidths,
        headerDecoration: pw.BoxDecoration(
          color: _primaryDark,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(18),
            topRight: pw.Radius.circular(18),
          ),
        ),
        headerStyle: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: pw.TextStyle(fontSize: 9, color: _primaryDark),
        cellAlignment: pw.Alignment.centerLeft,
        headerAlignment: pw.Alignment.centerLeft,
        cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        headerPadding: const pw.EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        oddRowDecoration: pw.BoxDecoration(color: _surface),
        rowDecoration: pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.5)),
        ),
      ),
    );
  }

  String _paymentStatusLabel(OrderModel order) {
    if (order.paymentStatus == 1) {
      return 'Paid';
    }
    if (order.paymentStatus == 2) {
      return 'Advance paid';
    }
    return 'Pending';
  }

  String _buildCustomerLabel(OrderModel order) {
    if (order.customerMobile.trim().isEmpty) {
      return order.name;
    }

    return '${order.name} (${order.customerMobile})';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCurrency(int amount) {
    return 'Rs. ${NumberFormat.decimalPattern('en_IN').format(amount)}';
  }

  String _formatNumber(int value) {
    return NumberFormat.decimalPattern('en_IN').format(value);
  }

  String _coverageLabel(PdfExportSection section) {
    switch (section) {
      case PdfExportSection.production:
        return 'Daily production only';
      case PdfExportSection.orders:
        return 'Orders only';
      case PdfExportSection.customers:
        return 'Customers only';
      case PdfExportSection.everything:
        return 'Production, orders and customers';
    }
  }

  bool _isWithinRange(DateTime value, DateTime start, DateTime end) {
    return !value.isBefore(start) && !value.isAfter(end);
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  DateTime _endOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day, 23, 59, 59, 999);
  }
}

class _MetricData {
  const _MetricData({required this.label, required this.value});

  final String label;
  final String value;
}
