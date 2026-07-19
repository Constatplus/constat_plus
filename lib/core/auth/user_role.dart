enum UserRole {
  user,
  controller,
  admin;

  static UserRole fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return switch (normalized) {
      'controller' || 'controleur' || 'contrôleur' => UserRole.controller,
      'admin' || 'administrator' || 'administrateur' => UserRole.admin,
      _ => UserRole.user,
    };
  }
}
