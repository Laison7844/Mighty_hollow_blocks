import 'package:flutter/material.dart';
import 'package:flutter_projects/model/production_model.dart';
import 'package:flutter_projects/repository/inventory_repository.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _StockAction { add, remove }

class AddStocks extends ConsumerStatefulWidget {
  const AddStocks({super.key, required this.blockName, required this.type});
  static String path = "/add-stocks";
  final String blockName;
  final int type; // 4, 6, or 8

  @override
  ConsumerState<AddStocks> createState() => _AddStocksState();
}

class _AddStocksState extends ConsumerState<AddStocks> {
  final TextEditingController _countController = TextEditingController();
  bool _isLoading = false;
  _StockAction _selectedAction = _StockAction.add;

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> _saveStock({
    required int? currentStock,
    required bool isInventoryLoading,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final count = int.tryParse(_countController.text) ?? 0;
    if (count <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    final isDelete = _selectedAction == _StockAction.remove;
    if (isDelete) {
      if (isInventoryLoading || currentStock == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Inventory is loading. Please try again in a moment.",
            ),
          ),
        );
        return;
      }
      if (count > currentStock) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "Cannot remove $count from ${widget.blockName}. Current stock is $currentStock.",
            ),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final signedCount = isDelete ? -count : count;
    final four = widget.type == 4 ? signedCount : 0;
    final six = widget.type == 6 ? signedCount : 0;
    final eight = widget.type == 8 ? signedCount : 0;

    final production = ProductionModel(
      date: DateTime.now(),
      totalProduction: signedCount,
      fourInch: four,
      sixInch: six,
      eightInch: eight,
      description:
          'Stock ${isDelete ? "removed" : "added"} manually from ${widget.blockName} stock dialog',
    );

    try {
      await ref.read(productionRepositoryProvider).addProduction(production);
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isDelete
                ? "Removed $count from ${widget.blockName} stock"
                : "Added $count to ${widget.blockName} stock",
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("Error updating stock: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryCalculatedProvider);
    final inventory = inventoryAsync.asData?.value;
    final currentStock = inventory == null
        ? null
        : switch (widget.type) {
            4 => inventory.stock4Inch,
            6 => inventory.stock6Inch,
            _ => inventory.stock8Inch,
          };

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(22, 18, 10, 0),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Manage Stock",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.blockName,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0FF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: Color(0xFF1D4ED8),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Current Stock",
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inventoryAsync.isLoading
                                ? "Loading..."
                                : "${currentStock ?? 0} blocks",
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SegmentedButton<_StockAction>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment<_StockAction>(
                    value: _StockAction.add,
                    icon: Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: Text("Add"),
                  ),
                  ButtonSegment<_StockAction>(
                    value: _StockAction.remove,
                    icon: Icon(Icons.remove_circle_outline_rounded, size: 18),
                    label: Text("Delete"),
                  ),
                ],
                selected: {_selectedAction},
                onSelectionChanged: _isLoading
                    ? null
                    : (selected) {
                        setState(() {
                          _selectedAction = selected.first;
                        });
                      },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _countController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter quantity",
                  prefixIcon: const Icon(Icons.numbers_rounded),
                  helperText: _selectedAction == _StockAction.add
                      ? "This quantity will be added to current stock."
                      : "This quantity will be removed from current stock.",
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorUtil.primary,
                      width: 1.6,
                    ),
                  ),
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
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () => _saveStock(
                  currentStock: currentStock,
                  isInventoryLoading: inventoryAsync.isLoading,
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedAction == _StockAction.add
                ? ColorUtil.primary
                : const Color(0xFFDC2626),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  _selectedAction == _StockAction.add
                      ? Icons.add_rounded
                      : Icons.remove_rounded,
                ),
          label: Text(
            _isLoading
                ? "Saving..."
                : _selectedAction == _StockAction.add
                ? "Add Stock"
                : "Delete Stock",
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
