enum MapStyleTheme {
  standard('Standard'),
  dark('Dark'),
  night('Night'),
  nightBlue('Night Blue'),
  retro('Retro');

  static MapStyleTheme fromName(String name) => MapStyleTheme.values.firstWhere((e) => e.name == name, orElse: () => MapStyleTheme.standard);

  const MapStyleTheme(this.displayName);
  final String displayName;
}
