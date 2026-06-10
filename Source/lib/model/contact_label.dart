class ContactLabel {
  const ContactLabel({
    required this.id,
    required this.uid,
    required this.title,
    required this.textColor,
    required this.backgroundColor,
  });

  final String id;
  final String uid;
  final String title;
  final String textColor;
  final String backgroundColor;

  factory ContactLabel.fromMap(Map<String, dynamic> map) {
    return ContactLabel(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      uid: (map['_uid'] ?? '').toString(),
      title: (map['title'] ?? map['value'] ?? 'Untitled').toString(),
      textColor:
          (map['text_color'] ?? map['textColor'] ?? '#000000').toString(),
      backgroundColor:
          (map['bg_color'] ?? map['bgColor'] ?? '#ffffff').toString(),
    );
  }

  Map<String, dynamic> toDropdownItem() {
    return <String, dynamic>{
      'id': id,
      '_uid': uid,
      'value': title,
      'textColor': textColor,
      'bgColor': backgroundColor,
    };
  }
}
