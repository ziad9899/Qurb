/// Arabic relative time helper. Input is minutes since the event.
/// Mirrors `rel(min)` in the web design.
String relMinutes(int min) {
  if (min < 1) return 'الآن';
  if (min < 60) return 'قبل $min د';
  if (min < 60 * 24) return 'قبل ${min ~/ 60} س';
  return 'قبل ${min ~/ (60 * 24)} ي';
}
