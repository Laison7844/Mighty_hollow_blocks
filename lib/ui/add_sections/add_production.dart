import 'package:flutter/material.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_projects/ui/customs/textfield_custom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddProduction extends ConsumerStatefulWidget {
  const AddProduction({super.key, this.productionToEdit});
  static String path = "/add-production";
  final ProductionModel? productionToEdit;

  @override
  ConsumerState<AddProduction> createState() => _AddProductionState();
}

class _AddProductionState extends ConsumerState<AddProduction> {
  // Controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController fourInchController = TextEditingController();
  final TextEditingController sixInchController = TextEditingController();
  final TextEditingController eightInchController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productionToEdit != null) {
      final p = widget.productionToEdit!;
      _selectedDate = p.date;
      fourInchController.text = p.fourInch.toString();
      sixInchController.text = p.sixInch.toString();
      eightInchController.text = p.eightInch.toString();
      descriptionController.text = p.description;
    }
    dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
  }

  @override
  void dispose() {
    dateController.dispose();
    fourInchController.dispose();
    sixInchController.dispose();
    eightInchController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8,
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xFF2563EB)),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveProduction() async {
    int four = int.tryParse(fourInchController.text) ?? 0;
    int six = int.tryParse(sixInchController.text) ?? 0;
    int eight = int.tryParse(eightInchController.text) ?? 0;

    if (four == 0 && six == 0 && eight == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter production count")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final production = ProductionModel(
      id: widget.productionToEdit?.id, // Keep ID if editing
      date: _selectedDate,
      totalProduction: four + six + eight,
      fourInch: four,
      sixInch: six,
      eightInch: eight,
      description: descriptionController.text.trim(),
    );

    try {
      if (widget.productionToEdit != null) {
        await ref
            .read(productionRepositoryProvider)
            .updateProduction(production);
      } else {
        await ref.read(productionRepositoryProvider).addProduction(production);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productionToEdit != null
                  ? "Production Updated"
                  : "Production Logged Successfully",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error saving production: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24.0),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.productionToEdit != null
                        ? "Edit Production"
                        : "Add Production",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Divider(color: Color(0xFFE2E8F0)),
              const SizedBox(height: 15),

              // --- NEW DATE PICKER FIELD ---
              const Text(
                "Production Date",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextfieldCustom(
                    hintText: "Select Date",
                    controller: dateController,
                    suffix: const Icon(Icons.calendar_today_outlined, size: 20),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- PRODUCTION COUNT SECTION ---
              const Text(
                "Production Count",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextfieldCustom(
                hintText: "Count of 4 inch",
                controller: fourInchController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextfieldCustom(
                hintText: "Count of 6 inch",
                controller: sixInchController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextfieldCustom(
                hintText: "Count of 8 inch",
                controller: eightInchController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              const Text(
                "Description",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextfieldCustom(
                hintText: "Add notes about this production batch",
                controller: descriptionController,
                maxLines: 4,
                minLines: 3,
              ),

              const SizedBox(height: 30),

              // --- Action Buttons ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF475569),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                          : const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
