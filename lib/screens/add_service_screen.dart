import 'package:flutter/material.dart';
import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/services/listing_service.dart';
import 'package:el_moza3/services/error_handler.dart';
import 'package:el_moza3/services/auth_service.dart';

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
  String _category = "خدمات مهنية";
  String _type = "عرض خدمة";
  String _location = "القاهرة";
  bool _loading = false;

  static const List<String> _categories = [
    "خدمات مهنية",
    "صناعة وتصنيع",
    "مقاولات",
    "نقل ولوجستيات",
  ];
  static const List<String> _locations = [
    "القاهرة",
    "الإسكندرية",
    "الجيزة",
    "القليوبية",
    "الشرقية",
    "الساحل الشمالي",
    "شبرا الخيمة",
  ];

  Future<void> _submit() async {
    if (_titleCtrl.text.isEmpty || _descCtrl.text.isEmpty) {
      ErrorHandler.showErrorDialog(
        context,
        message: 'يرجى إكمال جميع الحقول المطلوبة',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final err = await ListingService.addListing(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        type: _type,
        price: _priceCtrl.text.trim().isEmpty
            ? "يحدد لاحقاً"
            : _priceCtrl.text.trim(),
        location: _location,
        phone: _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);

      if (err != null) {
        ErrorHandler.showErrorDialog(context, message: err);
      } else {
        ErrorHandler.showSuccessDialog(
          context,
          message: 'تم نشر الإعلان بنجاح',
        );
        _titleCtrl.clear();
        _descCtrl.clear();
        _priceCtrl.clear();
        _phoneCtrl.clear();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ErrorHandler.handleException(context, e);
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
                "إضافة خدمة",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "انشر خدمتك أو منتجك",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _section("نوع الخدمة"),
              Row(
                children: ["عرض خدمة", "طلب خدمة"].map((t) {
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
                          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
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
              _section("التصنيف"),
              _dropdown(
                _categories,
                _category,
                (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              _section("عنوان الخدمة"),
              _field(_titleCtrl, "مثال: شركة تصميم هندسي"),
              const SizedBox(height: 16),
              _section("وصف الخدمة"),
              _field(_descCtrl, "اكتب تفاصيل الخدمة...", maxLines: 4),
              const SizedBox(height: 16),
              _section("السعر (اختياري)"),
              _field(_priceCtrl, "مثال: 500 ج.م. أو اتصل بنا"),
              const SizedBox(height: 16),
              _section("الموقع"),
              _dropdown(
                _locations,
                _location,
                (v) => setState(() => _location = v!),
              ),
              const SizedBox(height: 16),
              _section("رقم التواصل"),
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
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "نشر الخدمة",
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
