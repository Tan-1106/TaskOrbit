import 'package:flutter/material.dart';

/// A custom AppBar widget that allows for a title, an optional back button, and optional action widgets.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  // The preferred size of the AppBar is set to the standard toolbar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Builds the AppBar widget with the specified title, back button, and actions.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: actions,
      centerTitle: true,
    );
  }
}
