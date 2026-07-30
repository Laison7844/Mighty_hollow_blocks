import 'package:flutter/material.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_projects/util/snack_bar_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_projects/ui/add_sections/add_order.dart';
import 'package:flutter_projects/ui/orders/order_detail_screen.dart';

class OrderListItem extends ConsumerStatefulWidget {
  final OrderModel order;
  const OrderListItem({super.key, required this.order});

  @override
  ConsumerState<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends ConsumerState<OrderListItem> {
  String _money(int amount) {
    return '₹ ${NumberFormat.decimalPattern('en_IN').format(amount)}';
  }

  void _showRecordPaymentDialog({
    required BuildContext context,
    required String name,
    required String orderId,
    required int totalAmount,
    required int paidAmount,
  }) {
    final int remainingDue = totalAmount - paidAmount;
    final TextEditingController amountController = TextEditingController(
      text: remainingDue.toString(),
    );
    String selectedPaymentMode = 'Money in hand';
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Record Payment - $name",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF94A3B8),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Balance Summary
                      const Text(
                        "Current Balance:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: "Total: "),
                            TextSpan(
                              text: _money(totalAmount),
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " | Paid: "),
                            TextSpan(
                              text: _money(paidAmount),
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Text(
                            "Remaining Due: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            _money(remainingDue),
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Payment Mode Selector (Radio / Segmented)
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
                                setState(() {
                                  selectedPaymentMode = 'Money in hand';
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedPaymentMode == 'Money in hand'
                                      ? const Color(
                                          0xFF2563EB,
                                        ).withValues(alpha: 0.1)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        selectedPaymentMode == 'Money in hand'
                                        ? ColorUtil.primary
                                        : const Color(0xFFE2E8F0),
                                    width:
                                        selectedPaymentMode == 'Money in hand'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 18,
                                      color:
                                          selectedPaymentMode == 'Money in hand'
                                          ? ColorUtil.primary
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Money in hand",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            selectedPaymentMode ==
                                                'Money in hand'
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
                                setState(() {
                                  selectedPaymentMode = 'Online payment';
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedPaymentMode == 'Online payment'
                                      ? const Color(
                                          0xFF2563EB,
                                        ).withValues(alpha: 0.1)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        selectedPaymentMode == 'Online payment'
                                        ? ColorUtil.primary
                                        : const Color(0xFFE2E8F0),
                                    width:
                                        selectedPaymentMode == 'Online payment'
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_outlined,
                                      size: 18,
                                      color:
                                          selectedPaymentMode ==
                                              'Online payment'
                                          ? ColorUtil.primary
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Online payment",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            selectedPaymentMode ==
                                                'Online payment'
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

                      // Input Field
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
                              color: Color(0xFF2563EB),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (errorText != null) {
                            setState(() {
                              errorText = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                                if (enteredAmount == null ||
                                    enteredAmount <= 0) {
                                  setState(() {
                                    errorText = "Please enter a valid amount";
                                  });
                                  return;
                                }

                                if (enteredAmount > remainingDue) {
                                  setState(() {
                                    errorText =
                                        "Amount cannot exceed remaining due";
                                  });
                                  return;
                                }

                                try {
                                  if (widget.order.id != null) {
                                    await ref
                                        .read(orderRepositoryProvider)
                                        .updatePayment(
                                          widget.order.id!,
                                          enteredAmount,
                                          paymentMode: selectedPaymentMode,
                                        );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      SnackbarUtil.showSnackBar(
                                        context: context,
                                        message:
                                            "Payment of ₹$enteredAmount ($selectedPaymentMode) recorded",
                                        isError: false,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setState(() {
                                    errorText = "Failed to update: $e";
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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

  void _showMarkDeliveredDialog(BuildContext context) {
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
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                if (widget.order.id != null) {
                  await ref
                      .read(orderRepositoryProvider)
                      .updateDeliveryStatus(
                        widget.order.id!,
                        deliveryNotes: notesController.text.trim(),
                      );
                  if (context.mounted) {
                    SnackbarUtil.showSnackBar(
                      context: context,
                      message: "Order marked as delivered",
                      isError: false,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
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

  void _confirmCancelOrder(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text(
          "Are you sure you want to cancel this order? This will restore the reserved stock.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && widget.order.id != null) {
      await ref.read(orderRepositoryProvider).cancelOrder(widget.order.id!);
      if (context.mounted) {
        SnackbarUtil.showSnackBar(
          context: context,
          message: "Order cancelled",
          isError: false,
        );
      }
    }
  }

  void _confirmDeleteOrder(BuildContext context) async {
    if (widget.order.isDelivered) {
      SnackbarUtil.showSnackBar(
        context: context,
        message:
            "Delivered orders cannot be deleted because the stock has already been issued.",
        isError: true,
      );
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.order.id != null) {
      await ref.read(orderRepositoryProvider).deleteOrder(widget.order.id!);
      if (context.mounted) {
        SnackbarUtil.showSnackBar(
          context: context,
          message: "Order deleted successfully.",
          isError: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = widget.order.isCancelled
        ? Colors.grey
        : widget.order.deliveryStatus == 1
        ? ColorUtil.darkGreen
        : Colors.orange;

    Color paymentColor = widget.order.isCancelled
        ? Colors.grey
        : widget.order.paymentStatus == 1
        ? ColorUtil.darkGreen
        : widget.order.paymentStatus == 2
        ? Colors.orange
        : Colors.red;

    final stockSummary = widget.order.stockParts.join(" | ");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => context.push(OrderDetailScreen.path, extra: widget.order),
        borderRadius: BorderRadius.circular(16),
        child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Customer Name, Order ID, Status Badge & Action Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.order.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              widget.order.orderId,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "•  ${DateFormat('dd MMM yyyy').format(widget.order.orderDate)}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (widget.order.address.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.order.address,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.order.isCancelled
                          ? "Cancelled"
                          : widget.order.deliveryStatus == 1
                          ? "Delivered"
                          : "Pending",
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.push(AddOrder.path, extra: widget.order);
                      } else if (value == 'cancel') {
                        _confirmCancelOrder(context);
                      } else if (value == 'delete') {
                        _confirmDeleteOrder(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text('Edit Order'),
                          ],
                        ),
                      ),
                      if (!widget.order.isCancelled &&
                          !widget.order.isDelivered)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.block, size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Cancel Order'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('Delete Order'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Paid / Due & Payment Status Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Paid / Due",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_money(widget.order.paidAmount)} / ${_money(widget.order.dueAmount)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: paymentColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Payment Status",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.order.isCancelled
                              ? "Cancelled"
                              : widget.order.paymentStatus == 1
                              ? "Paid"
                              : widget.order.paymentStatus == 2
                              ? "Advance paid"
                              : "Pending",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: paymentColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Stock & Total Order Value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ORDER QUANTITY",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stockSummary.isEmpty
                              ? 'No stock selected'
                              : stockSummary,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _money(widget.order.orderValue),
                    style: const TextStyle(
                      color: ColorUtil.darkGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              // Contact & Address Details
              if (widget.order.customerMobile.isNotEmpty ||
                  widget.order.address.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (widget.order.customerMobile.isNotEmpty) ...[
                      const Icon(
                        Icons.phone_iphone_rounded,
                        size: 14,
                        color: ColorUtil.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.order.customerMobile,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorUtil.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.order.address.isNotEmpty) ...[
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: ColorUtil.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.order.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorUtil.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Delivery Notes / Remarks
              if (widget.order.deliveryNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        size: 14,
                        color: ColorUtil.darkGreen,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Delivery remark: ${widget.order.deliveryNotes}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Clean Primary Actions Row (Record Payment & Mark Delivered side by side)
              if (!widget.order.isCancelled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (!widget.order.isPaid) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showRecordPaymentDialog(
                              context: context,
                              name: widget.order.name,
                              orderId: widget.order.orderId,
                              totalAmount: widget.order.orderValue,
                              paidAmount: widget.order.paidAmount,
                            );
                          },
                          icon: const Icon(Icons.payment, size: 16),
                          label: const Text(
                            "Record Payment",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtil.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (!widget.order.isDelivered) const SizedBox(width: 10),
                    ],
                    if (!widget.order.isDelivered) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showMarkDeliveredDialog(context),
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                          ),
                          label: const Text(
                            "Mark Delivered",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorUtil.darkGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}
