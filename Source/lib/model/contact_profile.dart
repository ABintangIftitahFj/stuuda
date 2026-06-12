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

  static String _optionalString(dynamic value) {
    final text = (value ?? '').toString().trim();
    return (text == '-' || text == '...') ? '' : text;
  }

  factory ContactProfile.fromResponse(Map<String, dynamic>? response) {
    final data = response?['data'] is Map
        ? Map<String, dynamic>.from(response!['data'] as Map)
        : const <String, dynamic>{};
    final innerData = data['__data'] is Map
        ? Map<String, dynamic>.from(data['__data'] as Map)
        : const <String, dynamic>{};
    final firstName = _optionalString(data['first_name']);
    final waId = _optionalString(data['wa_id']);

    return ContactProfile(
      uid: _optionalString(data['_uid'] ?? data['contact_uid']),
      firstName: firstName.isNotEmpty ? firstName : 'Unknown',
      waId: waId.isNotEmpty ? waId : '-',
      email: _optionalString(data['email']),
      languageCode: _optionalString(data['language_code']),
      notes: _optionalString(innerData['contact_notes']),
      assignedUserId: _optionalString(data['assigned_users__id']),
    );
  }
}
