import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/walletpage_model.dart';

class PaymentGatewaylistWidget extends StatelessWidget {
  final BuildContext cont;
  final String currencySymbol;
  final String amount;
  final List<PaymentGateway> walletPaymentGatways;
  const PaymentGatewaylistWidget(
      {super.key,
      required this.cont,
      required this.walletPaymentGatways,
      required this.currencySymbol,
      required this.amount});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scaffoldBg =
            isDark ? const Color(0xFF080F19) : const Color(0xFFF8FAFC);
        final cardBg = isDark ? const Color(0xFF0D1623) : Colors.white;
        final cardBorder = isDark
            ? Colors.white.withValues(alpha: 0.07)
            : const Color(0xFFE2E8F0);
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;
        final isRtl = context.read<AccBloc>().textDirection == 'rtl';

        return walletPaymentGatways.isNotEmpty
            ? Scaffold(
                backgroundColor: scaffoldBg,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(64),
                  child: SafeArea(
                    child: Container(
                      color: Colors.transparent,
                      padding:
                          const EdgeInsets.only(top: 8, left: 16, right: 16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PositionedDirectional(
                            start: 0,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Icon(
                                isRtl ? Icons.arrow_forward : Icons.arrow_back,
                                color: titleColor,
                                size: 20,
                              ),
                            ),
                          ),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .selectPaymentMethod,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: titleColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .choosePaymentMethod,
                                textStyle: TextStyle(
                                  color: titleColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .choosePaymentMethodSubText,
                                textStyle: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 24),
                              ListView.separated(
                                itemCount: walletPaymentGatways.length,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (_, index) {
                                  final gateway = walletPaymentGatways[index];
                                  if (gateway.enabled != true) {
                                    return const SizedBox.shrink();
                                  }

                                  final isSelected = context
                                          .read<AccBloc>()
                                          .choosenPaymentIndex ==
                                      index;

                                  // Standardize Gateway Name capitalization
                                  String gatewayName = gateway.gateway;
                                  if (gatewayName.toLowerCase() ==
                                      'flutterwave') {
                                    gatewayName = 'Flutterwave';
                                  } else if (gatewayName.toLowerCase() ==
                                      'cashfree') {
                                    gatewayName = 'Cashfree';
                                  } else if (gatewayName.toLowerCase() ==
                                      'paystack') {
                                    gatewayName = 'Paystack';
                                  } else if (gatewayName.toLowerCase() ==
                                      'razorpay') {
                                    gatewayName = 'Razorpay';
                                  } else if (gatewayName.toLowerCase() ==
                                      'stripe') {
                                    gatewayName = 'Stripe';
                                  } else if (gatewayName.toLowerCase() ==
                                      'flexpaie') {
                                    gatewayName = 'Flexpaie';
                                  } else if (gatewayName.toLowerCase() ==
                                      'openpix') {
                                    gatewayName = 'Openpix';
                                  }

                                  return InkWell(
                                    onTap: () {
                                      context.read<AccBloc>().add(
                                          PaymentOnTapEvent(
                                              selectedPaymentIndex: index));
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark
                                                ? primaryBlue.withValues(
                                                    alpha: 0.05)
                                                : const Color(0xFFEFF6FF))
                                            : cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          width: 1.5,
                                          color: isSelected
                                              ? primaryBlue
                                              : cardBorder,
                                        ),
                                        boxShadow: isDark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.02),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                )
                                              ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Logo Container
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF162032)
                                                  : (gateway.isCard
                                                      ? const Color(0xFF0F172A)
                                                      : const Color(
                                                          0xFFF8FAFC)),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: cardBorder, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: gateway.isCard
                                                ? _getCardImage(
                                                    gateway.image, size)
                                                : CachedNetworkImage(
                                                    imageUrl: gateway.image,
                                                    fit: BoxFit.contain,
                                                    placeholder:
                                                        (context, url) =>
                                                            const Center(
                                                      child: Loader(),
                                                    ),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(
                                                      Icons.payment_rounded,
                                                      color: primaryBlue,
                                                      size: 20,
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Gateway name and optional recommended badge
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText(
                                                  text: gateway.isCard
                                                      ? gateway.gateway
                                                          .toString()
                                                      : gatewayName,
                                                  textStyle: TextStyle(
                                                    color: titleColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (gateway.isCard) ...[
                                                  const SizedBox(height: 2),
                                                  MyText(
                                                    text:
                                                        '**** **** **** ${gateway.gateway.toString().substring(gateway.gateway.toString().length >= 4 ? gateway.gateway.toString().length - 4 : 0)}',
                                                    textStyle: TextStyle(
                                                      color: subtitleColor,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          // Radio button
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                width: isSelected ? 6 : 2,
                                                color: isSelected
                                                    ? primaryBlue
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF475569)
                                                        : const Color(
                                                            0xFFCBD5E1)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),

                      // Bottom action panel
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          border: Border(
                            top: BorderSide(color: cardBorder, width: 1),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () async {
                                if (!walletPaymentGatways[context
                                        .read<AccBloc>()
                                        .choosenPaymentIndex!]
                                    .isCard) {
                                  context.read<AccBloc>().add(
                                        WalletPageReUpdateEvent(
                                          currencySymbol: currencySymbol,
                                          from: '',
                                          requestId: '',
                                          planId: '',
                                          money: amount,
                                          url: walletPaymentGatways[context
                                                  .read<AccBloc>()
                                                  .choosenPaymentIndex!]
                                              .url,
                                          userId: userData!.userId.toString(),
                                        ),
                                      );
                                } else {
                                  context.read<AccBloc>().add(
                                      AddMoneyFromCardEvent(
                                          amount:
                                              context
                                                  .read<AccBloc>()
                                                  .addMoney
                                                  .toString(),
                                          cardToken: walletPaymentGatways[
                                                  context
                                                      .read<AccBloc>()
                                                      .choosenPaymentIndex!]
                                              .url));
                                }
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: double.infinity,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: MyText(
                                  text: AppLocalizations.of(context)!.pay,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: subtitleColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .yourPaymentInfoSecureText,
                                  textStyle: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox();
      }),
    );
  }

  Widget _getCardImage(String imageString, Size size) {
    final imageLower = imageString.toLowerCase();

    if (imageLower.contains('visa')) {
      return Image.asset(AppImages.visa, fit: BoxFit.contain);
    } else if (imageLower.contains('eftpos')) {
      return Image.asset(AppImages.eftpos, fit: BoxFit.contain);
    } else if (imageLower.contains('american')) {
      return Image.asset(AppImages.americanExpress, fit: BoxFit.contain);
    } else if (imageLower.contains('jcb')) {
      return Image.asset(AppImages.jcb, fit: BoxFit.contain);
    } else if (imageLower.contains('discover') ||
        imageLower.contains('dinners')) {
      return Image.asset(AppImages.discover, fit: BoxFit.contain);
    } else {
      return Image.asset(AppImages.master, fit: BoxFit.contain);
    }
  }
}
