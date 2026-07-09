class AuthUser {
  const AuthUser({
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String username;
  final String displayName;
  final String role;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final text = '$first$last';
    return text.isEmpty ? '?' : text.toUpperCase();
  }
}
