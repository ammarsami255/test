import 'package:flutter/material.dart';
import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/services/admin_service.dart';
import 'package:el_moza3/services/listing_service.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _category = "Ø®Ø¯Ù…Ø§Øª Ù…Ù‡Ù†ÙŠØ©";
  String _type = "Ø¹Ø±Ø¶ Ø®Ø¯Ù…Ø©";
  String _location = "Ø§Ù„Ù‚Ø§Ù‡Ø±Ø©";
  bool _loading = false;

  static const List<String> _categories = [
    "Ø®Ø¯Ù…Ø§Øª Ù…Ù‡Ù†ÙŠØ©",
    "ØµÙ†Ø§Ø¹Ø© ÙˆØªØµÙ†ÙŠØ¹",
    "Ù…Ù‚Ø§ÙˆÙ„Ø§Øª",
    "Ù†Ù‚Ù„ ÙˆÙ„ÙˆØ¬Ø³ØªÙŠØ§Øª",
  ];
  static const List<String> _locations = [
    "Ø§Ù„Ù‚Ø§Ù‡Ø±Ø©",
    "Ø§Ù„Ø¥Ø³ÙƒÙ†Ø¯Ø±ÙŠØ©",
    "Ø§Ù„Ø¬ÙŠØ²Ø©",
    "Ø§Ù„Ù‚Ø§Ù‡Ø±Ø© Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©",
    "Ø§Ù„Ø¹Ø§Ø´Ø± Ù…Ù† Ø±Ù…Ø¶Ø§Ù†",
    "Ø§Ù„Ø³Ø§Ø¯Ø³ Ù…Ù† Ø£ÙƒØªÙˆØ¨Ø±",
    "Ø´Ø¨Ø±Ø§ Ø§Ù„Ø®ÙŠÙ…Ø©",
  ];

  void _submit() async {
    final ok = await AdminService.requireAdmin(context);
    if (!ok) return;

    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(content: Text("Ù…Ù† ÙØ¶Ù„Ùƒ Ø§ÙƒÙ…Ù„ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª")),
      );
      return;
    }
    setState(() => _loading = true);
    final err = await ListingService.addListing(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      type: _type,
      price: _priceCtrl.text.trim().isEmpty
          ? "ÙŠÙØ­Ø¯Ø¯ Ù„Ø§Ø­Ù‚Ø§Ù‹"
          : _priceCtrl.text.trim(),
      location: _location,
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ØªÙ… Ù†Ø´Ø± Ø§Ù„Ø¥Ø¹Ù„Ø§Ù† âœ“"),
          backgroundColor: Colors.green,
        ),
      );
      _titleCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _phoneCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ø¥Ø¶Ø§ÙØ© Ø¥Ø¹Ù„Ø§Ù†",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Ø§Ù†Ø´Ø± Ø®Ø¯Ù…ØªÙƒ Ø£Ùˆ Ø§Ø·Ù„Ø¨ Ù…Ø§ ØªØ­ØªØ§Ø¬Ù‡",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _section("Ù†ÙˆØ¹ Ø§Ù„Ø¥Ø¹Ù„Ø§Ù†"),
              Row(
                children: ["Ø¹Ø±Ø¶ Ø®Ø¯Ù…Ø©", "Ø·Ù„Ø¨ Ø®Ø¯Ù…Ø©"].map((t) {
                  final sel = _type == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppSizes.borderRadius,
                          ),
                          border: Border.all(
                            color: sel ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          t,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _section("Ø§Ù„ØªØµÙ†ÙŠÙ"),
              _dropdown(
                _categories,
                _category,
                (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              _section("Ø¹Ù†ÙˆØ§Ù† Ø§Ù„Ø¥Ø¹Ù„Ø§Ù†"),
              _field(_titleCtrl, "Ù…Ø«Ø§Ù„: Ù…ÙƒØªØ¨ Ù…Ø­Ø§Ø³Ø¨Ø© Ù…Ø¹ØªÙ…Ø¯"),
              const SizedBox(height: 16),
              _section("ÙˆØµÙ Ø§Ù„Ø®Ø¯Ù…Ø©"),
              _field(_descCtrl, "Ø§ÙƒØªØ¨ ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø®Ø¯Ù…Ø©...", maxLines: 4),
              const SizedBox(height: 16),
              _section("Ø§Ù„Ø³Ø¹Ø± (Ø§Ø®ØªÙŠØ§Ø±ÙŠ)"),
              _field(_priceCtrl, "Ù…Ø«Ø§Ù„: 500 Ø¬/Ø³Ø§Ø¹Ø© Ø£Ùˆ ØªÙØ§ÙˆØ¶"),
              const SizedBox(height: 16),
              _section("Ø§Ù„Ù…ÙˆÙ‚Ø¹"),
              _dropdown(
                _locations,
                _location,
                (v) => setState(() => _location = v!),
              ),
              const SizedBox(height: 16),
              _section("Ø±Ù‚Ù… Ø§Ù„ØªÙˆØ§ØµÙ„"),
              _field(_phoneCtrl, "01XXXXXXXXX"),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadius,
                      ),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ù†Ø´Ø± Ø§Ù„Ø¥Ø¹Ù„Ø§Ù†",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );

  Widget _field(TextEditingController ctrl, String hint, {int maxLines = 1}) =>
      TextField(
        controller: ctrl,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      );

  Widget _dropdown(
    List<String> items,
    String value,
    void Function(String?) onChanged,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, textAlign: TextAlign.right),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      );
}
