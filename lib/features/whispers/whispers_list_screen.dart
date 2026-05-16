import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_icon.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/whispers_models.dart';
import 'data/whispers_providers.dart';

class WhispersListScreen extends ConsumerWidget {
  const WhispersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final chatsAsync = ref.watch(myChatsProvider);
    final requestsAsync = ref.watch(incomingWhispersProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _Header(),
              Expanded(
                child: RefreshIndicator(
                  color: qurb.accent,
                  backgroundColor: qurb.surface,
                  onRefresh: () async {
                    ref.invalidate(myChatsProvider);
                    ref.invalidate(incomingWhispersProvider);
                    await Future.wait([
                      ref.read(myChatsProvider.future),
                      ref.read(incomingWhispersProvider.future),
                    ]);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                    children: [
                      requestsAsync.maybeWhen(
                        data: (reqs) => reqs.isEmpty
                            ? const SizedBox.shrink()
                            : _IncomingRequestsSection(requests: reqs),
                        orElse: () => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 4),
                      chatsAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (e, _) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'تعذّر تحميل الهمسات',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: qurb.danger),
                          ),
                        ),
                        data: (chats) => chats.isEmpty
                            ? _EmptyChats()
                            : Column(
                                children: [
                                  for (final c in chats)
                                    _ChatRow(thread: c),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.inbox,
              onChange: (tab) {
                switch (tab) {
                  case NavTab.feed:
                    context.go('/home');
                    break;
                  case NavTab.post:
                    context.push('/compose');
                    break;
                  case NavTab.search:
                    context.push('/explore');
                    break;
                  case NavTab.me:
                    context.push('/profile');
                    break;
                  default:
                    break;
                }
              },
              hasUnread: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            top: media.padding.top + 6, bottom: 12,
          ),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              bottom: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QurbIconWidget(QIcon.whisper, size: 20, color: qurb.accent),
                const SizedBox(width: 8),
                Text(
                  'همس',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: qurb.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncomingRequestsSection extends StatelessWidget {
  const _IncomingRequestsSection({required this.requests});
  final List<IncomingWhisper> requests;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 10),
          child: Row(
            children: [
              Text(
                'طلبات هَمس',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: qurb.textFaint,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: qurb.accentSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${requests.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: qurb.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        for (final r in requests) _IncomingRequestCard(request: r),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _IncomingRequestCard extends ConsumerStatefulWidget {
  const _IncomingRequestCard({required this.request});
  final IncomingWhisper request;
  @override
  ConsumerState<_IncomingRequestCard> createState() =>
      _IncomingRequestCardState();
}

class _IncomingRequestCardState extends ConsumerState<_IncomingRequestCard> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final chatId = await ref
          .read(whispersRepositoryProvider)
          .respondToRequest(requestId: widget.request.id, accept: accept);
      ref.invalidate(incomingWhispersProvider);
      ref.invalidate(myChatsProvider);
      if (accept && chatId != null && mounted) {
        context.push('/whispers/$chatId');
      }
    } catch (_) {
      // ignore — list will refresh on next pull
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    final r = widget.request;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IdBadge(id: r.fromNumericId.toString(), shape: shape),
              const SizedBox(width: 8),
              Text(
                relMinutes(
                  DateTime.now().difference(r.createdAt).inMinutes,
                ),
                style: TextStyle(fontSize: 11, color: qurb.textFaint),
              ),
            ],
          ),
          if (r.message != null && r.message!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              r.message!,
              style: TextStyle(fontSize: 14, color: qurb.text, height: 1.6),
            ),
          ],
          if (r.postPreview != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: qurb.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                r.postPreview!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12, color: qurb.textDim, height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _respond(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: qurb.border),
                    foregroundColor: qurb.textDim,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy ? null : () => _respond(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: qurb.accent,
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFFFFF)),
                          ),
                        )
                      : const Text('قبول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatRow extends ConsumerWidget {
  const _ChatRow({required this.thread});
  final ChatThread thread;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    final time = thread.lastMessageAt ?? thread.createdAt;
    return GestureDetector(
      onTap: () => context.push('/whispers/${thread.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: qurb.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: qurb.border, width: 0.5),
        ),
        child: Row(
          children: [
            IdBadge(
              id: thread.otherNumericId.toString(),
              shape: shape,
              size: IdBadgeSize.lg,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'همس · #${thread.otherNumericId}',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: qurb.text,
                          ),
                        ),
                      ),
                      Text(
                        relMinutes(
                          DateTime.now().difference(time).inMinutes,
                        ),
                        style: TextStyle(
                          fontSize: 10.5, color: qurb.textFaint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          thread.lastMessagePreview ?? 'لا رسائل بعد',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: thread.unreadCount > 0
                                ? qurb.text
                                : qurb.textDim,
                            fontWeight: thread.unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (thread.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: qurb.accent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 20),
                          child: Text(
                            '${thread.unreadCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.w700,
                              fontFeatures: [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: qurb.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: QurbIconWidget(
                QIcon.whisper, size: 28, color: qurb.accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا همسات بعد',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: qurb.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اضغط "همس للناشر" تحت أي منشور لبدء محادثة خاصة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12, color: qurb.textDim, height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
