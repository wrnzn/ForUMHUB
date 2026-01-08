import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/notification_model.dart';
import 'notification_card.dart';

class NotificationSection extends StatelessWidget {
  final String title;
  final List<AppNotification> items;
  final VoidCallback? onMarkAllRead;
  final void Function(AppNotification)? onItemTap;

  const NotificationSection({
    Key? key,
    required this.title,
    required this.items,
    this.onMarkAllRead,
    this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (onMarkAllRead != null)
                GestureDetector(
                  onTap: onMarkAllRead,
                  child: Text(
                    'Mark as all read',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              NotificationCard(
                notification: item,
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              ),
              if (i != items.length - 1)
                Divider(
                  height: 1,
                  indent: 72,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.08),
                ),
            ],
          );
        }),
      ],
    );
  }
}
