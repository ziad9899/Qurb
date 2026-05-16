import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_providers.dart';
import '../../core/prefs/prefs_providers.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../l10n/generated/app_localizations.dart';
import '../profile/data/profile_providers.dart';
import '../showcase/design_showcase_screen.dart' show idShapeProvider;

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final mode = ref.watch(appThemeModeProvider);
    final profileAsync = ref.watch(myProfileProvider);
    final blocksAsync = ref.watch(myBlocksProvider);
    final shape = ref.watch(idShapeProvider);

    final locationShare = ref.watch(locationShareProvider);
    final allowStrangers = ref.watch(allowStrangersProvider);
    final readReceipts = ref.watch(readReceiptsProvider);
    final allNotifs = ref.watch(allNotifsProvider);
    final pulseNotifs = ref.watch(pulseNotifsProvider);
    final locale = ref.watch(localeProvider);
    final isArabic = (locale?.languageCode ?? 'ar') == 'ar';

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Column(
        children: [
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(
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
                  t.settings_header,
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
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 50),
              children: [
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
                                      t.settings_identity_title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: qurb.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.settings_identity_subtitle,
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

                _GroupLabel(text: t.settings_group_privacy),
                _Group(children: [
                  _Row(
                    icon: QIcon.pin,
                    label: t.settings_row_locationShare,
                    detail: t.settings_row_locationShare_detail,
                    toggle: locationShare,
                    onToggle: (v) =>
                        ref.read(locationShareProvider.notifier).set(v),
                  ),
                  _Row(
                    icon: QIcon.whisper,
                    label: t.settings_row_allowStrangers,
                    toggle: allowStrangers,
                    onToggle: (v) =>
                        ref.read(allowStrangersProvider.notifier).set(v),
                  ),
                  _Row(
                    icon: QIcon.eye,
                    label: t.settings_row_readReceipts,
                    toggle: readReceipts,
                    onToggle: (v) =>
                        ref.read(readReceiptsProvider.notifier).set(v),
                  ),
                  _Row(
                    icon: QIcon.lock,
                    label: t.settings_row_blocklist,
                    detail: blocksAsync.maybeWhen(
                      data: (b) => b.isEmpty
                          ? t.settings_row_blocklist_empty
                          : t.settings_row_blocklist_count(b.length),
                      orElse: () => '...',
                    ),
                    onTap: () => GoRouter.of(context).push('/settings/blocks'),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                _GroupLabel(text: t.settings_group_appearance),
                _Group(children: [
                  _Row(
                    icon: mode == ThemeMode.dark ? QIcon.moon : QIcon.sun,
                    label: t.settings_row_nightMode,
                    toggle: mode == ThemeMode.dark,
                    onToggle: (v) {
                      ref.read(appThemeModeProvider.notifier).setMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                _GroupLabel(text: t.settings_group_notifs),
                _Group(children: [
                  _Row(
                    icon: QIcon.bell,
                    label: t.settings_row_allNotifs,
                    toggle: allNotifs,
                    onToggle: (v) =>
                        ref.read(allNotifsProvider.notifier).set(v),
                  ),
                  _Row(
                    icon: QIcon.flame,
                    label: t.settings_row_pulseNotifs,
                    detail: t.settings_row_pulseNotifs_detail,
                    toggle: pulseNotifs,
                    onToggle: (v) =>
                        ref.read(pulseNotifsProvider.notifier).set(v),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                _GroupLabel(text: t.settings_group_about),
                _Group(children: [
                  _Row(
                    icon: QIcon.shield,
                    label: t.settings_row_community,
                    onTap: () =>
                        GoRouter.of(context).push('/settings/community'),
                  ),
                  _Row(
                    icon: QIcon.globe,
                    label: t.settings_row_language,
                    detail: isArabic
                        ? t.settings_lang_arabic
                        : t.settings_lang_english,
                    onTap: () => _showLanguageSheet(context, ref),
                  ),
                  _Row(
                    icon: QIcon.lock,
                    label: t.privacy_title,
                    onTap: () =>
                        GoRouter.of(context).push('/settings/privacy'),
                  ),
                  _Row(
                    icon: QIcon.flag,
                    label: t.settings_row_report,
                    onTap: () =>
                        GoRouter.of(context).push('/settings/report'),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 18),

                _Group(children: [
                  _Row(
                    icon: QIcon.close,
                    label: t.settings_row_signout,
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
                    label: t.settings_row_delete,
                    danger: true,
                    onTap: () => _confirmDelete(context, ref, t),
                    last: true,
                  ),
                ]),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    t.settings_version,
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

  Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
    final qurb = context.qurb;
    final t = AppLocalizations.of(context);
    final current = ref.read(localeProvider)?.languageCode ?? 'ar';
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                Text(
                  t.settings_lang_sheet_title,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: qurb.text,
                  ),
                ),
                const SizedBox(height: 10),
                _LangChoice(
                  label: t.settings_lang_arabic,
                  selected: current == 'ar',
                  onTap: () async {
                    await ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('ar'));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                _LangChoice(
                  label: t.settings_lang_english,
                  selected: current == 'en',
                  last: true,
                  onTap: () async {
                    await ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en'));
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations t,
  ) async {
    final qurb = context.qurb;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: qurb.surface,
        title: Text(t.settings_delete_title, style: TextStyle(color: qurb.text)),
        content: Text(
          t.settings_delete_body,
          style: TextStyle(color: qurb.textDim, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.common_cancel, style: TextStyle(color: qurb.textDim)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.common_delete, style: TextStyle(color: qurb.danger)),
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

class _LangChoice extends StatelessWidget {
  const _LangChoice({
    required this.label,
    required this.selected,
    required this.onTap,
    this.last = false,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
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
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: qurb.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (selected)
              QurbIconWidget(QIcon.check, size: 16, color: qurb.accent),
          ],
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 8),
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
                      style: TextStyle(fontSize: 11, color: qurb.textFaint),
                    ),
                  ],
                ],
              ),
            ),
            if (toggle != null)
              _Toggle(value: toggle!, onChange: onToggle ?? (_) {})
            else if (onTap != null)
              QurbIconWidget(
                QIcon.chevron, size: 15, color: qurb.textFaint,
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
          alignment:
              value ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
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
