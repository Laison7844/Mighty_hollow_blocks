import 'package:flutter/material.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_projects/util/snack_bar_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  static String path = "/order-detail";

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  String _money(int amount) {
    return '₹ ${NumberFormat.decimalPattern('en_IN').format(amount)}';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  void _showRecordPaymentDialog(OrderModel currentOrder) {
    final int remainingDue = currentOrder.dueAmount;
    final TextEditingController amountController = TextEditingController(
      text: remainingDue.toString(),
    );
    String selectedPaymentMode = 'Money in hand';
    String? errorText;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return SingleChildScrollView(
              child: Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Record Payment - ${currentOrder.name}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        "Payment Mode",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedPaymentMode = 'Money in hand';
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedPaymentMode == 'Money in hand'
                                      ? ColorUtil.primary.withValues(alpha: 0.1)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedPaymentMode == 'Money in hand'
                                        ? ColorUtil.primary
                                        : const Color(0xFFE2E8F0),
                                    width: selectedPaymentMode == 'Money in hand' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 18,
                                      color: selectedPaymentMode == 'Money in hand'
                                          ? ColorUtil.primary
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Money in hand",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: selectedPaymentMode == 'Money in hand'
                                            ? ColorUtil.primary
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedPaymentMode = 'Online payment';
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selectedPaymentMode == 'Online payment'
                                      ? ColorUtil.primary.withValues(alpha: 0.1)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedPaymentMode == 'Online payment'
                                        ? ColorUtil.primary
                                        : const Color(0xFFE2E8F0),
                                    width: selectedPaymentMode == 'Online payment' ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_outlined,
                                      size: 18,
                                      color: selectedPaymentMode == 'Online payment'
                                          ? ColorUtil.primary
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Online payment",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: selectedPaymentMode == 'Online payment'
                                            ? ColorUtil.primary
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Amount Paid Now (₹)",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          errorText: errorText,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: ColorUtil.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (errorText != null) {
                            setDialogState(() {
                              errorText = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Color(0xFF475569)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final enteredAmount = int.tryParse(
                                  amountController.text,
                                );
                                if (enteredAmount == null || enteredAmount <= 0) {
                                  setDialogState(() {
                                    errorText = "Please enter a valid amount";
                                  });
                                  return;
                                }
                                if (enteredAmount > remainingDue) {
                                  setDialogState(() {
                                    errorText = "Amount cannot exceed remaining due";
                                  });
                                  return;
                                }
                                try {
                                  if (currentOrder.id != null) {
                                    await ref
                                        .read(orderRepositoryProvider)
                                        .updatePayment(
                                          currentOrder.id!,
                                          enteredAmount,
                                          paymentMode: selectedPaymentMode,
                                        );
                                     if (mounted) {
                                       if (dialogContext.mounted) {
                                         Navigator.pop(dialogContext);
                                       }
                                       SnackbarUtil.showSnackBar(
                                        context: context,
                                        message: "Payment recorded successfully",
                                        isError: false,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setDialogState(() {
                                    errorText = "Failed to update: $e";
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Save Payment",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMarkDeliveredDialog(OrderModel currentOrder) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Mark Order as Delivered",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to mark this order as delivered?",
              style: TextStyle(color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Delivery Notes / Remarks (Optional)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: "Driver name, vehicle no., drop location...",
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (currentOrder.id != null) {
                  await ref
                      .read(orderRepositoryProvider)
                      .updateDeliveryStatus(
                        currentOrder.id!,
                        deliveryNotes: notesController.text.trim(),
                      );
                  if (mounted) {
                    SnackbarUtil.showSnackBar(
                      context: context,
                      message: "Order marked as delivered",
                      isError: false,
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  SnackbarUtil.showSnackBar(
                    context: context,
                    message: "Failed to update: $e",
                    isError: true,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorUtil.darkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Confirm Delivered"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderStreamProvider);
    final OrderModel currentOrder = ordersAsync.maybeWhen(
      data: (orders) => orders.firstWhere(
        (o) => o.id == widget.order.id || o.orderId == widget.order.orderId,
        orElse: () => widget.order,
      ),
      orElse: () => widget.order,
    );

    final payments = [...currentOrder.paymentHistory]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: CustomAppBar(
        title: "Order Details",
        subtitle: "${currentOrder.orderId} • ${currentOrder.name}",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: ColorUtil.heroGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x220F2D59),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentOrder.orderId,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          currentOrder.isCancelled
                              ? "Cancelled"
                              : currentOrder.isDelivered
                                  ? "Delivered"
                                  : "Pending Delivery",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentOrder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (currentOrder.customerMobile.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_iphone_rounded,
                          size: 16,
                          color: Color(0xFFD7E6FF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentOrder.customerMobile,
                          style: const TextStyle(
                            color: Color(0xFFD7E6FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (currentOrder.address.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFFD7E6FF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentOrder.address,
                            style: const TextStyle(
                              color: Color(0xFFD7E6FF),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Summary Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: "Order Value",
                    value: _money(currentOrder.orderValue),
                    accentColor: ColorUtil.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: "Paid Amount",
                    value: _money(currentOrder.paidAmount),
                    accentColor: ColorUtil.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricTile(
                    label: "Remaining Due",
                    value: _money(currentOrder.dueAmount),
                    accentColor: currentOrder.dueAmount > 0
                        ? ColorUtil.danger
                        : ColorUtil.darkGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Order Timeline Journey Section
            const Text(
              "Order History & Timeline",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: ColorUtil.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Complete journey from creation date to payments and final delivery.",
              style: TextStyle(
                color: ColorUtil.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),

            // Timeline Items
            _TimelineItem(
              icon: Icons.assignment_turned_in_outlined,
              iconBg: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              title: "Order Placed",
              subtitle: _formatDate(currentOrder.orderDate),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Block Mix: ${currentOrder.stockParts.join(', ')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ColorUtil.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Quantity: ${currentOrder.totalQuantity} blocks (${_money(currentOrder.orderValue)})",
                    style: const TextStyle(
                      color: ColorUtil.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (currentOrder.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Note: ${currentOrder.description}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorUtil.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Payment Entries Timeline Item
            _TimelineItem(
              icon: Icons.payments_outlined,
              iconBg: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF15803D),
              title: "Payments Recorded (${payments.length})",
              subtitle: currentOrder.paymentStatus == 1
                  ? "Fully Paid"
                  : currentOrder.paymentStatus == 2
                      ? "Advance Paid"
                      : "Pending Payment",
              content: payments.isEmpty
                  ? const Text(
                      "No payment recorded yet.",
                      style: TextStyle(color: ColorUtil.textSecondary, fontSize: 13),
                    )
                  : Column(
                      children: payments.map((p) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                p.paymentMode == 'Online payment'
                                    ? Icons.account_balance_outlined
                                    : Icons.payments_outlined,
                                size: 16,
                                color: ColorUtil.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a').format(p.date),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      p.paymentMode,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: ColorUtil.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _money(p.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: ColorUtil.darkGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),

            // Delivery Timeline Item
            _TimelineItem(
              icon: Icons.local_shipping_outlined,
              iconBg: currentOrder.isDelivered
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              iconColor: currentOrder.isDelivered
                  ? const Color(0xFF15803D)
                  : const Color(0xFFD97706),
              isLast: true,
              title: currentOrder.isDelivered
                  ? "Delivered"
                  : "Delivery Pending",
              subtitle: currentOrder.deliveryDateValue != null
                  ? _formatDate(currentOrder.deliveryDateValue!)
                  : "Awaiting dispatch",
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentOrder.isDelivered
                        ? "Stock has been issued and delivered to customer."
                        : "Order is prepared and awaiting delivery.",
                    style: const TextStyle(
                      color: ColorUtil.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (currentOrder.deliveryNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Delivery Remark: ${currentOrder.deliveryNotes}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorUtil.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: !currentOrder.isCancelled
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (!currentOrder.isPaid) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showRecordPaymentDialog(currentOrder),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text(
                          "Record Payment",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtil.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (!currentOrder.isDelivered) const SizedBox(width: 10),
                  ],
                  if (!currentOrder.isDelivered) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showMarkDeliveredDialog(currentOrder),
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text(
                          "Mark Delivered",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorUtil.darkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          : null,
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget content;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.content,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 70,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ColorUtil.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ColorUtil.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ColorUtil.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  content,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
