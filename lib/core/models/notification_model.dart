class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final NotificationStatus status;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionText;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.status,
    this.data,
    this.actionUrl,
    this.actionText,
    this.readAt,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: NotificationType.fromString(json['type'] ?? 'system_update'),
      priority: NotificationPriority.fromString(json['priority'] ?? 'medium'),
      status: NotificationStatus.fromString(json['status'] ?? 'unread'),
      data: json['data'],
      actionUrl: json['actionUrl'],
      actionText: json['actionText'],
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.value,
      'priority': priority.value,
      'status': status.value,
      'data': data,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'readAt': readAt?.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    NotificationStatus? status,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? actionText,
    DateTime? readAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isUnread => status == NotificationStatus.unread;
  bool get isRead => status == NotificationStatus.read;
  bool get isArchived => status == NotificationStatus.archived;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

enum NotificationType {
  bookingConfirmed('booking_confirmed'),
  bookingCancelled('booking_cancelled'),
  bookingCompleted('booking_completed'),
  paymentSuccessful('payment_successful'),
  paymentFailed('payment_failed'),
  serviceAvailable('service_available'),
  promotion('promotion'),
  reminder('reminder'),
  systemUpdate('system_update'),
  securityAlert('security_alert'),
  locationAdded('location_added'),
  locationDeleted('location_deleted'),
  artisanAddedToFavorites('artisan_added_to_favorites'),
  artisanRemovedFromFavorites('artisan_removed_from_favorites');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemUpdate,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case NotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case NotificationType.bookingCompleted:
        return 'Booking Completed';
      case NotificationType.paymentSuccessful:
        return 'Payment Successful';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.serviceAvailable:
        return 'Service Available';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.systemUpdate:
        return 'System Update';
      case NotificationType.securityAlert:
        return 'Security Alert';
      case NotificationType.locationAdded:
        return 'Location Added';
      case NotificationType.locationDeleted:
        return 'Location Deleted';
      case NotificationType.artisanAddedToFavorites:
        return 'Artisan Added to Favorites';
      case NotificationType.artisanRemovedFromFavorites:
        return 'Artisan Removed from Favorites';
    }
  }

  String get icon {
    switch (this) {
      case NotificationType.bookingConfirmed:
        return '✓';
      case NotificationType.bookingCancelled:
        return '✕';
      case NotificationType.bookingCompleted:
        return '✓';
      case NotificationType.paymentSuccessful:
        return '💰';
      case NotificationType.paymentFailed:
        return '⚠️';
      case NotificationType.serviceAvailable:
        return '🔔';
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.systemUpdate:
        return 'ℹ️';
      case NotificationType.securityAlert:
        return '🔒';
      case NotificationType.locationAdded:
        return '📍';
      case NotificationType.locationDeleted:
        return '🗑️';
      case NotificationType.artisanAddedToFavorites:
        return '❤️';
      case NotificationType.artisanRemovedFromFavorites:
        return '💔';
    }
  }
}

enum NotificationPriority {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}

enum NotificationStatus {
  unread('unread'),
  read('read'),
  archived('archived');

  const NotificationStatus(this.value);
  final String value;

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.unread,
    );
  }
}

class NotificationStats {
  final int total;
  final int unread;
  final int read;
  final int archived;
  final Map<String, int> byType;
  final Map<String, int> byPriority;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.read,
    required this.archived,
    required this.byType,
    required this.byPriority,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      total: json['total'] ?? 0,
      unread: json['unread'] ?? 0,
      read: json['read'] ?? 0,
      archived: json['archived'] ?? 0,
      byType: Map<String, int>.from(json['byType'] ?? {}),
      byPriority: Map<String, int>.from(json['byPriority'] ?? {}),
    );
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;

  NotificationResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      notifications:
          (json['notifications'] as List<dynamic>?)
              ?.map((item) => NotificationModel.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
