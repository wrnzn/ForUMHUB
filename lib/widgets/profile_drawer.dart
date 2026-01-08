import 'package:flutter/material.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/services/auth_service.dart';
import 'package:ForUMHUB/pages/bookmarks_page.dart';
import 'package:ForUMHUB/pages/profile_page.dart';
import 'package:ForUMHUB/pages/change_password_page.dart';
import 'package:ForUMHUB/pages/login_page.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({super.key});

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  String? _userEmail;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final user = _userService.getCurrentUser();
    if (user != null) {
      _userId = user.uid;
      _userEmail = user.email;
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginPage()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandOrange = Color(0xFFFB8C00);

    return Drawer(
      backgroundColor: Colors.white,
      child: StreamBuilder<Map<String, dynamic>?>(
        stream: _userId != null ? _userService.getUserDataStream(_userId!) : Stream.value(null),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final userName = userData?['name'] ?? 'User';
          final photoUrl = userData?['photoUrl'];

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: brandOrange),
                accountName: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text(_userEmail ?? '', style: const TextStyle(color: Colors.white70)),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.white, width: 2)),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildDefaultAvatar(userName))
                        : _buildDefaultAvatar(userName),
                  ),
                ),
              ),
              _buildListTile(Icons.person_outline, 'My Profile', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: userName, initialTabIndex: 0)));
              }),
              _buildListTile(Icons.bookmark_outline, 'Bookmarks', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksPage()));
              }),
              _buildListTile(Icons.post_add_rounded, 'My Posts', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: userName, initialTabIndex: 0)));
              }),
              _buildListTile(Icons.store_outlined, 'My Market', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: userName, initialTabIndex: 1)));
              }),
              _buildListTile(Icons.lock_outline_rounded, 'Change Password', () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
              }),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Divider()),
              _buildListTile(Icons.logout_rounded, 'Log out', _handleLogout, color: Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 24),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFFB8C00)),
      ),
    );
  }
}
