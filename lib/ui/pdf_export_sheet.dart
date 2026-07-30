import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_projects/repository/customer_repository.dart';
import 'package:flutter_projects/repository/order_repository.dart';
import 'package:flutter_projects/repository/production_repository.dart';
import 'package:flutter_projects/services/pdf_export_service.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class PdfExportSheet extends ConsumerStatefulWidget {
  const PdfExportSheet({super.key, required this.parentContext});

  final BuildContext parentContext;

  @override
  ConsumerState<PdfExportSheet> createState() => _PdfExportSheetState();
}

class _PdfExportSheetState extends ConsumerState<PdfExportSheet> {
  final PdfExportService _exportService = PdfExportService();
  late DateTimeRange _selectedRange;
  PdfExportSection _selectedSection = PdfExportSection.everything;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedRange = DateTimeRange(
      start: today.subtract(const Duration(days: 29)),
      end: today,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_isExporting,
      child: Container(
        decoration: const BoxDecoration(
          color: ColorUtil.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: ColorUtil.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: ColorUtil.heroGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'PDF Export',
                          style: TextStyle(
                            color: Color(0xFFD7E6FF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Build a polished report for any date range.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose the section you want, adjust the duration, and export a clean PDF that is saved directly on your device.',
                        style: TextStyle(
                          color: Color(0xFFD7E6FF),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildRangeCard(context),
                const SizedBox(height: 20),
                _buildSectionCard(),
                const SizedBox(height: 18),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportPdf,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(
                      _isExporting ? 'Preparing PDF...' : 'Export PDF',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export summary',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedSection.title} • ${_formatRange(_selectedRange)}',
            style: const TextStyle(
              color: ColorUtil.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'File will be saved in Downloads when available, otherwise app storage.',
            style: TextStyle(
              color: ColorUtil.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorUtil.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time duration',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use presets for speed or choose a custom date range.',
            style: TextStyle(
              color: ColorUtil.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _pickDateRange,
            child: Ink(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorUtil.surfaceMuted,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ColorUtil.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F0FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.date_range_rounded,
                      color: ColorUtil.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatRange(_selectedRange),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedRange.duration.inDays + 1} day(s) selected',
                          style: const TextStyle(
                            color: ColorUtil.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ColorUtil.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _RangePresetChip(
                label: 'Today',
                onTap: () => _applyPreset(_RangePreset.today),
              ),
              _RangePresetChip(
                label: '7 days',
                onTap: () => _applyPreset(_RangePreset.last7Days),
              ),
              _RangePresetChip(
                label: '30 days',
                onTap: () => _applyPreset(_RangePreset.last30Days),
              ),
              _RangePresetChip(
                label: 'This month',
                onTap: () => _applyPreset(_RangePreset.thisMonth),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard() {
    final options = [
      _SectionOptionData(
        section: PdfExportSection.production,
        title: 'Daily production',
        subtitle: 'Production totals, size mix and notes.',
        icon: Icons.factory_outlined,
      ),
      _SectionOptionData(
        section: PdfExportSection.orders,
        title: 'Order list',
        subtitle: 'Order value, payment and delivery status.',
        icon: Icons.receipt_long_rounded,
      ),
      _SectionOptionData(
        section: PdfExportSection.customers,
        title: 'Customer list',
        subtitle: 'Customers with activity in the chosen range.',
        icon: Icons.groups_2_outlined,
      ),
      _SectionOptionData(
        section: PdfExportSection.everything,
        title: 'Everything',
        subtitle: 'A combined business report with all sections.',
        icon: Icons.dashboard_customize_outlined,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorUtil.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ColorUtil.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PDF section',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick what should appear inside the report.',
            style: TextStyle(
              color: ColorUtil.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = option.section == _selectedSection;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  setState(() {
                    _selectedSection = option.section;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFEAF2FF)
                        : ColorUtil.surfaceMuted,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected ? ColorUtil.primary : ColorUtil.border,
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF163F7A,
                              ).withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? ColorUtil.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          option.icon,
                          color: isSelected ? Colors.white : ColorUtil.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.subtitle,
                              style: const TextStyle(
                                color: ColorUtil.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isSelected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isSelected
                            ? ColorUtil.primary
                            : ColorUtil.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorUtil.primary,
              secondary: ColorUtil.accent,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range == null || !mounted) {
      return;
    }

    setState(() {
      _selectedRange = range;
    });
  }

  void _applyPreset(_RangePreset preset) {
    final now = DateTime.now();
    late final DateTime start;
    late final DateTime end;

    switch (preset) {
      case _RangePreset.today:
        start = DateTime(now.year, now.month, now.day);
        end = now;
      case _RangePreset.last7Days:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        end = now;
      case _RangePreset.last30Days:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 29));
        end = now;
      case _RangePreset.thisMonth:
        start = DateTime(now.year, now.month, 1);
        end = now;
    }

    setState(() {
      _selectedRange = DateTimeRange(start: start, end: end);
    });
  }

  Future<void> _exportPdf() async {
    final parentMessenger = ScaffoldMessenger.of(widget.parentContext);

    setState(() {
      _isExporting = true;
    });

    try {
      final result = await _exportService.createReport(
        section: _selectedSection,
        start: _selectedRange.start,
        end: _selectedRange.end,
        productionRepository: ref.read(productionRepositoryProvider),
        orderRepository: ref.read(orderRepositoryProvider),
        customerRepository: ref.read(customerRepositoryProvider),
      );

      final filePath = await _savePdfToDevice(
        bytes: result.bytes,
        fileName: result.fileName,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      parentMessenger.showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedSection.title} PDF saved to: ${_compactPath(filePath)}',
          ),
        ),
      );
      
      await OpenFilex.open(filePath);
    } catch (error) {
      if (!mounted) {
        return;
      }

      parentMessenger.showSnackBar(
        SnackBar(content: Text('Unable to export PDF: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<String> _savePdfToDevice({
    required List<int> bytes,
    required String fileName,
  }) async {
    final candidateDirectories = <Directory>[];

    if (Platform.isAndroid) {
      candidateDirectories.add(Directory('/storage/emulated/0/Download'));
      final externalDownloads = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (externalDownloads != null) {
        candidateDirectories.addAll(externalDownloads);
      }
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        candidateDirectories.add(externalDir);
      }
    }

    if (Platform.isIOS) {
      final docsDir = await getApplicationDocumentsDirectory();
      candidateDirectories.add(docsDir);
    } else if (!Platform.isAndroid) {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        candidateDirectories.add(downloads);
      }
      candidateDirectories.add(await getApplicationSupportDirectory());
    }

    if (candidateDirectories.isEmpty) {
      candidateDirectories.add(await getApplicationDocumentsDirectory());
    }

    Object? lastError;
    for (final directory in candidateDirectories) {
      try {
        await directory.create(recursive: true);
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(bytes, flush: true);
        return file.path;
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception('Unable to save PDF to local storage: $lastError');
  }

  String _compactPath(String path) {
    if (path.length <= 60) {
      return path;
    }
    return '...${path.substring(path.length - 57)}';
  }

  String _formatRange(DateTimeRange range) {
    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }
}

enum _RangePreset { today, last7Days, last30Days, thisMonth }

class _SectionOptionData {
  const _SectionOptionData({
    required this.section,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final PdfExportSection section;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _RangePresetChip extends StatelessWidget {
  const _RangePresetChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: ColorUtil.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
