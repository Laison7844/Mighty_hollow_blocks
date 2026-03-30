import 'package:flutter/material.dart';
import 'package:flutter_projects/model/order_model.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_projects/util/snack_bar_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_projects/ui/add_sections/add_order.dart';

class OrderListItem extends ConsumerStatefulWidget {
  final OrderModel order;
  const OrderListItem({super.key, required this.order});

  @override
  ConsumerState<OrderListItem> createState() => _OrderListItemState();
}

class _OrderListItemState extends ConsumerState<OrderListItem> {
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
                      // --- Header ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "Record Payment for $name",
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
                      const Divider(height: 32),

                      // --- Balance Summary ---
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
                              text: "₹ ${totalAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: " | Paid: "),
                            TextSpan(
                              text: "₹ ${paidAmount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            "Remaining Due: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "₹ ${remainingDue.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Color(0xFFEF4444), // Warning Red
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Input Field ---
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
                      const SizedBox(height: 10),
                      const Text(
                        "Enter a partial amount for advance payment, or the full remaining balance.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Action Buttons ---
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
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
                                  // Call Repository
                                  if (widget.order.id != null) {
                                    await ref
                                        .read(orderRepositoryProvider)
                                        .updatePayment(
                                          widget.order.id!,
                                          enteredAmount,
                                        );
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      SnackbarUtil.showSnackBar(
                                        context: context,
                                        message:
                                            "Payment recorded successfully",
                                        isError: false,
                                      );
                                    }
                                  } else {
                                    // Handle missing ID (should generally not happen if fetched from firestore)
                                    setState(() {
                                      errorText = "Error: Order ID missing";
                                    });
                                  }
                                } catch (e) {
                                  setState(() {
                                    errorText = "Failed to update: $e";
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF10B981,
                                ), // Success Green
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Payment",
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
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Mark as Delivered"),
        content: const Text(
          "Are you sure you want to mark this order as delivered?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              try {
                if (widget.order.id != null) {
                  await ref
                      .read(orderRepositoryProvider)
                      .updateDeliveryStatus(widget.order.id!);
                  if (context.mounted) {
                    SnackbarUtil.showSnackBar(
                      context: context,
                      message: "Order marked as delivered",
                      isError: false,
                    );
                  }
                } else {
                  if (context.mounted) {
                    SnackbarUtil.showSnackBar(
                      context: context,
                      message: "Error: Order ID missing",
                      isError: true,
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
            child: const Text(
              "Yes",
              style: TextStyle(color: ColorUtil.darkGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logic for Status Colors
    Color statusColor = widget.order.deliveryStatus == 1
        ? Colors.green
        : Colors.orange;
    Color paymentColor = widget.order.paymentStatus == 1
        ? ColorUtil.darkGreen
        : widget.order.paymentStatus == 2
        ? Colors.orange
        : Colors.red;

    // Logic for dynamic Stock Summary from 3 parameters
    final stockSummary = widget.order.stockParts.join(" | ");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Dismissible(
        key: ValueKey(widget.order.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF21B7CA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              Icon(Icons.edit, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Edit",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFE4A49),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Edit
            context.push(AddOrder.path, extra: widget.order);
            return false;
          } else {
            if (widget.order.isDelivered) {
              SnackbarUtil.showSnackBar(
                context: context,
                message:
                    "Delivered orders cannot be deleted because the stock has already been issued.",
                isError: true,
              );
              return false;
            }
            // Delete
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Delete Order"),
                content: const Text(
                  "Are you sure you want to delete this order?",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context, true); // Return true to confirm
                      if (widget.order.id != null) {
                        await ref
                            .read(orderRepositoryProvider)
                            .deleteOrder(widget.order.id!);
                        if (context.mounted) {
                          SnackbarUtil.showSnackBar(
                            context: context,
                            message:
                                "Order deleted successfully. Reserved stock has been restored.",
                            isError: false,
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        child: Card(
          elevation: 5,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              color: ColorUtil.blurBorder,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: const Color(0xffe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.order.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.order.deliveryStatus == 1
                              ? "Delivered"
                              : "Pending",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.order.orderId,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (widget.order.isDelivered &&
                          widget.order.deliveryDate.isNotEmpty &&
                          DateTime.tryParse(widget.order.deliveryDate) !=
                              null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 14,
                                color: ColorUtil.darkGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM').format(
                                  DateTime.parse(widget.order.deliveryDate),
                                ),
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Paid / Due",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "₹ ${widget.order.paidAmount} / ₹ ${widget.order.dueAmount}",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: paymentColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Payment Status",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.order.paymentStatus == 1
                                ? "Paid"
                                : widget.order.paymentStatus == 2
                                ? "Advance paid"
                                : "Pending",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: paymentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "ORDER VALUE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          stockSummary,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        "₹ ${widget.order.orderValue}",
                        style: const TextStyle(
                          color: ColorUtil.darkGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (widget.order.customerMobile.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_iphone_rounded,
                          size: 16,
                          color: ColorUtil.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.order.customerMobile,
                          style: const TextStyle(
                            color: ColorUtil.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.order.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        widget.order.description,
                        style: const TextStyle(
                          color: ColorUtil.textSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_shipping_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              // Using the DateTime format here
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(widget.order.orderDate),
                              softWrap: true,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      (widget.order.isPaid && widget.order.isDelivered)
                          ? SizedBox.shrink()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                widget.order.isPaid
                                    ? Container()
                                    : InkWell(
                                        onTap: () {
                                          _showRecordPaymentDialog(
                                            context: context,
                                            name: widget.order.name,
                                            orderId: widget.order.orderId,
                                            totalAmount:
                                                widget.order.orderValue,
                                            paidAmount: widget.order.paidAmount,
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            "Record Payment",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                widget.order.isDelivered
                                    ? SizedBox.shrink()
                                    : InkWell(
                                        onTap: () {
                                          _showMarkDeliveredDialog(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ColorUtil.darkGreen,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Text(
                                            "Mark Delivered",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
