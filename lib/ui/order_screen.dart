import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/dashborad.dart';
import 'package:flutter_projects/util/color_util.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static String path = "/orders-screen";
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Dashborad(),
      appBar: CustomAppBar(title: "Orders List"),
      body: buildOrderCard(
        projectName: "EcoBuild Projects",
        orderId: "ORD-00121",
        paidAmount: 0,
        dueAmount: 48000,
        paymentStatus: "Pending",
        deliveryStatus: "Processing",
        orderDate: "Oct 15, 2025",
        deliveryDate: "Delivery: Oct 20, 2025 (10:00 AM)",
        stockSummary: '4": 1000 | 6": 500 | 8": 200',
        orderValue: 48000,
        isDelivered: false,
      ),
    );
  }

  // Widget buildOrderCard({
  //   required String projectName,
  //   required String orderId,
  //   required String mobile,
  //   required String orderDate,
  //   required String deliveryDate,
  //   required String stockSummary,
  //   required int orderValue,
  //   required String status,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20),
  //     child: Card(
  //       elevation: 5,
  //       child: Container(
  //         height: 315,
  //         width: double.infinity,
  //         padding: const EdgeInsets.only(left: 5),
  //         decoration: BoxDecoration(
  //           color: ColorUtil.blurBorder,
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         child: Container(
  //           height: 300,
  //           width: double.infinity,
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     projectName,
  //                     style: const TextStyle(
  //                       fontSize: 20,
  //                       fontWeight: FontWeight.w700,
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 6,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.orange.withOpacity(0.15),
  //                       borderRadius: BorderRadius.circular(20),
  //                     ),
  //                     child: Text(
  //                       status,
  //                       style: const TextStyle(
  //                         color: Colors.orange,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 4),
  //               Text(orderId, style: const TextStyle(color: Colors.grey)),

  //               const SizedBox(height: 16),

  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const Text(
  //                         "Mobile",
  //                         style: TextStyle(color: Colors.grey, fontSize: 12),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         mobile,
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       const Text(
  //                         "Order Date",
  //                         style: TextStyle(color: Colors.grey, fontSize: 12),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         orderDate,
  //                         style: const TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 20),

  //               const Text(
  //                 "ORDER VALUE",
  //                 style: TextStyle(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                   color: Colors.grey,
  //                 ),
  //               ),

  //               const SizedBox(height: 4),

  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       stockSummary,
  //                       style: const TextStyle(fontSize: 13),
  //                     ),
  //                   ),
  //                   Text(
  //                     "₹ $orderValue",
  //                     style: const TextStyle(
  //                       color: Colors.green,
  //                       fontSize: 26,
  //                       fontWeight: FontWeight.w800,
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 12),
  //               const Divider(),
  //               const SizedBox(height: 12),

  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       const Icon(
  //                         Icons.local_shipping_rounded,
  //                         color: Colors.red,
  //                         size: 20,
  //                       ),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         deliveryDate,
  //                         style: const TextStyle(
  //                           color: Colors.red,
  //                           fontWeight: FontWeight.w600,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 18,
  //                       vertical: 10,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.green,
  //                       borderRadius: BorderRadius.circular(30),
  //                     ),
  //                     child: const Text(
  //                       "Mark Delivered",
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildOrderCard({
    required String projectName,
    required String orderId,
    required int paidAmount,
    required int dueAmount,
    required String paymentStatus,
    required String deliveryStatus,
    required String orderDate,
    required String deliveryDate,
    required String stockSummary,
    required int orderValue,
    bool isDelivered = false,
  }) {
    Color statusColor = deliveryStatus == "Delivered"
        ? Colors.green
        : Colors.orange;

    Color paymentColor = paymentStatus == "Fully Paid"
        ? ColorUtil.darkGreen
        : paymentStatus == "Advance Paid"
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: Container(
          height: 335,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            color: ColorUtil.blurBorder,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            height: 335,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.15),
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
                      projectName,
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
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Del: $deliveryStatus",
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
                Text(orderId, style: const TextStyle(color: Colors.grey)),

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
                          "₹ $paidAmount / ₹ $dueAmount",
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
                          paymentStatus,
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
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      "₹ $orderValue",
                      style: const TextStyle(
                        color: ColorUtil.darkGreen,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

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
                            deliveryDate,
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Record Payment",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ColorUtil.darkGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Mark Delivered",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
    );
  }
}
