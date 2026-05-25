import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../models/premium_plan_model.dart';
import '../services/premium_service.dart';

class MockPaymentScreen extends StatefulWidget {
  final PremiumPlanModel plan;

  const MockPaymentScreen({
    super.key,
    required this.plan,
  });

  @override
  State<MockPaymentScreen> createState() => _MockPaymentScreenState();
}

class _MockPaymentScreenState extends State<MockPaymentScreen> {
  bool _isLoading = false;

  // Đổi các thông tin này thành tài khoản demo/thật của bạn.
  static const String _bankId = 'TechcomBank';
  static const String _accountNo = '2868 9955 77';
  static const String _accountName = 'NGUYEN TUAN VU';

  String get _orderCode {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    return 'VM${widget.plan.id.toUpperCase()}${time.substring(time.length - 6)}';
  }

  String get _transferContent => 'VOCABMATE ${widget.plan.id.toUpperCase()}';

  String get _vietQrUrl {
    final encodedAddInfo = Uri.encodeComponent(_transferContent);
    final encodedAccountName = Uri.encodeComponent(_accountName);

    return 'https://img.vietqr.io/image/'
        '$_bankId-$_accountNo-compact2.png'
        '?amount=${widget.plan.amountVnd}'
        '&addInfo=$encodedAddInfo'
        '&accountName=$encodedAccountName';
  }

  Future<void> _confirmPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock: giả lập hệ thống đã kiểm tra giao dịch.
      await Future.delayed(const Duration(seconds: 1));

      await PremiumService.activatePremium(
        plan: widget.plan.id,
        months: widget.plan.months,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
              ),
              SizedBox(width: 8),
              Text('Thành công'),
            ],
          ),
          content: Text(
            'Bạn đã nâng cấp ${widget.plan.title} thành công.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyTransferContent() async {
    await Clipboard.setData(
      ClipboardData(text: _transferContent),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép nội dung chuyển khoản'),
      ),
    );
  }

  Future<void> _copyAccountNo() async {
    await Clipboard.setData(
      const ClipboardData(text: _accountNo),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép số tài khoản'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: plan.gradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Thanh toán VietQR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${plan.title} • ${plan.price}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
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
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildOrderSummary(plan),
                  const SizedBox(height: 18),
                  _buildQrCard(plan),
                  const SizedBox(height: 18),
                  _buildTransferInfo(plan),
                  const SizedBox(height: 20),
                  _buildConfirmButton(),
                  const SizedBox(height: 14),
                  const Text(
                    'Đây là thanh toán demo bằng VietQR. Mã QR có thể quét thật, nhưng app chưa tự kiểm tra giao dịch ngân hàng.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PremiumPlanModel plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: plan.gradient,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 28,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thời hạn: ${plan.months} tháng',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            plan.price,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(PremiumPlanModel plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Quét mã VietQR để thanh toán',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'App ngân hàng sẽ tự điền số tiền và nội dung chuyển khoản',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 260,
            height: 300,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                _vietQrUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 36,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Không tải được mã VietQR',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            plan.price,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferInfo(PremiumPlanModel plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const _InfoRow(
            label: 'Ngân hàng',
            value: _bankId,
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _copyAccountNo,
            child: const _InfoRow(
              label: 'Số tài khoản',
              value: '0123456789',
              trailingIcon: Icons.copy_rounded,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            label: 'Chủ tài khoản',
            value: _accountName,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Số tiền',
            value: plan.price,
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _copyTransferContent,
            child: _InfoRow(
              label: 'Nội dung',
              value: _transferContent,
              trailingIcon: Icons.copy_rounded,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Mã đơn',
            value: _orderCode,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _isLoading ? null : _confirmPayment,
      child: Ink(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.primaryGradient,
          color: _isLoading ? AppColors.textSecondary : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: Colors.white,
            ),
          )
              : const Text(
            'Tôi đã thanh toán',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? trailingIcon;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 6),
                Icon(
                  trailingIcon,
                  size: 18,
                  color: AppColors.indigo,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}