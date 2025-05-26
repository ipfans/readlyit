import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final VoidCallback? onPocketImport;

  const CustomAppBar({
    super.key,
    required this.titleText,
    this.onPocketImport,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titleText,
        style: TextStyle( // Consistent title style
          fontWeight: FontWeight.bold,
          // fontSize: 20, // Example: if you want to customize size
        ),
      ),
      elevation: 1.0, // Subtle elevation
      centerTitle: true, // Optional: center title
      actions: <Widget>[
        if (onPocketImport != null)
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            tooltip: 'Import from Pocket', // Replace with localized string
            onPressed: onPocketImport,
          ),
        // Example: Add a settings icon button
        // IconButton(
        //   icon: const Icon(Icons.settings_outlined),
        //   tooltip: 'Settings', // Replace with localized string
        //   onPressed: () {
        //     // TODO: Navigate to settings screen or show settings options
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Settings tapped (Placeholder)')),
        //     );
        //   },
        // ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
