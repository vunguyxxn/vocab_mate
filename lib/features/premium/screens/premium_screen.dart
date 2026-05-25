import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/premium_plan_model.dart';
import 'mock_payment_screen.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  Future<void> _openPayment(
      BuildContext context,
      PremiumPlanModel plan,
      ) async {
    final upgraded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MockPaymentScreen(plan: plan),
      ),
    );

    if (upgraded == true && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'VocabMate Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mở khóa toàn bộ tính năng học từ vựng nâng cao',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            sliver: SliverList.separated(
              itemCount: PremiumPlanModel.plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final plan = PremiumPlanModel.plans[index];

                return _PlanCard(
                  plan: plan,
                  onTap: () => _openPayment(context, plan),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final PremiumPlanModel plan;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Ink(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: plan.isPopular
                      ? AppColors.indigo
                      : Colors.transparent,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildPrice(),
                  const SizedBox(height: 16),
                  _buildBenefits(),
                  const SizedBox(height: 18),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
        if (plan.isPopular)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.amberGradient,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: const Text(
                'Phổ biến',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: plan.gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.diamond_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                plan.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          plan.price,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            plan.originalPrice,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: plan.benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  benefit,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: plan.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Đăng ký gói',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}