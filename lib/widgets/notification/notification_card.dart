import 'package:flutter/material.dart';
import 'package:ForUMHUB/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;

  const NotificationCard({Key? key, required this.notification, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Colors.deepOrange;
    final onPrimary = Colors.white;
    final onSurface = Colors.black87;
    final bg = notification.isNew
        ? primary.withOpacity(0.06)
        : Colors.transparent;

    return Material(
      color: bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: notification.isNew
                      ? Border.all(color: primary, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: notification.avatarUrl == null
                      ? primary
                      : null,
                  backgroundImage: notification.avatarUrl != null
                      ? NetworkImage(notification.avatarUrl!)
                      : null,
                  child: notification.avatarUrl == null
                      ? Icon(Icons.person, size: 24, color: onPrimary)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: notification.isNew ? primary : onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeago.format(notification.timeAgo.toDate()),
                style: TextStyle(
                  color: onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
