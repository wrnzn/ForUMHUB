import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String category;
  final String timestamp;
  final String description;
  final int upvotes;
  final int bookmarks;
  final List<Color> avatarColors;

  const PostCard({
    super.key,
    required this.title,
    required this.category,
    required this.timestamp,
    required this.description,
    required this.upvotes,
    required this.bookmarks,
    required this.avatarColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepOrange,
                ),
                child: const Icon(Icons.home, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '• $timestamp',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Handle edit action
                  } else if (value == 'save') {
                    // Handle save action
                  } else if (value == 'report') {
                    // Handle report action
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'save', child: Text('Save post')),
                  const PopupMenuItem(value: 'report', child: Text('Report')),
                ],
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.deepOrange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$upvotes',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(Icons.bookmark_border, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$bookmarks',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 40,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: avatarColors.isNotEmpty
                            ? avatarColors[0]
                            : Colors.grey[300],
                      ),
                    ),
                    if (avatarColors.length > 1)
                      Positioned(
                        left: 16,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: avatarColors[1],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
