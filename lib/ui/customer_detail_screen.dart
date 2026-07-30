import 'package:flutter/material.dart';
import 'package:flutter_projects/model/customer_model.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/orders/order_history_screen.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:intl/intl.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final CustomerModel customer;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatCurrency(int amount) {
    return '₹ ${NumberFormat.decimalPattern('en_IN').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final orders = [...customer.orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: CustomAppBar(
        title: customer.companyName,
        subtitle: customer.phoneNumber.isEmpty
            ? 'Customer account summary'
            : 'Mobile: ${customer.phoneNumber}',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CustomerHero(
              customer: customer,
              formatDate: _formatDate,
              formatCurrency: _formatCurrency,
            ),
            const SizedBox(height: 18),
            _CustomerProfileSection(
              customer: customer,
              formatDate: _formatDate,
              formatCurrency: _formatCurrency,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _SectionIntro(
                    title: 'Orders and payments',
                    trailing: '${orders.length} orders',
                  ),
                ),
              ],
            ),
            if (orders.length > 1) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderHistoryScreen(
                          initialSearchQuery: customer.companyName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: ColorUtil.primary,
                  ),
                  label: Text(
                    "View All Orders for ${customer.companyName}",
                    style: const TextStyle(
                      color: ColorUtil.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            if (orders.isEmpty)
              const _EmptyState(
                message: 'No orders have been linked to this customer yet.',
              )
            else
              ...orders.map(
                (order) => _OrderActivityCard(
                  order: order,
                  formatDate: _formatDate,
                  formatCurrency: _formatCurrency,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomerHero extends StatelessWidget {
  const _CustomerHero({
    required this.customer,
    required this.formatDate,
    required this.formatCurrency,
  });

  final CustomerModel customer;
  final String Function(DateTime) formatDate;
  final String Function(int) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorUtil.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F2D59),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.companyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customer.phoneNumber.isEmpty
                          ? 'Phone number not added'
                          : customer.phoneNumber,
                      style: const TextStyle(
                        color: Color(0xFFD7E6FF),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer since ${formatDate(customer.registrationDate)}',
                      style: const TextStyle(
                        color: Color(0xFFD7E6FF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _HeroMetric(
                label: 'Total sales',
                value: formatCurrency(customer.totalSales),
              ),
              _HeroMetric(
                label: 'Received',
                value: formatCurrency(customer.totalPaid),
              ),
              _HeroMetric(
                label: 'Outstanding',
                value: formatCurrency(customer.totalDue),
              ),
              _HeroMetric(label: 'Orders', value: '${customer.orderCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerProfileSection extends StatelessWidget {
  const _CustomerProfileSection({
    required this.customer,
    required this.formatDate,
    required this.formatCurrency,
  });

  final CustomerModel customer;
  final String Function(DateTime) formatDate;
  final String Function(int) formatCurrency;

  @override
  Widget build(BuildContext context) {
    final String displayAddress = customer.address.trim().isNotEmpty
        ? customer.address
        : (customer.orders.any((o) => o.address.trim().isNotEmpty)
            ? customer.orders
                .firstWhere((o) => o.address.trim().isNotEmpty)
                .address
            : '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ColorUtil.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: ColorUtil.actionGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    customer.companyName.trim().isNotEmpty
                        ? customer.companyName.trim().substring(0, 1).toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.companyName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ColorUtil.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Registered ${formatDate(customer.registrationDate)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorUtil.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone_iphone_rounded,
                        size: 18,
                        color: ColorUtil.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Mobile",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.textSecondary,
                              ),
                            ),
                            Text(
                              customer.phoneNumber.isEmpty
                                  ? "Not added"
                                  : customer.phoneNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ColorUtil.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 18,
                        color: ColorUtil.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Orders",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: ColorUtil.textSecondary,
                              ),
                            ),
                            Text(
                              "${customer.orderCount} orders",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ColorUtil.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (displayAddress.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: ColorUtil.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Address",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayAddress,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ColorUtil.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (customer.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: ColorUtil.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Customer Notes",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorUtil.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: ColorUtil.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _FinancialStatCard(
                  label: "Total Sales",
                  value: formatCurrency(customer.totalSales),
                  accentColor: ColorUtil.primary,
                  bgColor: const Color(0xFFE0F2FE),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinancialStatCard(
                  label: "Paid Collected",
                  value: formatCurrency(customer.totalPaid),
                  accentColor: ColorUtil.darkGreen,
                  bgColor: const Color(0xFFDCFCE7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FinancialStatCard(
                  label: "Outstanding",
                  value: formatCurrency(customer.totalDue),
                  accentColor: customer.totalDue > 0 ? ColorUtil.danger : ColorUtil.darkGreen,
                  bgColor: customer.totalDue > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;
  final Color bgColor;

  const _FinancialStatCard({
    required this.label,
    required this.value,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorUtil.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderActivityCard extends StatelessWidget {
  const _OrderActivityCard({
    required this.order,
    required this.formatDate,
    required this.formatCurrency,
  });

  final OrderModel order;
  final String Function(DateTime) formatDate;
  final String Function(int) formatCurrency;

  String get _deliveryLabel => order.isDelivered ? 'Delivered' : 'Pending';

  String get _paymentLabel {
    if (order.paymentStatus == 1) {
      return 'Paid';
    }
    if (order.paymentStatus == 2) {
      return 'Advance paid';
    }
    return 'Pending payment';
  }

  Color get _deliveryColor =>
      order.isDelivered ? ColorUtil.darkGreen : ColorUtil.accent;

  Color get _paymentColor {
    if (order.paymentStatus == 1) {
      return ColorUtil.darkGreen;
    }
    if (order.paymentStatus == 2) {
      return ColorUtil.accent;
    }
    return ColorUtil.danger;
  }

  @override
  Widget build(BuildContext context) {
    final payments = [...order.paymentHistory]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorUtil.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderId,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ColorUtil.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Placed on ${formatDate(order.orderDate)}',
                      style: const TextStyle(
                        color: ColorUtil.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusChip(label: _deliveryLabel, color: _deliveryColor),
                  const SizedBox(height: 8),
                  _StatusChip(label: _paymentLabel, color: _paymentColor),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _OrderMetricCard(
                label: 'Quantity',
                value: '${order.totalQuantity} blocks',
                helper: order.stockParts.join('  •  '),
              ),
              _OrderMetricCard(
                label: 'Order value',
                value: formatCurrency(order.orderValue),
                helper: 'Total billed amount',
              ),
              _OrderMetricCard(
                label: 'Paid',
                value: formatCurrency(order.paidAmount),
                helper: 'Collected so far',
                accentColor: ColorUtil.darkGreen,
              ),
              _OrderMetricCard(
                label: 'Due',
                value: formatCurrency(order.dueAmount),
                helper: 'Outstanding balance',
                accentColor: order.dueAmount > 0
                    ? ColorUtil.danger
                    : ColorUtil.darkGreen,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorUtil.surfaceMuted,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorUtil.border),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Block mix',
                  value: order.stockParts.isEmpty
                      ? 'No quantity added'
                      : order.stockParts.join(', '),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'Delivery',
                  value: order.deliveryDateValue != null
                      ? 'Delivered on ${formatDate(order.deliveryDateValue!)}'
                      : 'Delivery pending',
                ),
                if (order.address.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Delivery address',
                    value: order.address,
                  ),
                ],
                if (order.deliveryNotes.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Delivery note',
                    value: order.deliveryNotes,
                  ),
                ],
                if (order.customerMobile.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.phone_iphone_rounded,
                    label: 'Customer mobile',
                    value: order.customerMobile,
                  ),
                ],
              ],
            ),
          ),
          if (order.description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailBlock(
              icon: Icons.sticky_note_2_outlined,
              title: 'Order notes',
              text: order.description,
            ),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorUtil.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: ColorUtil.primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Payment history',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ColorUtil.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${payments.length} entries',
                      style: const TextStyle(
                        color: ColorUtil.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (payments.isEmpty)
                  const Text(
                    'No payments recorded yet for this order.',
                    style: TextStyle(
                      color: ColorUtil.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  ...payments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ColorUtil.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: ColorUtil.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatDate(payment.date),
                                    style: const TextStyle(
                                      color: ColorUtil.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        payment.paymentMode == 'Online payment'
                                            ? Icons.account_balance_outlined
                                            : Icons.payments_outlined,
                                        size: 13,
                                        color: ColorUtil.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        payment.paymentMode,
                                        style: const TextStyle(
                                          color: ColorUtil.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatCurrency(payment.amount),
                              style: const TextStyle(
                                color: ColorUtil.darkGreen,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ColorUtil.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: ColorUtil.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}



class _OrderMetricCard extends StatelessWidget {
  const _OrderMetricCard({
    required this.label,
    required this.value,
    required this.helper,
    this.accentColor = ColorUtil.textPrimary,
  });

  final String label;
  final String value;
  final String helper;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            helper,
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: ColorUtil.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: ColorUtil.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorUtil.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ColorUtil.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ColorUtil.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: ColorUtil.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: ColorUtil.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
