import 'package:flutter/material.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onProfileTap;

  const CustomAppBar({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'CareSathi',
          style: TextStyle(
            color: Color(0xFF07569b), // Nice blue color
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Color(0xFF07569b)),
          onPressed: () {
            // Handle notification icon tap
          },
        ),
        IconButton(
          icon: const Icon(Icons.person, color: Color(0xFF07569b)),
          onPressed: onProfileTap,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.grey[300],
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1.0);
}