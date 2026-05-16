import 'package:equatable/equatable.dart';

/// Mirrors the `public.profiles` table in Supabase.
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.numericId,
    required this.status,
    this.cityCode,
    required this.createdAt,
    required this.lastSeenAt,
  });

  final String id;
  final int numericId;
  final String status;
  final String? cityCode;
  final DateTime createdAt;
  final DateTime lastSeenAt;

  bool get isBanned => status == 'banned';
  String get displayId => '#$numericId';

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        numericId: m['numeric_id'] as int,
        status: m['status'] as String? ?? 'active',
        cityCode: m['city_code'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        lastSeenAt: DateTime.parse(m['last_seen_at'] as String),
      );

  @override
  List<Object?> get props =>
      [id, numericId, status, cityCode, createdAt, lastSeenAt];
}
