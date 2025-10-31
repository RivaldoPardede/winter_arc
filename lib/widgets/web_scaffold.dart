import 'package:flutter/material.dart';
import 'package:winter_arc/utils/responsive_layout.dart';

/// Web-optimized scaffold with sidebar navigation for desktop
class WebScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final int currentIndex;
  final Function(int)? onNavigationChanged;

  const WebScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.currentIndex = 0,
    this.onNavigationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (!isDesktop) {
      // Mobile/Tablet: Use regular Scaffold
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }

    // Desktop: Use sidebar navigation
    return Scaffold(
      body: Row(
        children: [
          // Sidebar navigation
          _buildSidebar(context),
          
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top app bar
                _buildDesktopAppBar(context),
                
                // Content
                Expanded(
                  child: CenteredContentContainer(
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // App branding
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(
                  Icons.ac_unit,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Winter Arc',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Navigation items
          if (onNavigationChanged != null) ...[
            _buildNavItem(
              context,
              icon: Icons.home,
              label: 'Home',
              index: 0,
            ),
            _buildNavItem(
              context,
              icon: Icons.fitness_center,
              label: 'Log Workout',
              index: 1,
            ),
            _buildNavItem(
              context,
              icon: Icons.trending_up,
              label: 'Progress',
              index: 2,
            ),
            _buildNavItem(
              context,
              icon: Icons.groups,
              label: 'Squad',
              index: 3,
            ),
            _buildNavItem(
              context,
              icon: Icons.person,
              label: 'Profile',
              index: 4,
            ),
          ],
          
          const Spacer(),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '90-Day Winter Arc Challenge',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = currentIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        selected: isSelected,
        leading: Icon(icon),
        title: Text(label),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        selectedTileColor: theme.colorScheme.primaryContainer,
        selectedColor: theme.colorScheme.onPrimaryContainer,
        onTap: () => onNavigationChanged?.call(index),
      ),
    );
  }

  Widget _buildDesktopAppBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
