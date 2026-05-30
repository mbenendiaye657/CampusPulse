import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Panel de notifications qui s'affiche en overlay
class NotificationPanel extends StatefulWidget {
  final VoidCallback onClose;
  const NotificationPanel({super.key, required this.onClose});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  final _service = NotificationService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NotificationItem>>(
      stream: _service.stream,
      initialData: const [],
      builder: (context, snapshot) {
        final notifs = snapshot.data ?? [];
        final unread = notifs.where((n) => !n.isRead).length;

        return Container(
          margin: const EdgeInsets.only(top: 8, right: 12, left: 40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A6B),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(children: [
                  const Icon(Icons.notifications,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text('Notifications',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const Spacer(),
                  if (unread > 0) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          debugPrint("Action: Tout lire");
                          _service.markAllRead();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2DAB6F),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text('Tout lire ($unread)',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: widget.onClose,
                    child: const Icon(Icons.close,
                        color: Colors.white70, size: 18),
                  ),
                ]),
              ),

              // ── Liste ────────────────────────────────────
              if (notifs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(children: [
                    Icon(Icons.notifications_none,
                        size: 36, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Aucune notification',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ]),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade100),
                    itemBuilder: (_, i) => _NotifTile(
                      notif: notifs[i],
                      onTap: () {
                        debugPrint("Action: Lire notification ${notifs[i].id}");
                        _service.markAsRead(notifs[i].id);
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 6),
            ],
          ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationItem notif;
  final VoidCallback onTap;
  const _NotifTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // IMPORTANT : Opaque permet de cliquer même dans le "vide" entre les textes
        behavior: HitTestBehavior.opaque,
        onTap: () {
          debugPrint("--- CLIC DETECTE SUR : ${notif.title} ---");
          onTap();
        },
        child: Container(
          // On met une couleur de fond (même très légère) pour que le clic "accroche"
          color: isUnread
              ? const Color(0xFF1A3A6B).withOpacity(0.05)
              : Colors.white.withOpacity(0.01),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partie Icône
              Stack(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A6B).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isUnread
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      size: 18,
                      color: const Color(0xFF1A3A6B),
                    ),
                  ),
                  if (isUnread)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Partie Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.normal,
                        color: const Color(0xFF1A3A6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
