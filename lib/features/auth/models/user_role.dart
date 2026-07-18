enum UserRole {
  inspector,
  pmc,
  itcEngineer;

  String get label => switch (this) {
        UserRole.inspector => 'Inspector',
        UserRole.pmc => 'PMC',
        UserRole.itcEngineer => 'ITC Engineer',
      };

  /// Same as [label] — kept for call sites that want a compact role name.
  String get shortLabel => label;

  /// Stable API-ready role code for future backend payloads.
  String get apiCode => switch (this) {
        UserRole.inspector => 'INSPECTOR',
        UserRole.pmc => 'PMC',
        UserRole.itcEngineer => 'ITC_ENGINEER',
      };

  static UserRole? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
    return switch (normalized) {
      'inspector' || 'in' || 'itctc in' || 'itctc in 001' => UserRole.inspector,
      'pmc' || 'itctc pmc' || 'itctc pmc 001' => UserRole.pmc,
      'itc' ||
      'itc engineer' ||
      'itcengineer' ||
      'itc preconfirmation engineer' || // legacy label
      'itctc itc' ||
      'itctc itc 001' =>
        UserRole.itcEngineer,
      _ => null,
    };
  }

  /// Human-readable label for stored api codes / legacy role strings.
  static String displayLabel(String? value) {
    return tryParse(value)?.label ?? (value?.trim().isNotEmpty == true ? value!.trim() : '—');
  }
}
