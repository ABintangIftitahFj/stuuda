import 'package:flutter/material.dart';
import 'package:stundaa/repositories/campaign_repository.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class BroadcastCreateScreen extends StatefulWidget {
  const BroadcastCreateScreen({super.key});

  @override
  State<BroadcastCreateScreen> createState() => _BroadcastCreateScreenState();
}

class _BroadcastCreateScreenState extends State<BroadcastCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final CampaignRepository _repo = CampaignRepository();

  final _titleCtrl = TextEditingController();
  final _templateNameCtrl = TextEditingController();
  final _templateLangCtrl = TextEditingController(text: 'en');

  List<Map<String, dynamic>> _groups = [];
  String? _selectedGroup;
  bool _loadingGroups = true;
  bool _submitting = false;
  DateTime? _scheduleAt;
  DateTime? _expireAt;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final groups = await _repo.fetchContactGroups();
    if (mounted) {
      setState(() {
        _groups = groups;
        _loadingGroups = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a contact group')),
      );
      return;
    }
    setState(() => _submitting = true);

    final tz = DateTime.now().timeZoneName;
    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'contact_group': _selectedGroup,
      'timezone': tz,
      'template_name': _templateNameCtrl.text.trim(),
      'template_language': _templateLangCtrl.text.trim(),
      if (_scheduleAt != null) 'schedule_at': _scheduleAt!.toIso8601String(),
      if (_expireAt != null) 'expire_at': _expireAt!.toIso8601String(),
    };

    final ok = await _repo.scheduleCampaign(data);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Broadcast scheduled'),
          backgroundColor: app_theme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to schedule broadcast'),
          backgroundColor: app_theme.error,
        ),
      );
    }
  }

  Future<void> _pickDateTime(bool isSchedule) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: app_theme.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: app_theme.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isSchedule) {
        _scheduleAt = dt;
      } else {
        _expireAt = dt;
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _templateNameCtrl.dispose();
    _templateLangCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: AppBar(
        title: const Text('New Broadcast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loadingGroups
          ? const Center(child: CircularProgressIndicator(color: app_theme.primary))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildField(_titleCtrl, 'Title', required: true),
                  const SizedBox(height: 16),
                  _buildGroupDropdown(),
                  const SizedBox(height: 16),
                  _buildField(_templateNameCtrl, 'Template Name', required: true,
                      hint: 'exact name from WhatsApp template'),
                  const SizedBox(height: 16),
                  _buildField(_templateLangCtrl, 'Template Language',
                      required: true, hint: 'e.g. en, id'),
                  const SizedBox(height: 16),
                  _buildDateTile(
                    'Schedule At (optional)',
                    _scheduleAt,
                    () => _pickDateTime(true),
                    () => setState(() => _scheduleAt = null),
                  ),
                  const SizedBox(height: 12),
                  _buildDateTile(
                    'Expire At (optional)',
                    _expireAt,
                    () => _pickDateTime(false),
                    () => setState(() => _expireAt = null),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: app_theme.primary,
                      foregroundColor: app_theme.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: app_theme.black,
                            ),
                          )
                        : const Text('Schedule Broadcast',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    String? hint,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: app_theme.lavenderWhite),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: app_theme.secondary),
        hintStyle: TextStyle(color: app_theme.secondary.withValues(alpha: 0.5)),
        filled: true,
        fillColor: app_theme.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.outlineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.primary),
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _buildGroupDropdown() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'all_contacts', child: Text('All Contacts')),
      ..._groups.map((g) => DropdownMenuItem<String>(
            value: g['title']?.toString() ?? g['_uid']?.toString() ?? '',
            child: Text(g['title']?.toString() ?? ''),
          )),
    ];
    return DropdownButtonFormField<String>(
      value: _selectedGroup,
      items: items,
      onChanged: (v) => setState(() => _selectedGroup = v),
      dropdownColor: app_theme.surfaceElevated,
      style: const TextStyle(color: app_theme.lavenderWhite),
      decoration: InputDecoration(
        labelText: 'Contact Group',
        labelStyle: const TextStyle(color: app_theme.secondary),
        filled: true,
        fillColor: app_theme.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.outlineSoft),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.outlineSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: app_theme.primary),
        ),
      ),
    );
  }

  Widget _buildDateTile(
    String label,
    DateTime? value,
    VoidCallback onTap,
    VoidCallback onClear,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: app_theme.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: app_theme.outlineSoft),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: app_theme.secondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null
                    ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                    : label,
                style: TextStyle(
                  color: value != null ? app_theme.lavenderWhite : app_theme.secondary,
                  fontSize: 14,
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear, color: app_theme.secondary, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}
