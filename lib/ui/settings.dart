import 'package:flutter/material.dart';
import 'package:flutter_projects/model/settings_model.dart';
import 'package:flutter_projects/repository/settings_repository.dart';
import 'package:flutter_projects/ui/customs/appbar.dart';
import 'package:flutter_projects/ui/customs/textfield_custom.dart';
import 'package:flutter_projects/util/color_util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static String path = "/settings-screen";

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _price4Controller = TextEditingController();
  final TextEditingController _price6Controller = TextEditingController();
  final TextEditingController _price8Controller = TextEditingController();

  @override
  void dispose() {
    _price4Controller.dispose();
    _price6Controller.dispose();
    _price8Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsyncValue = ref.watch(settingsStreamProvider);

    ref.listen(settingsStreamProvider, (previous, next) {
      if (next.value != null) {
        if (_price4Controller.text.isEmpty) {
          _price4Controller.text = next.value!.price4Inch.toString();
        }
        if (_price6Controller.text.isEmpty) {
          _price6Controller.text = next.value!.price6Inch.toString();
        }
        if (_price8Controller.text.isEmpty) {
          _price8Controller.text = next.value!.price8Inch.toString();
        }
      }
    });

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Settings",
        subtitle: "Manage selling prices for each concrete block size.",
      ),
      body: settingsAsyncValue.when(
        data: (settings) {
          if (_price4Controller.text.isEmpty && settings.price4Inch != 0) {
            _price4Controller.text = settings.price4Inch.toString();
          }
          if (_price6Controller.text.isEmpty && settings.price6Inch != 0) {
            _price6Controller.text = settings.price6Inch.toString();
          }
          if (_price8Controller.text.isEmpty && settings.price8Inch != 0) {
            _price8Controller.text = settings.price8Inch.toString();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsHeroCard(settings: settings),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorUtil.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ColorUtil.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Block prices",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Update the default unit price used while preparing new orders.",
                        style: TextStyle(
                          color: ColorUtil.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPriceField("4 Inch Block", _price4Controller),
                      const SizedBox(height: 16),
                      _buildPriceField("6 Inch Block", _price6Controller),
                      const SizedBox(height: 16),
                      _buildPriceField("8 Inch Block", _price8Controller),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final newSettings = SettingsModel(
                              price4Inch:
                                  double.tryParse(_price4Controller.text) ?? 0,
                              price6Inch:
                                  double.tryParse(_price6Controller.text) ?? 0,
                              price8Inch:
                                  double.tryParse(_price8Controller.text) ?? 0,
                            );
                            await ref
                                .read(settingsRepositoryProvider)
                                .updateSettings(newSettings);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Settings updated successfully',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "Save changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading settings: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: ColorUtil.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ColorUtil.textPrimary,
            ),
          ),
        ),
        TextfieldCustom(
          hintText: "0.00",
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffix: const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "₹",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: ColorUtil.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({required this.settings});

  final SettingsModel settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: ColorUtil.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current price snapshot",
            style: TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PriceMetric(
                  label: "4 Inch",
                  value: settings.price4Inch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PriceMetric(
                  label: "6 Inch",
                  value: settings.price6Inch,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PriceMetric(
                  label: "8 Inch",
                  value: settings.price8Inch,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD7E6FF),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "₹ ${value.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
