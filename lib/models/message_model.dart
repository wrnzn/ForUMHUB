class MessageModel {
  final String senderId;
  final String text;
  final String? imageUrl; // Added imageUrl
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.senderId,
    required this.text,
    this.imageUrl, // Added imageUrl
    required this.timestamp,
    required this.isMe,
  });
}
