import 'package:flutter/material.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/production_repository.dart';
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
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(22, 18, 10, 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.productionToEdit != null
                ? "Edit Production"
                : "Add Production",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  child: TextField(
                    controller: dateController,
                    readOnly: true,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222222), // ColorUtil.textPrimary
                    ),
                    decoration: const InputDecoration(
                      hintText: "Select Date",
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                      fillColor: Color(0xFFF1F1F1), // ColorUtil.surfaceMuted
                    ),
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
              TextField(
                controller: fourInchController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
                decoration: const InputDecoration(
                  hintText: "Count of 4 inch",
                  fillColor: Color(0xFFF1F1F1),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: sixInchController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
                decoration: const InputDecoration(
                  hintText: "Count of 6 inch",
                  fillColor: Color(0xFFF1F1F1),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: eightInchController,
                keyboardType: TextInputType.number,
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
                decoration: const InputDecoration(
                  hintText: "Count of 8 inch",
                  fillColor: Color(0xFFF1F1F1),
                ),
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
              TextField(
                controller: descriptionController,
                maxLines: 4,
                minLines: 3,
                enabled: !_isLoading,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
                decoration: const InputDecoration(
                  hintText: "Add notes about this production batch",
                  fillColor: Color(0xFFF1F1F1),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProduction,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
              : const Text("Save", style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
