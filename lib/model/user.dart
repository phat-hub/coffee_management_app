class User {
  final String? id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String role;
  final bool isActive;

  User({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.role,
    required this.isActive,
  });

  bool get isOwner => role == 'owner';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      role: json['role'] ?? 'staff',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'role': role,
      'isActive': isActive,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }
}
