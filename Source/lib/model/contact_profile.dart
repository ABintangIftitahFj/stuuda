class ContactProfile {
  const ContactProfile({
    required this.uid,
    required this.firstName,
    required this.waId,
    required this.email,
    required this.languageCode,
    required this.notes,
    required this.assignedUserId,
  });

  final String uid;
  final String firstName;
  final String waId;
  final String email;
  final String languageCode;
  final String notes;
  final String assignedUserId;

  factory ContactProfile.fromResponse(Map<String, dynamic>? response) {
    final data = response?['data'] is Map
        ? Map<String, dynamic>.from(response!['data'] as Map)
        : const <String, dynamic>{};
    final innerData = data['__data'] is Map
        ? Map<String, dynamic>.from(data['__data'] as Map)
        : const <String, dynamic>{};

    return ContactProfile(
      uid: (data['_uid'] ?? data['contact_uid'] ?? '').toString(),
      firstName: (data['first_name'] ?? 'Unknown').toString(),
      waId: (data['wa_id'] ?? '-').toString(),
      email: (data['email'] ?? '-').toString(),
      languageCode: (data['language_code'] ?? '-').toString(),
      notes: (innerData['contact_notes'] ?? '').toString(),
      assignedUserId: (data['assigned_users__id'] ?? '').toString(),
    );
  }
}
