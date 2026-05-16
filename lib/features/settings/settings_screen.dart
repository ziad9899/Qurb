import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_icon.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart'
    show themeModeProvider, idShapeProvider;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _locationShare = true;
  bool _allowWhisperStrangers = true;
  bool _readReceipts = false;
  bool _allNotifs = true;
  bool _pulseNotifs = true;

  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final media = MediaQuery.of(context);
    final mode = ref.watch(themeModeProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final blocksAsync = ref.watch(myBlocksProvider);
    final shape = ref.watch(idShapeProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.fromLTRB(
              8, media.padding.top + 6, 8, 8,
            ),
            decoration: BoxDecoration(
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
                const Spacer(),
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 36),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 50),
              children: [
                // identity card
                profileAsync.maybeWhen(
                  data: (p) => p == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: qurb.surface,
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: qurb.border, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              IdBadge(
                                id: p.numericId.toString(),
                                shape: shape,
                                size: IdBadgeSize.lg,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'هذا هو معرفك الدائم',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: qurb.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'لا يمكن تغييره. لا يحتوي على معلومات شخصية.',
                                      style: TextStyle(
                                        fontSize: 11, color: qurb.textFaint,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
                const SizedBox(height: 18),

                const _GroupLabel(text: 'الخصوصية'),
                _Group(children: [
                  _Row(
                    icon: QIcon.pin,
                    label: 'مشاركة الموقع',
                    detail: 'ضرورية لإظهار المنشورات القريبة',
                    toggle: _locationShare,
                    onToggle: (v) =>
                        setState(() => _locationShare = v),
                  ),
                  _Row(
                    icon: QIcon.whisper,
                    label: 'السماح بهمس من الغرباء',
                    toggle: _allowWhisperStrangers,
                    onToggle: (v) =>
                        setState(() => _allowWhisperStrangers = v),
                  ),
                  _Row(
                    icon: QIcon.eye,
                    label: 'إيصالات القراءة',
                    toggle: _readReceipts,
                    onToggle: (v) =>
                        setState(() => _readReceipts = v),
                  ),
                  _Row(
                    icon: QIcon.lock,
                    label: 'قائمة الحظر',
                    detail: blocksAsync.maybeWhen(
                      data: (b) => b.isEmpty
                          ? 'لا أحد محظور'
                          : '${b.length} معرف محظور',
                      orElse: () => '...',
                    ),
                    onTap: () => GoRouter.of(context).push('/settings/blocks'),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                const _GroupLabel(text: 'المظهر'),
                _Group(children: [
                  _Row(
                    icon: mode == ThemeMode.dark
                        ? QIcon.moon
                        : QIcon.sun,
                    label: 'الوضع الليلي',
                    toggle: mode == ThemeMode.dark,
                    onToggle: (v) {
                      ref.read(themeModeProvider.notifier).state =
                          v ? ThemeMode.dark : ThemeMode.light;
                    },
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                const _GroupLabel(text: 'الإشعارات'),
                _Group(children: [
                  _Row(
                    icon: QIcon.bell,
                    label: 'جميع الإشعارات',
                    toggle: _allNotifs,
                    onToggle: (v) => setState(() => _allNotifs = v),
                  ),
                  _Row(
                    icon: QIcon.flame,
                    label: 'نبض المنطقة',
                    detail: 'إشعار عند نشاط مرتفع في حيك',
                    toggle: _pulseNotifs,
                    onToggle: (v) => setState(() => _pulseNotifs = v),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                const _GroupLabel(text: 'عن قُرب'),
                const _Group(children: [
                  _Row(icon: QIcon.shield, label: 'معايير المجتمع'),
                  _Row(icon: QIcon.globe, label: 'اللغة', detail: 'العربية'),
                  _Row(
                    icon: QIcon.flag,
                    label: 'الإبلاغ عن مشكلة',
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                _Group(children: [
                  _Row(
                    icon: QIcon.close,
                    label: 'تسجيل الخروج',
                    onTap: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      if (context.mounted) {
                        GoRouter.of(context).go('/welcome');
                      }
                    },
                    last: true,
                  ),
                ]),
                const SizedBox(height: 14),
                _Group(children: [
                  _Row(
                    icon: QIcon.close,
                    label: 'حذف معرفي وكل بياناتي',
                    danger: true,
                    onTap: () => _confirmDelete(context, ref),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'QURB · v0.1.0 (build 1)',
                    style: TextStyle(
                      fontSize: 10.5, color: qurb.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final qurb = context.qurb;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: qurb.surface,
        title: Text(
          'حذف الحساب نهائياً؟',
          style: TextStyle(color: qurb.text),
        ),
        content: Text(
          'سيُحذف معرفك وكل منشوراتك وتعليقاتك ومحادثاتك. '
          'لا يمكن التراجع.',
          style: TextStyle(color: qurb.textDim, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: TextStyle(color: qurb.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('حذف', style: TextStyle(color: qurb.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(profileRepositoryProvider).deleteMyAccount();
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) GoRouter.of(context).go('/welcome');
    } catch (_) {/* ignore */}
  }
}

// ─── building blocks ──────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: qurb.textFaint,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Container(
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.detail,
    this.toggle,
    this.onToggle,
    this.onTap,
    this.last = false,
    this.danger = false,
  });
  final QIcon icon;
  final String label;
  final String? detail;
  final bool? toggle;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;
  final bool last;
  final bool danger;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final color = danger ? qurb.danger : qurb.text;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: qurb.border, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: danger
                    ? qurb.danger.withValues(alpha: 0.12)
                    : qurb.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: QurbIconWidget(icon, size: 16, color: color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14, color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      detail!,
                      style: TextStyle(
                        fontSize: 11, color: qurb.textFaint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (toggle != null)
              _Toggle(value: toggle!, onChange: onToggle ?? (_) {})
            else
              Transform.flip(
                flipX: true,
                child: QurbIconWidget(
                  QIcon.chevron, size: 15, color: qurb.textFaint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.onChange});
  final bool value;
  final ValueChanged<bool> onChange;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44, height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? qurb.accent : qurb.surface2,
          borderRadius: BorderRadius.circular(13),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Color(0x33000000), blurRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
