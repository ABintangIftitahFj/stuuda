class AgentUser {
  const AgentUser({
    required this.id,
    required this.uid,
    required this.name,
    required this.vendorId,
  });

  final String id;
  final String uid;
  final String name;
  final String vendorId;

  factory AgentUser.fromMap(Map<String, dynamic> map) {
    return AgentUser(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      uid: (map['_uid'] ?? '').toString(),
      name: (map['full_name'] ?? map['value'] ?? 'Unknown').toString(),
      vendorId: (map['vendors__id'] ?? 'null').toString(),
    );
  }

  Map<String, dynamic> toDropdownItem() {
    return <String, dynamic>{
      'id': id,
      '_uid': uid,
      'value': name,
      'vendors__id': vendorId,
    };
  }
}
