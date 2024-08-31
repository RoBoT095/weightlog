import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wysiwyg_rounded,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  "Weight Tracker App!",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings,
                size: 26, color: Theme.of(context).colorScheme.onSurface),
            title: Text(
              "Settings",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 24),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info_outline,
                size: 26, color: Theme.of(context).colorScheme.onSurface),
            title: Text(
              "Info/help",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface, fontSize: 24),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
