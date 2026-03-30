import 'package:flutter/material.dart';
import 'package:flutter_projects/model/inventory_model.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/inventory_repository.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/repository/settings_repository.dart';
import 'package:flutter_projects/ui/customs/textfield_custom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class AddOrder extends ConsumerStatefulWidget {
  final OrderModel? orderToEdit;
  const AddOrder({super.key, this.orderToEdit});
  static String path = "/add-order";

  @override
  ConsumerState<AddOrder> createState() => _AddOrderState();
}

class _AddOrderState extends ConsumerState<AddOrder> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController stock4Controller = TextEditingController();
  final TextEditingController stock6Controller = TextEditingController();
  final TextEditingController stock8Controller = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController(
    text: "0",
  );
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderToEdit != null) {
      final order = widget.orderToEdit!;
      nameController.text = order.name;
      mobileController.text = order.customerMobile;
      stock4Controller.text = order.stock4inch > 0
          ? order.stock4inch.toString()
          : '';
      stock6Controller.text = order.stock6inch > 0
          ? order.stock6inch.toString()
          : '';
      stock8Controller.text = order.stock8inch > 0
          ? order.stock8inch.toString()
          : '';
      amountController.text = order.paidAmount > 0
          ? order.paidAmount.toString()
          : '';
      descriptionController.text = order.description;
      selectedDate = order.orderDate;
      // Pre-calculate total
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTotal();
      });
    }

    stock4Controller.addListener(_calculateTotal);
    stock6Controller.addListener(_calculateTotal);
    stock8Controller.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    stock4Controller.removeListener(_calculateTotal);
    stock6Controller.removeListener(_calculateTotal);
    stock8Controller.removeListener(_calculateTotal);
    nameController.dispose();
    mobileController.dispose();
    stock4Controller.dispose();
    stock6Controller.dispose();
    stock8Controller.dispose();
    amountController.dispose();
    totalAmountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final settings = ref.read(settingsStreamProvider).asData?.value;
    final price4 = settings?.price4Inch ?? 0;
    final price6 = settings?.price6Inch ?? 0;
    final price8 = settings?.price8Inch ?? 0;

    int qty4 = int.tryParse(stock4Controller.text) ?? 0;
    int qty6 = int.tryParse(stock6Controller.text) ?? 0;
    int qty8 = int.tryParse(stock8Controller.text) ?? 0;

    double total = (qty4 * price4) + (qty6 * price6) + (qty8 * price8);
    totalAmountController.text = total.toStringAsFixed(0);
  }

  bool get _canEditInitialPayment =>
      widget.orderToEdit == null ||
      widget.orderToEdit!.paymentHistory.length <= 1;

  Map<String, int> _availableStockBySize(InventoryModel inventory) {
    return {
      '4 Inch': inventory.stock4Inch + (widget.orderToEdit?.stock4inch ?? 0),
      '6 Inch': inventory.stock6Inch + (widget.orderToEdit?.stock6inch ?? 0),
      '8 Inch': inventory.stock8Inch + (widget.orderToEdit?.stock8inch ?? 0),
    };
  }

  Future<bool> _showStockWarningDialog(List<String> warnings) async {
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The requested quantity is higher than current available stock. You can still place the order if you want to continue.',
            ),
            const SizedBox(height: 12),
            ...warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(warning),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Place order'),
          ),
        ],
      ),
    );

    return shouldContinue ?? false;
  }

  Future<void> _saveOrder() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer Name is required")),
      );
      return;
    }
    if (mobileController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer mobile number is required")),
      );
      return;
    }

    int qty4 = int.tryParse(stock4Controller.text) ?? 0;
    int qty6 = int.tryParse(stock6Controller.text) ?? 0;
    int qty8 = int.tryParse(stock8Controller.text) ?? 0;
    final totalQuantity = qty4 + qty6 + qty8;
    if (totalQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one stock quantity")),
      );
      return;
    }

    final inventory = ref.read(inventoryCalculatedProvider).asData?.value;
    if (inventory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inventory is still loading. Please try again."),
        ),
      );
      return;
    }

    final availableStock = _availableStockBySize(inventory);
    final warnings = <String>[];
    final requested = {'4 Inch': qty4, '6 Inch': qty6, '8 Inch': qty8};

    for (final request in requested.entries) {
      final stockName = request.key;
      final requestedQty = request.value;
      final available = availableStock[stockName] ?? 0;
      if (requestedQty > available) {
        warnings.add(
          '$stockName stock is only $available, but requested quantity is $requestedQty.',
        );
      }
    }

    if (warnings.isNotEmpty) {
      final shouldContinue = await _showStockWarningDialog(warnings);
      if (!shouldContinue) {
        return;
      }
    }
    if (!mounted) {
      return;
    }

    int totalValue = int.tryParse(totalAmountController.text) ?? 0;
    int paid = int.tryParse(amountController.text) ?? 0;
    if (paid > totalValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Paid amount cannot be greater than order total"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Use existing ID if editing, else generate new
    String orderId =
        widget.orderToEdit?.orderId ?? "ORD-${Random().nextInt(90000) + 10000}";

    final orderDate = selectedDate ?? DateTime.now();
    final existingHistory = widget.orderToEdit?.paymentHistory ?? const [];
    List<PaymentEntry> paymentHistory;

    if (widget.orderToEdit == null) {
      paymentHistory = paid > 0
          ? [PaymentEntry(amount: paid, date: orderDate)]
          : const [];
    } else if (_canEditInitialPayment) {
      final paymentDate = existingHistory.isNotEmpty
          ? existingHistory.first.date
          : orderDate;
      paymentHistory = paid > 0
          ? [PaymentEntry(amount: paid, date: paymentDate)]
          : const [];
    } else {
      paymentHistory = existingHistory;
      paid = paymentHistory.fold<int>(0, (sum, item) => sum + item.amount);
    }

    // Determine payment status
    // 0: Pending, 1: Paid, 2: Advance
    int paymentStatus = 0;
    if (paid >= totalValue && totalValue > 0) {
      paymentStatus = 1;
    } else if (paid > 0) {
      paymentStatus = 2;
    }

    final newOrder = OrderModel(
      id: widget.orderToEdit?.id,
      name: nameController.text.trim(),
      customerMobile: mobileController.text.trim(),
      orderId: orderId,
      paidAmount: paid,
      dueAmount: totalValue - paid,
      paymentStatus: paymentStatus,
      deliveryStatus: widget.orderToEdit?.deliveryStatus ?? 0,
      orderDate: orderDate,
      deliveryDate: widget.orderToEdit?.deliveryDate ?? "Pending",
      orderValue: totalValue,
      description: descriptionController.text.trim(),
      stock4inch: qty4,
      stock6inch: qty6,
      stock8inch: qty8,
      paymentHistory: paymentHistory,
      isDelivered: widget.orderToEdit?.isDelivered ?? false,
      isPaid: paymentStatus == 1,
    );

    try {
      if (widget.orderToEdit != null) {
        await ref.read(orderRepositoryProvider).updateOrder(newOrder);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order Updated Successfully")),
          );
        }
      } else {
        await ref.read(orderRepositoryProvider).addOrder(newOrder);
        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order Created Successfully")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving order: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(settingsStreamProvider, (previous, next) {
      _calculateTotal();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.orderToEdit != null ? "Edit Order" : "Create New Order",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Customer Information"),
            _buildLabel("Customer Name"),
            TextfieldCustom(
              hintText: "Enter customer name",
              controller: nameController,
            ),
            const SizedBox(height: 16),
            _buildLabel("Customer Mobile Number"),
            TextfieldCustom(
              hintText: "Enter mobile number",
              controller: mobileController,
              keyboardType: TextInputType.phone,
              suffix: const Icon(Icons.phone_outlined, size: 20),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader("Order Details"),
            _buildLabel("Order Date"),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate != null
                          ? DateFormat('MMM dd, yyyy').format(selectedDate!)
                          : "Select Date",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel("Stock Requirements"),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubLabel("4 Inch"),
                      TextfieldCustom(
                        hintText: "Qty",
                        controller: stock4Controller,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubLabel("6 Inch"),
                      TextfieldCustom(
                        hintText: "Qty",
                        controller: stock6Controller,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSubLabel("8 Inch"),
                      TextfieldCustom(
                        hintText: "Qty",
                        controller: stock8Controller,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel("Description"),
            TextfieldCustom(
              hintText: "Add delivery notes, site info or order remarks",
              controller: descriptionController,
              maxLines: 4,
              minLines: 3,
            ),

            const SizedBox(height: 24),

            _buildLabel("Total Amount (Calculated)"),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: totalAmountController,
                readOnly: true,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: "0",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "₹",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionHeader("Payment"),
            _buildLabel("Initial Payment Received"),
            TextfieldCustom(
              hintText: "Amount received",
              controller: amountController,
              keyboardType: TextInputType.number,
              readOnly: !_canEditInitialPayment,
              suffix: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "₹",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            if (!_canEditInitialPayment)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Additional payments are locked here because this order already has multiple dated payment entries. Use the order card to record the next payment.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.orderToEdit != null
                            ? "Update Order"
                            : "Create Order",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildSubLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}
