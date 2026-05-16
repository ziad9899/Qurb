import 'package:equatable/equatable.dart';

class Community extends Equatable {
  const Community({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.hue,
    required this.members,
  });
  final int id;
  final String slug;
  final String name;
  final String description;
  final int hue;
  final int members;

  factory Community.fromMap(Map<String, dynamic> m) => Community(
        id: (m['id'] as num).toInt(),
        slug: m['slug'] as String,
        name: m['name'] as String,
        description: m['description'] as String? ?? '',
        hue: (m['hue'] as num).toInt(),
        members: (m['members'] as num).toInt(),
      );

  @override
  List<Object?> get props => [id, slug, name, description, hue, members];
}
