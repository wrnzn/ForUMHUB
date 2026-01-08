import 'package:flutter/material.dart';

class CommentInputBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage; // Added image picker callback
  final bool isUploading; // Added uploading state

  const CommentInputBox({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -2), blurRadius: 5),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
          child: Row(
            children: [
              // Image Picker Button
              IconButton(
                icon: isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                onPressed: isUploading ? null : onPickImage,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                onPressed: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
