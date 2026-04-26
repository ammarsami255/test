import 'package:flutter/material.dart';
import 'package:el_moza3/Constants.dart';
import 'package:el_moza3/services/listing_service.dart';
import 'package:el_moza3/widget/service_card.dart';
import 'package:el_moza3/screens/service_detail_screen.dart';

class ServicesScreen extends StatefulWidget {
  final Future<void> Function() onRequireLogin;

  const ServicesScreen({super.key, required this.onRequireLogin});

  static String id = "ServicesScreen";

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _selectedCategory = 0;

  static const List<Map<String, dynamic>> _categories = [
    {"label": "الكل", "icon": Icons.apps},
    {"label": "خدمات مهنية", "icon": Icons.business_center},
    {"label": "صناعة وتصنيع", "icon": Icons.factory},
    {"label": "مقاولات", "icon": Icons.construction},
    {"label": "نقل ولوجستيات", "icon": Icons.local_shipping},
  ];

  static const Map<String, IconData> _categoryIcons = {
    "خدمات مهنية": Icons.business_center,
    "صناعة وتصنيع": Icons.factory,
    "مقاولات": Icons.construction,
    "نقل ولوجستيات": Icons.local_shipping,
  };

  static const Map<String, Color> _categoryColors = {
    "خدمات مهنية": Colors.blue,
    "صناعة وتصنيع": Colors.orange,
    "مقاولات": Colors.green,
    "نقل ولوجستيات": Colors.red,
  };

  String get _selectedCategoryLabel =>
      _categories[_selectedCategory]["label"] as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background2,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background1, AppColors.background2],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isMobile = w < AppSizes.mobileBreakpoint;
              final isDesktop = w >= AppSizes.tabletBreakpoint;
              final crossAxisCount = isMobile
                  ? 1
                  : isDesktop
                  ? 3
                  : 2;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildCategories(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: ListingService.getListings(
                        category: _selectedCategoryLabel == 'الكل'
                            ? null
                            : _selectedCategoryLabel,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final listings = snapshot.data ?? [];
                        if (listings.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 60,
                                  color: AppColors.border,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "مفيش إعلانات دلوقتي",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                "${listings.length} إعلان",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: listings.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: isMobile ? 3.2 : 1.6,
                                    ),
                                itemBuilder: (context, index) {
                                  final item = listings[index];
                                  final cat = item["category"] as String? ?? "";
                                  return ServiceCard(
                                    title: item["title"] ?? "",
                                    category: cat,
                                    price: item["price"] ?? "",
                                    location: item["location"] ?? "",
                                    icon:
                                        _categoryIcons[cat] ??
                                        Icons.miscellaneous_services,
                                    color:
                                        _categoryColors[cat] ??
                                        AppColors.primary,
                                    type: item["type"] ?? "",
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ServiceDetailScreen(
                                            item: item,
                                            onRequireLogin:
                                                widget.onRequireLogin,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            "الموزّع",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _categories[index]["icon"] as IconData,
                    size: 15,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _categories[index]["label"] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
