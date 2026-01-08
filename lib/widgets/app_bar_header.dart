import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppBarHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch; // Added to control search visibility

  const AppBarHeader({
    super.key,
    this.showSearch = true, // Default to true
  });

  @override
  Widget build(BuildContext context) {
    final UserService _userService = UserService();
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => Scaffold.of(context).openDrawer(),
          child: StreamBuilder<Map<String, dynamic>?>(
            stream: userId != null ? _userService.getUserDataStream(userId) : Stream.value(null),
            builder: (context, snapshot) {
              final String? photoUrl = snapshot.data?['photoUrl'];
              return Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]),
                child: ClipOval(
                  child: photoUrl != null && photoUrl.isNotEmpty
                      ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey, size: 20))
                      : const Icon(Icons.person, color: Colors.grey, size: 20),
                ),
              );
            },
          ),
        ),
      ),
      title: Image.asset('assets/headerlogo.png', height: 35, fit: BoxFit.contain),
      actions: [
        if (showSearch) // FIXED: Only show if enabled
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
