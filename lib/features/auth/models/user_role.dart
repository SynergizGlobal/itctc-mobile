enum UserRole {
  inspector,
  pmc,
  itcEngineer;

  String get label => switch (this) {
        UserRole.inspector => 'Inspector',
        UserRole.pmc => 'PMC',
        UserRole.itcEngineer => 'ITC Preconfirmation Engineer',
      };

  String get shortLabel => switch (this) {
        UserRole.inspector => 'Inspector',
        UserRole.pmc => 'PMC',
        UserRole.itcEngineer => 'ITC Engineer',
      };

  /// Stable API-ready role code for future backend payloads.
  String get apiCode => switch (this) {
        UserRole.inspector => 'INSPECTOR',
        UserRole.pmc => 'PMC',
        UserRole.itcEngineer => 'ITC_ENGINEER',
      };

  static UserRole? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'inspector' || 'in' || 'itctc_in' => UserRole.inspector,
      'pmc' || 'itctc_pmc' => UserRole.pmc,
      'itc' ||
      'itc_engineer' ||
      'itcengineer' ||
      'itc preconfirmation engineer' ||
      'itctc_itc' =>
        UserRole.itcEngineer,
      _ => null,
    };
  }
}
