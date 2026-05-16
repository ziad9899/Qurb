import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_empty.dart';
import '../../core/widgets/qurb_error.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../l10n/generated/app_localizations.dart';
import '../feed/report_sheet.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;
import 'data/whispers_models.dart';
import 'data/whispers_providers.dart';

/// One-to-one chat. Loads via REST, then layers realtime INSERTs on top.
class WhisperThreadScreen extends ConsumerStatefulWidget {
  const WhisperThreadScreen({super.key, required this.chatId});
  final int chatId;
  @override
  ConsumerState<WhisperThreadScreen> createState() =>
      _WhisperThreadScreenState();
}

class _WhisperThreadScreenState
    extends ConsumerState<WhisperThreadScreen> {
  final _composer = TextEditingController();
  final _scrollC = ScrollController();
  final List<ChatMessage> _liveAdded = [];
  RealtimeChannel? _channel;
  bool _sending = false;
  int? _otherNumericId;

  @override
  void initState() {
    super.initState();
    _resolveCounterpart();
    _subscribe();
  }

  Future<void> _resolveCounterpart() async {
    // Pull from the chats list (which has other_numeric_id via the view).
    try {
      final chats = await ref
          .read(whispersRepositoryProvider)
          .listMyChats();
      final match = chats.where((c) => c.id == widget.chatId);
      if (match.isNotEmpty && mounted) {
        setState(() => _otherNumericId = match.first.otherNumericId);
      }
    } catch (_) {/* ignore */}
  }

  void _subscribe() {
    final repo = ref.read(whispersRepositoryProvider);
    _channel = repo.subscribeToChat(
      chatId: widget.chatId,
      onMessage: (m) {
        if (!mounted) return;
        setState(() => _liveAdded.add(m));
        _scrollToBottomSoon();
      },
    );
    // mark-read on open; ignored if unsupported
    repo.markRead(widget.chatId);
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _composer.dispose();
    _scrollC.dispose();
    super.dispose();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollC.hasClients) return;
      _scrollC.animateTo(
        _scrollC.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    HapticFeedback.lightImpact();
    setState(() => _sending = true);
    final repo = ref.read(whispersRepositoryProvider);
    final ph = ChatMessage(
      id: -DateTime.now().microsecondsSinceEpoch,
      chatId: widget.chatId,
      body: body,
      isMine: true,
      createdAt: DateTime.now(),
    );
    setState(() {
      _liveAdded.add(ph);
      _composer.clear();
    });
    _scrollToBottomSoon();
    try {
      final realId = await repo.sendMessage(
        chatId: widget.chatId, body: body,
      );
      if (!mounted) return;
      // replace placeholder with real id
      setState(() {
        final idx = _liveAdded.indexWhere((m) => m.id == ph.id);
        if (idx >= 0) {
          _liveAdded[idx] = ChatMessage(
            id: realId,
            chatId: ph.chatId,
            body: ph.body,
            isMine: true,
            createdAt: ph.createdAt,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _liveAdded.removeWhere((m) => m.id == ph.id));
      HapticFeedback.heavyImpact();
      final t = AppLocalizations.of(context);
      final msg = e.toString();
      String reason = t.thread_err_generic;
      if (msg.contains('moderation_violation')) {
        reason = t.thread_err_moderation;
      } else if (msg.contains('rate_limit_messages_per_minute')) {
        reason = t.thread_err_rateLimit;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(reason), duration: const Duration(seconds: 3)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  List<ChatMessage> _merge(List<ChatMessage> initial) {
    // dedupe: live additions may overlap with initial REST list
    final byId = <int, ChatMessage>{};
    for (final m in initial) {
      byId[m.id] = m;
    }
    for (final m in _liveAdded) {
      byId[m.id] = m;
    }
    final result = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    final shape = ref.watch(idShapeProvider);
    final initial =
        ref.watch(chatMessagesInitialProvider(widget.chatId));

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          Column(
            children: [
              _ThreadHeader(
                numericId: _otherNumericId,
                shape: shape,
              ),
              Expanded(
                child: initial.when(
                  loading: () => const SkelList(count: 4),
                  error: (e, _) => QurbError(
                    title: AppLocalizations.of(context).thread_error_title,
                    onRetry: () => ref.invalidate(
                      chatMessagesInitialProvider(widget.chatId),
                    ),
                  ),
                  data: (initialMessages) {
                    final merged = _merge(initialMessages);
                    if (merged.isEmpty) {
                      final t = AppLocalizations.of(context);
                      return QurbEmpty(
                        icon: QIcon.whisper,
                        title: t.thread_empty_title,
                        subtitle: t.thread_empty_subtitle,
                      );
                    }
                    return ListView.builder(
                      controller: _scrollC,
                      padding: EdgeInsets.fromLTRB(
                        14, 14, 14, 110 + media.padding.bottom,
                      ),
                      itemCount: merged.length,
                      itemBuilder: (_, i) => _MessageBubble(
                        message: merged[i],
                        showTimestamp: _showTimestampFor(merged, i),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _ComposeBar(
              controller: _composer,
              busy: _sending,
              onSend: _send,
            ),
          ),
        ],
      ),
    );
  }

  bool _showTimestampFor(List<ChatMessage> all, int i) {
    if (i == 0) return true;
    final prev = all[i - 1];
    final cur = all[i];
    return cur.createdAt.difference(prev.createdAt).inMinutes >= 10;
  }
}

class _ThreadHeader extends ConsumerWidget {
  const _ThreadHeader({required this.numericId, required this.shape});
  final int? numericId;
  final IdBadgeShape shape;

  void _openMenu(BuildContext context, WidgetRef ref) {
    if (numericId == null) return;
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: qurb.bgElev,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: qurb.borderStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                _ThreadMenuItem(
                  icon: QIcon.flag,
                  label: t.thread_menu_report_user,
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    await ReportSheet.show(
                      context,
                      targetType: 'user',
                      targetId: numericId!,
                    );
                  },
                ),
                _ThreadMenuItem(
                  icon: QIcon.block,
                  label: t.thread_menu_block_user,
                  color: qurb.danger,
                  last: true,
                  onTap: () async {
                    Navigator.of(sheetCtx).pop();
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: qurb.surface,
                        title: Text(
                          t.post_block_title(numericId.toString()),
                          style: TextStyle(color: qurb.text),
                        ),
                        content: Text(
                          t.post_block_body,
                          style: TextStyle(
                              color: qurb.textDim, height: 1.6),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false),
                            child: Text(t.common_cancel,
                                style: TextStyle(color: qurb.textDim)),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            child: Text(t.post_block_action,
                                style: TextStyle(color: qurb.danger)),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    try {
                      await ref
                          .read(profileRepositoryProvider)
                          .blockUserByNumericId(numericId!);
                      ref.invalidate(myBlocksProvider);
                      if (context.mounted) Navigator.of(context).pop();
                    } catch (_) {/* swallow — UI already returned */}
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(8, media.padding.top + 6, 14, 12),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              bottom: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QurbIconWidget(
                    QIcon.chevron, size: 22, color: qurb.text,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (numericId != null)
                IdBadge(id: numericId.toString(), shape: shape)
              else
                Container(
                  width: 60, height: 22,
                  decoration: BoxDecoration(
                    color: qurb.surface2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  numericId != null
                      ? AppLocalizations.of(context)
                          .whispers_label_with_id(numericId.toString())
                      : AppLocalizations.of(context).thread_header_fallback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _openMenu(context, ref),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: QurbIconWidget(
                    QIcon.more, size: 20, color: qurb.textDim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadMenuItem extends StatelessWidget {
  const _ThreadMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.last = false,
  });
  final QIcon icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool last;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: qurb.border, width: 0.5)),
        ),
        child: Row(
          children: [
            QurbIconWidget(icon, size: 18, color: color ?? qurb.text),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color ?? qurb.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.message,
    required this.showTimestamp,
  });
  final ChatMessage message;
  final bool showTimestamp;
  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final message = widget.message;
    final showTimestamp = widget.showTimestamp;
    final isMine = message.isMine;
    final color = isMine ? qurb.accent : qurb.surface;
    final textColor = isMine ? const Color(0xFFFFFFFF) : qurb.text;
    return FadeTransition(
      opacity: _c,
      child: SlideTransition(
        position: _slide,
        child: _bubble(
          context,
          showTimestamp: showTimestamp,
          isMine: isMine,
          color: color,
          textColor: textColor,
          message: message,
          qurb: qurb,
        ),
      ),
    );
  }

  Widget _bubble(
    BuildContext context, {
    required bool showTimestamp,
    required bool isMine,
    required Color color,
    required Color textColor,
    required ChatMessage message,
    required dynamic qurb,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTimestamp)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                relMinutes(
                  DateTime.now().difference(message.createdAt).inMinutes,
                ),
                style: TextStyle(
                  fontSize: 10.5,
                  color: qurb.textFaint,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        Align(
          alignment: isMine ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 9,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMine
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
                bottomRight: isMine
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
              ),
              border: isMine
                  ? null
                  : Border.all(color: qurb.border, width: 0.5),
            ),
            child: Text(
              message.body,
              style: TextStyle(
                fontSize: 14, color: textColor, height: 1.55,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ComposeBar extends StatelessWidget {
  const _ComposeBar({
    required this.controller,
    required this.busy,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            14, 12, 14, 16 + media.padding.bottom,
          ),
          decoration: BoxDecoration(
            color: qurb.glass,
            border: Border(
              top: BorderSide(color: qurb.border, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: qurb.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: qurb.border, width: 0.5),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => onSend(),
                    style: TextStyle(
                      fontSize: 14, color: qurb.text, height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).thread_hint,
                      hintStyle: TextStyle(
                        fontSize: 14, color: qurb.textFaint,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: busy ? null : onSend,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: qurb.accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: qurb.accent.withValues(alpha: 0.33),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: busy
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFFFFFF)),
                          ),
                        )
                      : Transform.flip(
                          flipX: true,
                          child: const Center(
                            child: QurbIconWidget(
                              QIcon.send,
                              size: 17,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

