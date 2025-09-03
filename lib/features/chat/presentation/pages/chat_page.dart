import 'package:flutter/material.dart';
import 'dart:math';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> artisan;

  const ChatPage({super.key, required this.artisan});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _typingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add some sample messages
    _addSampleMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _addSampleMessages() {
    final sampleMessages = [
      ChatMessage(
        text:
            "Hi! I saw your service request. I'd be happy to help you with your project.",
        isFromUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        text:
            "Great! Can you tell me more about your experience with this type of work?",
        isFromUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        text:
            "I have over ${widget.artisan['yearsOfExperience'] ?? 5} years of experience in this field. I've completed ${widget.artisan['completedJobs'] ?? 50}+ similar projects.",
        isFromUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        status: MessageStatus.read,
      ),
      ChatMessage(
        text: "That sounds perfect! When would you be available to start?",
        isFromUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        status: MessageStatus.read,
      ),
    ];

    setState(() {
      _messages.addAll(sampleMessages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildChatAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_isTyping) _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2196F3),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.artisan['businessName'] ?? 'Artisan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Online • Typically replies in 5 min',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: Color(0xFF2196F3)),
          onPressed: _callArtisan,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
          onPressed: _showChatOptions,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showAvatar =
            index == _messages.length - 1 ||
            _messages[index + 1].isFromUser != message.isFromUser;
        final showTimestamp =
            index == 0 ||
            _messages[index - 1].timestamp
                    .difference(message.timestamp)
                    .inMinutes >
                5;

        return Column(
          children: [
            if (showTimestamp) _buildTimestamp(message.timestamp),
            _buildMessageBubble(message, showAvatar),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showAvatar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: message.isFromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (!message.isFromUser && showAvatar) _buildAvatar(),
        if (!message.isFromUser && !showAvatar) const SizedBox(width: 48),
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              left: message.isFromUser ? 60 : 8,
              right: message.isFromUser ? 8 : 60,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: message.isFromUser
                  ? const Color(0xFF2196F3)
                  : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(message.isFromUser ? 18 : 4),
                bottomRight: Radius.circular(message.isFromUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: message.isFromUser
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    height: 1.4,
                  ),
                ),
                if (message.isFromUser) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _buildMessageStatusIcon(message.status),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2196F3),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 16),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 12,
          color: Colors.white.withValues(alpha: 0.8),
        );
      case MessageStatus.delivered:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12, color: Colors.white.withValues(alpha: 0.8)),
            Icon(Icons.check, size: 12, color: Colors.white.withValues(alpha: 0.8)),
          ],
        );
      case MessageStatus.read:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, size: 12, color: Colors.lightBlue),
            const Icon(Icons.check, size: 12, color: Colors.lightBlue),
          ],
        );
    }
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (_typingAnimation.value + delay) % 1.0;
                    final opacity = (sin(animationValue * 2 * pi) + 1) / 2;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: 0.3 + (opacity * 0.7),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Color(0xFF2196F3)),
              onPressed: _showAttachmentOptions,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: _onMessageChanged,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMessageChanged(String text) {
    // Simulate typing indicator
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isTyping = false);
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    _scrollToBottom();

    // Simulate message status updates
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateMessageStatus(message, MessageStatus.sent);
    });
    Future.delayed(const Duration(seconds: 1), () {
      _updateMessageStatus(message, MessageStatus.delivered);
    });
    Future.delayed(const Duration(seconds: 2), () {
      _updateMessageStatus(message, MessageStatus.read);
    });

    // Simulate artisan reply
    Future.delayed(const Duration(seconds: 3), () {
      _simulateArtisanReply();
    });
  }

  void _updateMessageStatus(ChatMessage message, MessageStatus status) {
    if (mounted) {
      setState(() {
        message.status = status;
      });
    }
  }

  void _simulateArtisanReply() {
    final replies = [
      "Thanks for your message! I'll get back to you shortly.",
      "Sounds good! Let me prepare a quote for you.",
      "I'm available this week. Would that work for you?",
      "Perfect! I'll send you the details soon.",
      "Great question! Let me check and get back to you.",
    ];

    final reply = ChatMessage(
      text: replies[Random().nextInt(replies.length)],
      isFromUser: false,
      timestamp: DateTime.now(),
      status: MessageStatus.read,
    );

    if (mounted) {
      setState(() {
        _messages.add(reply);
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _callArtisan() {
    // TODO: Implement call functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Calling artisan...')));
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF2196F3)),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate back to profile
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF2196F3)),
              title: const Text('Photo'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.grey),
              title: const Text('Document'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Location'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  MessageStatus status;

  ChatMessage({
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    required this.status,
  });
}

enum MessageStatus { sending, sent, delivered, read }
