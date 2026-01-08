import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ForUMHUB/models/message_model.dart';
import 'package:ForUMHUB/models/chat_model.dart';
import 'package:ForUMHUB/services/message_service.dart';
import 'package:ForUMHUB/services/file_service.dart';
import 'package:ForUMHUB/services/chat_service.dart';
import 'package:ForUMHUB/services/presence_service.dart';
import 'package:ForUMHUB/services/user_service.dart';
import 'package:ForUMHUB/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConversationPage extends StatefulWidget {
  final ChatItemModel chatPartner;
  const ConversationPage({Key? key, required this.chatPartner}) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final FileService _fileService = FileService();
  final ChatService _chatService = ChatService();
  final PresenceService _presenceService = PresenceService();
  final UserService _userService = UserService();
  
  String? _chatId;
  String? _otherUserId;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatPartner.id;
    _getPartnerId();
  }

  Future<void> _getPartnerId() async {
    final chatDoc = await _chatService.getChatDocument(_chatId!);
    if (chatDoc != null) {
      final participants = List<String>.from(chatDoc['participants'] ?? []);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (mounted) setState(() => _otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => ''));
    }
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);
    if (msgDate == today) return "Today";
    if (msgDate == yesterday) return "Yesterday";
    return DateFormat('MMMM d, yyyy').format(date);
  }

  Future<void> _pickAndSendImage() async {
    final File? imageFile = await _fileService.pickImage();
    if (imageFile == null) return;
    setState(() => _isUploading = true);
    try {
      final String? url = await _fileService.uploadImage(imageFile);
      if (url != null) await _messageService.sendMessage(_chatId!, '', imageUrl: url);
    } catch (e) {
      debugPrint('Chat Image Error: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _confirmDelete() async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Delete Conversation?'), content: const Text('This will delete all messages for both users.'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(c, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete'))]));
    if (ok == true) { await _messageService.deleteConversation(_chatId!); Navigator.pop(context); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        title: _otherUserId != null 
          ? StreamBuilder<Map<String, dynamic>?>(
              stream: _userService.getUserDataStream(_otherUserId!),
              builder: (context, snapshot) {
                final data = snapshot.data;
                final partnerName = data?['name'] ?? widget.chatPartner.name;
                final partnerPhoto = data?['photoUrl'];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(name: partnerName))),
                  child: Row(children: [
                    Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[200]), child: ClipOval(child: partnerPhoto != null && partnerPhoto.isNotEmpty ? Image.network(partnerPhoto, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.person, color: Colors.grey)) : const Icon(Icons.person, color: Colors.grey))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(partnerName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), _buildStatusIndicator()])),
                  ]),
                );
              },
            ) : const Text('Loading...'),
        actions: [PopupMenuButton<String>(onSelected: (val) { if (val == 'delete') _confirmDelete(); }, itemBuilder: (c) => [const PopupMenuItem(value: 'delete', child: Text('Delete Chat'))])],
      ),
      body: Column(children: [_buildMessagesList(), _buildMessageInput()]),
    );
  }

  Widget _buildStatusIndicator() {
    if (_otherUserId == null || _otherUserId!.isEmpty) return const SizedBox();
    return StreamBuilder<bool>(stream: _presenceService.isUserOnline(_otherUserId!), builder: (context, snapshot) {
      final isOnline = snapshot.data ?? false;
      return Text(isOnline ? 'Online' : 'Offline', style: TextStyle(color: isOnline ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.w500));
    });
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: StreamBuilder<List<MessageModel>>(
        stream: _messageService.getMessages(_chatId!),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final bool showDateHeader = index == messages.length - 1 || DateFormat('yyyy-MM-dd').format(message.timestamp) != DateFormat('yyyy-MM-dd').format(messages[index + 1].timestamp);
              return Column(children: [if (showDateHeader) _buildDateHeader(_formatHeaderDate(message.timestamp)), _buildMessageWithTime(message)]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(String text) {
    return Center( // Center the date header (Today, Yesterday)
      child: Container(margin: const EdgeInsets.only(top: 10, bottom: 24), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildMessageWithTime(MessageModel message) {
    final String timeStr = DateFormat('hh:mm a').format(message.timestamp);
    return Align(
      // FIXED: Added alignment logic to push messages to sides
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildMessageBubble(message),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
      decoration: BoxDecoration(
        color: message.isMe ? Theme.of(context).colorScheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null) ...[
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(message.imageUrl!, fit: BoxFit.cover)),
            if (message.text.isNotEmpty) const SizedBox(height: 8),
          ],
          if (message.text.isNotEmpty) Text(message.text, style: TextStyle(color: message.isMe ? Colors.white : Colors.black87, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(children: [
        IconButton(icon: Icon(Icons.image_outlined, color: Colors.grey[600]), onPressed: _pickAndSendImage),
        Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)), child: TextField(controller: _messageController, decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none)))),
        const SizedBox(width: 8),
        if (_isUploading) const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
        else IconButton(icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary), onPressed: () {
          if (_messageController.text.trim().isEmpty) return;
          _messageService.sendMessage(_chatId!, _messageController.text.trim());
          _messageController.clear();
        }),
      ]),
    );
  }
}
