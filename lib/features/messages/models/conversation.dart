class Conversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? avatarUrl;
  int unreadCount;
  bool online;
  bool archived;
  bool muted;
  bool pinned;

  Conversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastMessageAt,
    this.avatarUrl,
    this.unreadCount = 0,
    this.online = false,
    this.archived = false,
    this.muted = false,
    this.pinned = false,
  });

  Conversation copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? avatarUrl,
    int? unreadCount,
    bool? online,
    bool? archived,
    bool? muted,
    bool? pinned,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      online: online ?? this.online,
      archived: archived ?? this.archived,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
    );
  }
}
