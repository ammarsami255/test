import 'package:flutter/material.dart';
import 'package:el_moza3/Constants.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  static final List<Map<String, dynamic>> _chats = [
    {
      "name": "مكتب المحاسبة المعتمد",
      "last": "شكراً، هنتواصل معاك قريباً",
      "time": "10:30",
      "unread": 2,
      "icon": Icons.account_balance,
      "color": Colors.blue,
    },
    {
      "name": "ورشة الحدادة",
      "last": "إيه السعر للطلبية؟",
      "time": "أمس",
      "unread": 0,
      "icon": Icons.hardware,
      "color": Colors.brown,
    },
    {
      "name": "شركة الشحن الداخلي",
      "last": "متاح من بكرة إن شاء الله",
      "time": "أمس",
      "unread": 1,
      "icon": Icons.local_shipping,
      "color": Colors.red,
    },
    {
      "name": "مقاول التشطيبات",
      "last": "تم إرسال العرض",
      "time": "السبت",
      "unread": 0,
      "icon": Icons.home_repair_service,
      "color": Colors.teal,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: const Text(
                "الرسائل",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _chats.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _ChatTile(chat: chat);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;

  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    final color = chat["color"] as Color;
    final unread = chat["unread"] as int;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(chat["icon"] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat["name"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      chat["time"]!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        chat["last"]!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread > 0)
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "$unread",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
