import 'package:flutter/material.dart';

const Color brandOrange = Color(0xFFFB8C00); 

String formatCourseName(String fullCourse) {
  return fullCourse
      .replaceAll('Bachelor of Science in ', '')
      .replaceAll('Bachelor of Elementary ', '')
      .replaceAll('Bachelor of Secondary ', '')
      .replaceAll('Bachelor of ', '')
      .replaceAll('Associate in ', '')
      .trim();
}

Widget courseChip(String course) {
  if (course.isEmpty || course == 'General') return const SizedBox();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    constraints: const BoxConstraints(maxWidth: 150),
    decoration: BoxDecoration(color: brandOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: brandOrange.withOpacity(0.2))),
    child: Text(formatCourseName(course), overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(color: brandOrange, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}

Widget categoryBadge(String category) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
    child: Text(
      category,
      style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}
