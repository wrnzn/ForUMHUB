import 'package:flutter/material.dart';
import 'package:ForUMHUB/widgets/app_bar_header.dart';
import 'package:ForUMHUB/widgets/home_page/home_navigation_bar.dart';
import 'package:ForUMHUB/widgets/bottom_nav_bar.dart';
import 'package:ForUMHUB/widgets/home_page/create_post_dialog.dart';
import 'package:ForUMHUB/pages/market_page.dart';
import 'package:ForUMHUB/pages/chat_page.dart';
import 'package:ForUMHUB/pages/notification_page.dart';
import 'package:ForUMHUB/pages/campus_page.dart';
import 'package:ForUMHUB/pages/courses_page.dart';
import 'package:ForUMHUB/widgets/profile_drawer.dart';
import 'package:ForUMHUB/services/presence_service.dart';
import 'package:ForUMHUB/services/notification_service.dart';
import 'package:ForUMHUB/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotificationService _notifService = NotificationService();
  final PresenceService _presenceService = PresenceService();
  int _activeTab = 0;
  int _selectedTopTab = 0; 
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _presenceService.setOnline();
  }

  @override
  void dispose() {
    _presenceService.setOffline();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      // FIXED: Hide header search specifically when on the Market page (index 1)
      appBar: AppBarHeader(showSearch: _activeTab != 1),
      drawer: const ProfileDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _activeTab = index >= 2 ? index + 1 : index),
        children: [_buildMainFeed(), const MarketPage(), const NotificationPage(), const ChatPage()],
      ),
      bottomNavigationBar: StreamBuilder<List<AppNotification>>(
        stream: _notifService.getNotifications(),
        builder: (context, notifSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('chats')
                .where('participants', arrayContains: currentUserId).snapshots(),
            builder: (context, chatSnap) {
              final int newNotifs = notifSnap.data?.where((n) => n.isNew).length ?? 0;
              
              int newMessages = 0;
              if (chatSnap.hasData) {
                for (var doc in chatSnap.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final int count = (data['unreadCount'] as num?)?.toInt() ?? 0;
                  final String lastSenderId = data['lastSenderId'] ?? '';
                  if (count > 0 && lastSenderId != currentUserId) {
                    newMessages++;
                  }
                }
              }

              return BottomNavBar(
                activeTab: _activeTab,
                notificationCount: newNotifs,
                messageCount: newMessages,
                onTabChanged: (index) {
                  if (index == 2) {
                    showDialog(context: context, builder: (c) => const CreatePostDialog());
                  } else {
                    setState(() => _activeTab = index);
                    _pageController.animateToPage(index > 2 ? index - 1 : index, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMainFeed() {
    return Column(
      children: [
        HomeNavigationBar(selectedTab: _selectedTopTab, onTabChanged: (i) => setState(() => _selectedTopTab = i)),
        Expanded(child: IndexedStack(index: _selectedTopTab, children: const [CampusPage(), CoursesPage()])),
      ],
    );
  }
}
