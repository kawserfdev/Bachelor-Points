enum MessRole {
  owner('owner'),
  manager('manager'),
  member('member');

  const MessRole(this.value);
  final String value;

  factory MessRole.fromString(String role) {
    return MessRole.values.firstWhere(
      (r) => r.value == role,
      orElse: () => MessRole.member,
    );
  }

  bool get canManageMembers => this == owner || this == manager;
  bool get canApprove => this == owner || this == manager;
  bool get canEditSettings => this == owner || this == manager;
  bool get canDeleteMess => this == owner;
  bool get canTransferOwnership => this == owner;
}