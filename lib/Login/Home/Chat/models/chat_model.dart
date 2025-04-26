class Chat {
  final String chatId; // Firestore document ID
  final String userId; // Other user's ID (derived from participants)
  final String name; // Other user's display name (fetched from users collection)
  final String lastMessage; // Last message preview
  final String time; // Timestamp of last message
  final String avatarUrl; // Other user's avatar URL (fetched from users collection)

  Chat({
    required this.chatId,
    required this.userId,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
  });

  factory Chat.fromJson(Map<String, dynamic> json, String chatId, String currentUserId) {
    // Extract the other user's ID from participants
    final participants = json['participants'] as List<dynamic>;
    final userId = participants.firstWhere((id) => id != currentUserId);

    return Chat(
      chatId: chatId,
      userId: userId,
      name: '', // Will be fetched from users collection
      lastMessage: json['lastMessage'] ?? '',
      time: json['time']?.toString() ?? '',
      avatarUrl: '', // Will be fetched from users collection
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastMessage': lastMessage,
      'time': time,
    };
  }
}

class Message {
  final String id; // Firestore document ID
  final String senderId; // Sender's Firebase user ID
  final String content; // Message text
  final String timestamp; // Message timestamp

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, String id) {
    return Message(
      id: id,
      senderId: json['senderId'] ?? '',
      content: json['content'] ?? '',
      timestamp: json['timestamp']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}