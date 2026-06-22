import 'package:flutter/material.dart';
import 'package:stundaa/repositories/campaign_repository.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class BroadcastCreateScreen extends StatefulWidget {
  const BroadcastCreateScreen({super.key});

  @override
  State<BroadcastCreateScreen> createState() => _BroadcastCreateScreenState();
}

class _BroadcastCreateScreenState extends State<BroadcastCreateScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final CampaignRepository _repo = CampaignRepository();

  final _titleCtrl = TextEditingController();
  final _templateNameCtrl = TextEditingController();
  final _templateLangCtrl = TextEditingController(text: 'en');

  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _templates = [];
  String? _selectedGroup;
  bool _loadingGroups = true;
  bool _loadingTemplates = true;
  bool _submitting = false;
  DateTime? _scheduleAt;
  DateTime? _expireAt;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: const Cubic(0.32, 0.72, 0, 1),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Cubic(0.32, 0.72, 0, 1),
    ));
    _loadData();
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _repo.fetchContactGroups(),
      _repo.fetchTemplates(),
    ]);
    if (mounted) {
      setState(() {
        _groups = results[0];
        _templates = results[1];
        _loadingGroups = false;
        _loadingTemplates = false;
      });
    }
  }

  void _onTemplateSelected(Map<String, dynamic> template) {
    _templateNameCtrl.text = template['template_name']?.toString() ?? '';
    _templateLangCtrl.text = template['language']?.toString() ?? 'en';
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a contact group')),
      );
      return;
    }
    if (_templateNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select or enter a template')),
      );
      return;
    }
    setState(() => _submitting = true);

    String _fmtDt(DateTime dt) {
      final utc = dt.toUtc();
      return '${utc.year}-${utc.month.toString().padLeft(2,'0')}-${utc.day.toString().padLeft(2,'0')}T${utc.hour.toString().padLeft(2,'0')}:${utc.minute.toString().padLeft(2,'0')}:${utc.second.toString().padLeft(2,'0')}';
    }
    final data = <String, dynamic>{
      'title': _titleCtrl.text.trim(),
      'contact_group': _selectedGroup,
      'timezone': 'UTC',
      'template_name': _templateNameCtrl.text.trim(),
      'template_language': _templateLangCtrl.text.trim(),
      if (_scheduleAt != null) 'schedule_at': _fmtDt(_scheduleAt!),
      if (_expireAt != null) 'expire_at': _fmtDt(_expireAt!),
    };

    final result = await _repo.scheduleCampaign(data);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] == true) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Broadcast scheduled'),
          backgroundColor: app_theme.success,
        ),
      );
    } else {
      final msg = result['message'] ?? 'Failed to schedule broadcast';
      if (msg.toLowerCase().contains('tidak ada kontak aktif') || msg.toLowerCase().contains('no active contacts')) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: app_theme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: app_theme.error.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: app_theme.error),
                SizedBox(width: 8),
                Text(
                  'Peringatan',
                  style: TextStyle(
                    color: app_theme.error,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              '$msg. Campaign tidak bisa dikirim.',
              style: const TextStyle(
                color: app_theme.lavenderWhite,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: app_theme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: app_theme.error,
          ),
        );
      }
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
    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
    _fadeController.dispose();
    _slideController.dispose();
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
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: app_theme.lavenderWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      body: _loadingGroups || _loadingTemplates
          ? const Center(
              child: CircularProgressIndicator(color: app_theme.primary))
          : FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      _buildSectionHeader('Campaign Details'),
                      const SizedBox(height: 14),
                      _buildDoubleBezelCard([
                        _buildGlowField(_titleCtrl, 'Campaign Title',
                            hint: 'e.g. Summer Sale Announcement',
                            required: true,
                            icon: Icons.campaign_outlined),
                      ]),
                      const SizedBox(height: 28),
                      _buildSectionHeader('Audience'),
                      const SizedBox(height: 14),
                      _buildDoubleBezelCard([
                        _buildGroupDropdown(),
                      ]),
                      const SizedBox(height: 28),
                      _buildSectionHeader('Message Template'),
                      const SizedBox(height: 14),
                      _buildDoubleBezelCard([
                        _buildTemplatePicker(),
                        const SizedBox(height: 16),
                        _buildGlowField(_templateNameCtrl, 'Template Name',
                            hint: 'exact WhatsApp template name',
                            required: true,
                            icon: Icons.message_outlined),
                        const SizedBox(height: 14),
                        _buildGlowField(_templateLangCtrl, 'Language Code',
                            hint: 'e.g. en, id',
                            required: true,
                            icon: Icons.language_outlined),
                      ]),
                      const SizedBox(height: 28),
                      _buildSectionHeader('Schedule'),
                      const SizedBox(height: 14),
                      _buildDoubleBezelCard([
                        _buildDateTile(
                          'Schedule At',
                          _scheduleAt,
                          () => _pickDateTime(true),
                          () => setState(() => _scheduleAt = null),
                        ),
                        const SizedBox(height: 10),
                        Container(height: 1, color: app_theme.outlineSoft),
                        const SizedBox(height: 10),
                        _buildDateTile(
                          'Expire At',
                          _expireAt,
                          () => _pickDateTime(false),
                          () => setState(() => _expireAt = null),
                        ),
                      ]),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: app_theme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: app_theme.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoubleBezelCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: app_theme.doubleBezelShellDecoration(radius: 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0C1A2E),
              Color(0xFF0A1524),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(255, 255, 255, 0.03),
              blurRadius: 0,
              spreadRadius: 0.5,
            ),
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.22),
              blurRadius: 12,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildGlowField(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    String? hint,
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(
        color: app_theme.lavenderWhite,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      cursorColor: app_theme.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            icon != null ? Icon(icon, size: 20, color: app_theme.secondary) : null,
        labelStyle: const TextStyle(
          color: app_theme.secondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: app_theme.secondary.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        filled: true,
        fillColor: app_theme.surface.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: app_theme.outlineSoft, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: app_theme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: app_theme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: app_theme.error, width: 1.5),
        ),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }

  Widget _buildGroupDropdown() {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem(
        value: 'all_contacts',
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: app_theme.primary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.public_outlined,
                  color: app_theme.primary, size: 17),
            ),
            const SizedBox(width: 12),
            const Text('All Contacts',
                style: TextStyle(
                    color: app_theme.lavenderWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      ..._groups.map((g) {
        final title = g['title']?.toString() ?? '';
        return DropdownMenuItem(
          value: title.isNotEmpty ? title : g['_uid']?.toString() ?? '',
          child: Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(title.isNotEmpty ? title : 'Unknown',
                style: const TextStyle(
                    color: app_theme.lavenderWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        );
      }),
    ];
    return DropdownButtonFormField<String>(
      initialValue: _selectedGroup,
      items: items,
      onChanged: (v) => setState(() => _selectedGroup = v),
      dropdownColor: app_theme.surfaceElevated,
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: app_theme.secondary, size: 22),
      style: const TextStyle(
          color: app_theme.lavenderWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Contact Group',
        prefixIcon: const Icon(Icons.group_outlined,
            size: 20, color: app_theme.secondary),
        labelStyle: const TextStyle(
          color: app_theme.secondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: app_theme.surface.withValues(alpha: 0.6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: app_theme.outlineSoft, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: app_theme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTemplatePicker() {
    if (_templates.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text(
            'Quick Select',
            style: TextStyle(
              color: app_theme.secondary.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (ctx, i) {
              final t = _templates[i];
              final name = t['template_name']?.toString() ?? '';
              final lang = t['language']?.toString() ?? 'en';
              final isSelected =
                  _templateNameCtrl.text.trim() == name;
              return GestureDetector(
                onTap: () => _onTemplateSelected(t),
                child: AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 300),
                  curve: const Cubic(0.32, 0.72, 0, 1),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? app_theme.primary
                            .withValues(alpha: 0.2)
                        : app_theme.surfaceMuted
                            .withValues(alpha: 0.5),
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? app_theme.primary
                              .withValues(alpha: 0.5)
                          : app_theme.outlineSoft,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: isSelected
                              ? app_theme.lavenderWhite
                              : app_theme.secondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              app_theme.surfaceElevated
                                  .withValues(
                                      alpha: 0.7),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Text(
                          lang.toUpperCase(),
                          style: TextStyle(
                            color: app_theme.secondary
                                .withValues(alpha: 0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(
    String label,
    DateTime? value,
    VoidCallback onTap,
    VoidCallback onClear,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.32, 0.72, 0, 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: value != null
              ? app_theme.primary.withValues(alpha: 0.08)
              : app_theme.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value != null
                ? app_theme.primary.withValues(alpha: 0.35)
                : app_theme.outlineSoft,
            width: value != null ? 1.2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: app_theme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                value != null
                    ? Icons.schedule_rounded
                    : Icons.calendar_today_outlined,
                color: value != null
                    ? app_theme.primary
                    : app_theme.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: app_theme.secondary.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value != null
                        ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}  ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}'
                        : 'Not set',
                    style: TextStyle(
                      color: value != null
                          ? app_theme.lavenderWhite
                          : app_theme.secondary.withValues(alpha: 0.45),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: app_theme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: app_theme.error, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _submitting ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: const Cubic(0.32, 0.72, 0, 1),
        height: 56,
        decoration: BoxDecoration(
          gradient: _submitting
              ? LinearGradient(
                  colors: [
                    app_theme.primary.withValues(alpha: 0.35),
                    app_theme.cyanGlow.withValues(alpha: 0.35),
                  ],
                )
              : app_theme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: app_theme.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Schedule Broadcast',
                      style: TextStyle(
                        color: app_theme.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: app_theme.black, size: 20),
                  ],
                ),
        ),
      ),
    );
  }
}
