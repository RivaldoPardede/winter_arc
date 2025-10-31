import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winter_arc/models/workout_template.dart';
import 'package:winter_arc/providers/user_provider.dart';
import 'package:winter_arc/services/template_service.dart';

class TemplatesScreen extends StatelessWidget {
  final Function(WorkoutTemplate)? onTemplateSelected;

  const TemplatesScreen({
    super.key,
    this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final templateService = TemplateService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Templates'),
      ),
      body: StreamBuilder<List<WorkoutTemplate>>(
        stream: templateService.templatesStream(userProvider.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading templates: ${snapshot.error}'),
            );
          }

          final templates = snapshot.data ?? [];

          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Templates Yet',
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Create templates from your workouts to log faster next time!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _TemplateCard(
                template: template,
                onTap: onTemplateSelected != null
                    ? () {
                        onTemplateSelected!(template);
                        Navigator.of(context).pop();
                      }
                    : null,
                onDelete: () async {
                  final confirmed = await _showDeleteConfirmation(
                    context,
                    template.name,
                  );
                  if (confirmed == true) {
                    await templateService.deleteTemplate(
                      userProvider.userId,
                      template.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Template deleted'),
                        ),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String templateName,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Template?'),
          content: Text('Are you sure you want to delete "$templateName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _TemplateCard({
    required this.template,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.bookmark,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            template.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDelete,
                      tooltip: 'Delete template',
                      color: theme.colorScheme.error,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${template.exercises.length} exercises',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: template.exercises.take(5).map((exercise) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${exercise.exercise.name} (${exercise.numberOfSets}x${exercise.targetReps})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (template.exercises.length > 5) ...[
                const SizedBox(height: 8),
                Text(
                  '+${template.exercises.length - 5} more exercises',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
