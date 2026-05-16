import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/mock_data.dart';
import '../../core/theme/qurb_theme.dart';
import '../../core/util/relative_time.dart';
import '../../core/widgets/id_badge.dart';
import '../../core/widgets/proximity_chip.dart';
import '../../core/widgets/qurb_bottom_nav.dart';
import '../../core/widgets/qurb_card.dart';
import '../../core/widgets/qurb_icon.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/vote_pill.dart';

/// Theme mode controller — wired to the AppBar toggle so we can switch
/// dark/light at runtime, matching the Tweaks panel from the web design.
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// ID-badge shape controller — picks the visual treatment from Tweaks.
final idShapeProvider =
    StateProvider<IdBadgeShape>((ref) => IdBadgeShape.pill);

class DesignShowcaseScreen extends ConsumerWidget {
  const DesignShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qurb = context.qurb;
    final shape = ref.watch(idShapeProvider);
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: qurb.bg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BrandHeader(
                    mode: mode,
                    onToggleMode: () => ref.read(themeModeProvider.notifier).state =
                        mode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark,
                  ),
                  const SizedBox(height: 22),
                  const _Section(title: 'الألوان', child: _Palette()),
                  const SizedBox(height: 26),
                  _Section(
                    title: 'المعرفات · 8 ألوان مولّدة من رقم المعرف',
                    child: _BadgesGrid(shape: shape),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'شكل المعرف (Tweak)',
                    child: _ShapePicker(
                      shape: shape,
                      onChange: (s) =>
                          ref.read(idShapeProvider.notifier).state = s,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _Section(
                    title: 'السلم الطباعي · IBM Plex Sans Arabic',
                    child: _TypeScale(),
                  ),
                  const SizedBox(height: 26),
                  const _Section(
                    title: 'شارات القرب',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ProximityChip(kind: Proximity.near),
                        ProximityChip(kind: Proximity.block),
                        ProximityChip(kind: Proximity.city),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _Section(
                    title: 'التصويت',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _VoteDemo(initial: null),
                        _VoteDemo(initial: VoteValue.up),
                        _VoteDemo(initial: VoteValue.down),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  _Section(
                    title: 'بطاقة منشور',
                    child: _SamplePost(shape: shape),
                  ),
                  const SizedBox(height: 26),
                  const _Section(
                    title: 'هياكل التحميل',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Skel(width: double.infinity, height: 14),
                        SizedBox(height: 8),
                        Skel(width: 220, height: 14),
                        SizedBox(height: 12),
                        Skel(width: double.infinity, height: 180, radius: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: QurbBottomNav(
              active: NavTab.feed,
              onChange: (_) {},
              hasUnread: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.mode, required this.onToggleMode});
  final ThemeMode mode;
  final VoidCallback onToggleMode;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'قُرب',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: qurb.text,
            height: 1.0,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: qurb.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'نظام التصميم · v0.1',
          style: TextStyle(fontSize: 11, color: qurb.textDim, letterSpacing: 1.5),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onToggleMode,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: qurb.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: qurb.border, width: 0.5),
            ),
            child: Center(
              child: QurbIconWidget(
                mode == ThemeMode.dark ? QIcon.sun : QIcon.moon,
                size: 18,
                color: qurb.text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: qurb.textFaint,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette();
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final swatches = <(String, Color)>[
      ('Background', qurb.bg),
      ('Surface', qurb.surface),
      ('Surface 2', qurb.surface2),
      ('Accent', qurb.accent),
      ('Gold', qurb.gold),
      ('Up', qurb.up),
      ('Danger', qurb.danger),
      ('Text', qurb.text),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        for (final (name, color) in swatches)
          Container(
            decoration: BoxDecoration(
              color: qurb.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: qurb.border, width: 0.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: Container(color: color)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: qurb.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BadgesGrid extends StatelessWidget {
  const _BadgesGrid({required this.shape});
  final IdBadgeShape shape;
  @override
  Widget build(BuildContext context) {
    const ids = [
      '45821', '77103', '32940', '91206',
      '58471', '12048', '83712', '67890',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final id in ids) IdBadge(id: id, shape: shape)],
    );
  }
}

class _ShapePicker extends StatelessWidget {
  const _ShapePicker({required this.shape, required this.onChange});
  final IdBadgeShape shape;
  final ValueChanged<IdBadgeShape> onChange;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    const labels = {
      IdBadgeShape.pill: 'Pill',
      IdBadgeShape.chip: 'Chip',
      IdBadgeShape.dot: 'Dot',
      IdBadgeShape.ring: 'Ring',
      IdBadgeShape.square: 'Square',
    };
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final entry in labels.entries)
          GestureDetector(
            onTap: () => onChange(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: entry.key == shape ? qurb.text : qurb.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: qurb.border, width: 0.5),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: entry.key == shape ? qurb.bg : qurb.textDim,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final entries = <(String, double, FontWeight, String)>[
      ('Display / 32 · 700', 32, FontWeight.w700, 'مجتمعك بدون اسم'),
      ('Title / 24 · 700', 24, FontWeight.w700, 'الترند المحلي'),
      ('Heading / 18 · 600', 18, FontWeight.w600, 'منشور جديد'),
      ('Body / 15 · 500', 15, FontWeight.w500,
          'نص المنشور هنا — يجب أن يكون مريحاً للقراءة في الجوال.'),
      ('Caption / 11 · 600', 11, FontWeight.w600, 'الخصوصية'),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: qurb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: qurb.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, size, weight, sample) in entries) ...[
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: qurb.textFaint,
                    fontFamily: 'monospace')),
            const SizedBox(height: 4),
            Text(sample,
                style: TextStyle(
                    fontSize: size,
                    fontWeight: weight,
                    color: qurb.text,
                    height: 1.4,
                    letterSpacing: size > 20 ? -0.4 : 0)),
            const SizedBox(height: 12),
            Container(height: 0.5, color: qurb.border),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _VoteDemo extends StatefulWidget {
  const _VoteDemo({required this.initial});
  final VoteValue? initial;
  @override
  State<_VoteDemo> createState() => _VoteDemoState();
}

class _VoteDemoState extends State<_VoteDemo> {
  late VoteValue? _v = widget.initial;
  @override
  Widget build(BuildContext context) {
    return VotePill(
      score: 120,
      vote: _v,
      onVote: (v) => setState(() => _v = v),
    );
  }
}

class _SamplePost extends StatefulWidget {
  const _SamplePost({required this.shape});
  final IdBadgeShape shape;
  @override
  State<_SamplePost> createState() => _SamplePostState();
}

class _SamplePostState extends State<_SamplePost> {
  VoteValue? _vote;
  @override
  Widget build(BuildContext context) {
    final qurb = context.qurb;
    final post = kMockPosts.first;
    return QurbCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IdBadge(id: post.uid, shape: widget.shape),
              const SizedBox(width: 8),
              ProximityChip(kind: post.proximity),
              const SizedBox(width: 6),
              Text('·',
                  style: TextStyle(fontSize: 11, color: qurb.textFaint)),
              const SizedBox(width: 6),
              Text(relMinutes(post.minutesAgo),
                  style: TextStyle(fontSize: 11, color: qurb.textFaint)),
              const Spacer(),
              QurbIconWidget(QIcon.more, size: 18, color: qurb.textFaint),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            post.body,
            style: TextStyle(
                fontSize: 14.5,
                color: qurb.text,
                height: 1.75),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              VotePill(
                score: post.score,
                vote: _vote,
                onVote: (v) => setState(() => _vote = v),
              ),
              const SizedBox(width: 10),
              Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: qurb.surface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: qurb.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    QurbIconWidget(QIcon.reply,
                        size: 13, color: qurb.textDim),
                    const SizedBox(width: 5),
                    Text(
                      '${post.comments}',
                      style: TextStyle(
                        fontSize: 12,
                        color: qurb.textDim,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: qurb.goldSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '#${post.tag}',
                  style: TextStyle(
                      fontSize: 10,
                      color: qurb.gold,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
