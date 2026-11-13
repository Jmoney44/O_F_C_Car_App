class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.isAdmin = false,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final bool isAdmin;

  String get firstName => name.trim().split(' ').first;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      isAdmin: map['role'] == 'admin',
    );
  }
}
