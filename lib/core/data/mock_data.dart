import 'package:equatable/equatable.dart';

/// Mock data used across screens during Phase 1–7. Replaced by Supabase
/// queries in Phase 8. Mirrors MOCK_POSTS / MOCK_TRENDS in the web design
/// (same ids, same hues, same plausible timelines).

enum Proximity { near, block, city }

class MockPost extends Equatable {
  const MockPost({
    required this.id,
    required this.uid,
    required this.minutesAgo,
    required this.proximity,
    required this.score,
    required this.comments,
    required this.body,
    required this.tag,
    this.hasImage = false,
  });

  final String id;
  final String uid;
  final int minutesAgo;
  final Proximity proximity;
  final int score;
  final int comments;
  final String body;
  final String tag;
  final bool hasImage;

  @override
  List<Object?> get props =>
      [id, uid, minutesAgo, proximity, score, comments, body, tag, hasImage];
}

class MockComment extends Equatable {
  const MockComment({
    required this.id,
    required this.uid,
    required this.minutesAgo,
    required this.score,
    required this.body,
    this.replies = const [],
  });

  final String id;
  final String uid;
  final int minutesAgo;
  final int score;
  final String body;
  final List<MockComment> replies;

  @override
  List<Object?> get props => [id, uid, minutesAgo, score, body, replies];
}

enum TrendDir { up, down, flat }

class MockTrend extends Equatable {
  const MockTrend({required this.tag, required this.count, required this.dir});
  final String tag;
  final int count;
  final TrendDir dir;
  @override
  List<Object?> get props => [tag, count, dir];
}

const kMockPosts = <MockPost>[
  MockPost(
    id: 'p1', uid: '45821', minutesAgo: 14, proximity: Proximity.near,
    score: 124, comments: 38, tag: 'حكايات',
    body:
        'إذا أحد يبي يطلع في الفجر، فيه أمكنة بالحي تخوّف من الهدوء... '
        'جربتها أمس وكأن البلد لي وحدي.',
  ),
  MockPost(
    id: 'p2', uid: '77103', minutesAgo: 32, proximity: Proximity.block,
    score: 482, comments: 156, tag: 'مشاعر',
    body:
        'صار لي 3 سنين أعيش في نفس العمارة، أمس فقط اكتشفت إن الجار اللي تحتي '
        'يشتغل طباخ في نفس المطعم اللي أحبه. كم سنة ضاعت بدون "هاي" بسيطة.',
  ),
  MockPost(
    id: 'p3', uid: '32940', minutesAgo: 47, proximity: Proximity.near,
    score: 67, comments: 12, tag: 'لحظة', hasImage: true,
    body: 'الغروب الحين فوق الحي... لو شخص ثاني شافه يرفع يده.',
  ),
  MockPost(
    id: 'p4', uid: '91206', minutesAgo: 88, proximity: Proximity.city,
    score: 1200, comments: 412, tag: 'نقاش',
    body:
        'سؤال جدي: ليش الكافيهات الجديدة كلها نفس الطابع؟ نفس الكراسي، نفس '
        'الإضاءة، نفس قائمة المشروبات. وين الأصالة؟',
  ),
  MockPost(
    id: 'p5', uid: '58471', minutesAgo: 120, proximity: Proximity.block,
    score: 245, comments: 47, tag: 'مساعدة',
    body:
        'فقدت محفظتي قرب البقالة الكبيرة. إذا أحد لقاها — فيها شي مهم جداً '
        'غير الفلوس.',
  ),
];

const kMockComments = <MockComment>[
  MockComment(
    id: 'c1', uid: '34812', minutesAgo: 5, score: 24,
    body: 'صراحة كلامك يلمس... جربت نفس الإحساس قبل سنة.',
  ),
  MockComment(
    id: 'c2', uid: '56720', minutesAgo: 12, score: 56,
    body: 'فيه أمكنة فيها قهوة 24 ساعة بنفس الحي، تحب أعطيك عناوينها؟',
    replies: [
      MockComment(
        id: 'c2a', uid: '45821', minutesAgo: 8, score: 12,
        body: 'أكيد، أرسل لي همس.',
      ),
      MockComment(
        id: 'c2b', uid: '67891', minutesAgo: 4, score: 5,
        body: 'أنا كمان أبيها.',
      ),
    ],
  ),
  MockComment(
    id: 'c3', uid: '12048', minutesAgo: 25, score: 8,
    body: 'في رأيي الفجر أحلى وقت في اليوم، الصمت له طعم.',
  ),
];

const kMockTrends = <MockTrend>[
  MockTrend(tag: 'الكهرباء_قاطعة', count: 1240, dir: TrendDir.up),
  MockTrend(tag: 'مطعم_جديد_بالحي', count: 894, dir: TrendDir.up),
  MockTrend(tag: 'مشكلة_الإيجارات', count: 752, dir: TrendDir.up),
  MockTrend(tag: 'الزحام_الفجر', count: 410, dir: TrendDir.flat),
  MockTrend(tag: 'فعالية_السبت', count: 380, dir: TrendDir.up),
  MockTrend(tag: 'حادث_الإشارة', count: 290, dir: TrendDir.down),
];
