/// A badge definition with its earned state computed by [AppState].
class Badge {
  final String id;
  final String titleEn;
  final String titleHi;
  final String descEn;
  final String descHi;
  final bool earned;

  const Badge(this.id, this.titleEn, this.titleHi, this.descEn, this.descHi,
      this.earned);

  String title(String locale) => locale == 'hi' ? titleHi : titleEn;
  String desc(String locale) => locale == 'hi' ? descHi : descEn;
}
