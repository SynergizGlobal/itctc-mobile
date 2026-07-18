import 'user_role.dart';

class AuthUser {
  const AuthUser({
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String username;
  final String displayName;
  final UserRole role;

  String get roleLabel => role.label;

  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final text = '$first$last';
    return text.isEmpty ? '?' : text.toUpperCase();
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'displayName': displayName,
        'role': role.apiCode,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      username: json['username']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      role: UserRole.tryParse(json['role']?.toString()) ?? UserRole.inspector,
    );
  }
}
