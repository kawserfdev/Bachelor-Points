enum AuthProvider {
  email('email'),
  google('google'),
  phone('phone');

  const AuthProvider(this.value);
  final String value;

  factory AuthProvider.fromString(String provider) {
    return AuthProvider.values.firstWhere(
      (p) => p.value == provider,
      orElse: () => AuthProvider.email,
    );
  }
}