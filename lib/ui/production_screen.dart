import 'package:flutter/material.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/button.dart';
import 'package:intl/intl.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  static String path = "/production-screen";

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  // Format: Today / Yesterday / Date
  String formatProductionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final given = DateTime(date.year, date.month, date.day);

    String formatted = DateFormat("MMM dd, yyyy").format(date);

    if (given == today) return "Today's Total: $formatted";
    if (given == today.subtract(const Duration(days: 1))) {
      return "Yesterday's Total: $formatted";
    }

    return formatted;
  }

  // Time ago (1 hour ago etc.)
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays == 1) return "Yesterday";

    return "${diff.inDays} days ago";
  }

  // Dummy values
  DateTime lastEntry = DateTime.now().subtract(const Duration(hours: 1));
  int todayProduction = 1850;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Production List"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
       //   mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            const Text(
              "Daily Production Logs",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            _latestProduction(),
                        const SizedBox(height: 10),
CustomButton(icon: Icon(Icons.dashboard), name: "Record Production", onTap: (){})
          ],
        ),
      ),
    );
  }

  Card _latestProduction() {
    return Card(
            elevation: 10,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 5, 22, 148),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatProductionDate(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$todayProduction blocks",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color.fromARGB(255, 10, 69, 173),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Last entry recorded ${timeAgo(DateTime.now())
}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
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
