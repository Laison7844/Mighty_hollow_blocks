import 'package:flutter/material.dart';
import 'package:flutter_projects/util/color_util.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;

  const CustomAppBar({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 84,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle ?? 'Track stock, production and orders at a glance.',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFD8E6FF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: ColorUtil.heroGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x220F2D59),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(84);
}
