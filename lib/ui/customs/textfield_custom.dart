import 'package:flutter/material.dart';
import 'package:flutter_projects/util/color_util.dart';

class TextfieldCustom extends StatelessWidget {
  const TextfieldCustom({
    super.key,
    required this.hintText,
    required this.controller,
    this.suffix,
    this.keyboardType,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
  });

  final String hintText;
  final TextEditingController controller;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ColorUtil.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: ColorUtil.textSecondary,
          fontSize: 15,
        ),
        suffixIcon: suffix,
        fillColor: ColorUtil.surfaceMuted,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ColorUtil.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ColorUtil.primary, width: 1.6),
        ),
      ),
    );
  }
}
