import 'package:flutter/material.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/production_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductionHistoryScreen extends ConsumerStatefulWidget {
  const ProductionHistoryScreen({super.key});

  static String path = "/production-history";

  @override
  ConsumerState<ProductionHistoryScreen> createState() =>
      _ProductionHistoryScreenState();
}

class _ProductionHistoryScreenState
    extends ConsumerState<ProductionHistoryScreen> {
  DateTime? _selectedDate;
  final TextEditingController _quantityController = TextEditingController();

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productionAsync = ref.watch(productionStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: "Production History"),
      body: Column(
        children: [
          // --- SEARCH SECTION ---
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter By",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // DATE FILTER
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _selectedDate == null ? _pickDate : _clearDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedDate != null
                                ? Colors.blue.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            border: Border.all(
                              color: _selectedDate != null
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedDate != null
                                    ? Icons.close
                                    : Icons.calendar_today,
                                size: 18,
                                color: _selectedDate != null
                                    ? Colors.red
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate != null
                                    ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                    : "Select Date",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDate != null
                                      ? Colors.blue
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // QUANTITY FILTER
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: "Search Quantity",
                          prefixIcon: const Icon(Icons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: _quantityController.text.isNotEmpty
                              ? Colors.blue.withValues(alpha: 0.05)
                              : Colors.grey.shade100,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- LIST SECTION ---
          Expanded(
            child: productionAsync.when(
              data: (logs) {
                // Apply filters
                List<ProductionModel> filteredLogs = logs;

                // Date Filter
                if (_selectedDate != null) {
                  filteredLogs = filteredLogs
                      .where(
                        (log) =>
                            log.date.year == _selectedDate!.year &&
                            log.date.month == _selectedDate!.month &&
                            log.date.day == _selectedDate!.day,
                      )
                      .toList();
                }

                // Quantity Filter
                if (_quantityController.text.isNotEmpty) {
                  final query = int.tryParse(_quantityController.text);
                  if (query != null) {
                    filteredLogs = filteredLogs
                        .where((log) => log.totalProduction == query)
                        .toList();
                  }
                }

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "No records found",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    return ProductionListItem(production: filteredLogs[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }
}
