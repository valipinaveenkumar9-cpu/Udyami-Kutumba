class Contact {
  final String initials;
  final String name;
  final String phone;
  final String sector;
  bool selected;

  Contact({
    required this.initials,
    required this.name,
    required this.phone,
    required this.sector,
    this.selected = false,
  });
}
