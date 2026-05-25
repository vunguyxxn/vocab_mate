import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumPlanModel {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String originalPrice;
  final int amountVnd;
  final int months;
  final LinearGradient gradient;
  final bool isPopular;
  final List<String> benefits;

  const PremiumPlanModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.originalPrice,
    required this.amountVnd,
    required this.months,
    required this.gradient,
    required this.isPopular,
    required this.benefits,
  });

  static const List<PremiumPlanModel> plans = [
    PremiumPlanModel(
      id: 'monthly',
      title: 'Gói tháng',
      subtitle: 'Phù hợp trải nghiệm ngắn hạn',
      price: '29.000đ',
      originalPrice: '39.000đ',
      amountVnd: 29000,
      months: 1,
      gradient: AppColors.primaryGradient,
      isPopular: false,
      benefits: [
        'Chatbot AI không giới hạn',
        'Mở khóa bảng xếp hạng',
        'Không giới hạn luyện quiz',
        'Theo dõi tiến độ học nâng cao',
      ],
    ),
    PremiumPlanModel(
      id: 'quarterly',
      title: 'Gói 3 tháng',
      subtitle: 'Tiết kiệm hơn cho học kỳ',
      price: '79.000đ',
      originalPrice: '117.000đ',
      amountVnd: 79000,
      months: 3,
      gradient: AppColors.pinkGradient,
      isPopular: true,
      benefits: [
        'Chatbot AI không giới hạn',
        'Mở khóa bảng xếp hạng',
        'Không giới hạn luyện quiz',
        'Ưu tiên tính năng mới',
      ],
    ),
    PremiumPlanModel(
      id: 'yearly',
      title: 'Gói năm',
      subtitle: 'Tối ưu cho học lâu dài',
      price: '249.000đ',
      originalPrice: '468.000đ',
      amountVnd: 249000,
      months: 12,
      gradient: AppColors.greenGradient,
      isPopular: false,
      benefits: [
        'Chatbot AI không giới hạn',
        'Mở khóa bảng xếp hạng',
        'Không giới hạn luyện quiz',
        'Tiết kiệm chi phí nhiều nhất',
      ],
    ),
  ];
}