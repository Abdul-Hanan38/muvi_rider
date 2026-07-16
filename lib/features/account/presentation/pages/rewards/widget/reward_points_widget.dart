import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class RewardPointsWidget extends StatelessWidget {
  final BuildContext cont;
  const RewardPointsWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dialogBgColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final hintTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final redeemRateText = AppLocalizations.of(context)!
              .redeemRateText
              .replaceAll("*",
                  userData!.loyaltyPoints!.data.conversionQuotient.toString())
              .replaceAll("z", userData!.currencySymbol);

          final redeemedAmountRaw =
              AppLocalizations.of(context)!.redeemedAmount;
          final redeemedAmountLabel = redeemedAmountRaw.contains(':')
              ? redeemedAmountRaw.split(':').first.trim()
              : redeemedAmountRaw
                  .replaceAll(':s*', '')
                  .replaceAll('s*', '')
                  .trim();

          return AlertDialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: 24,
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: size.width,
              child: Stack(
                children: [
                  // Main Scrollable Content
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        size.width * 0.06,
                        size.width * 0.08,
                        size.width * 0.06,
                        size.width * 0.06,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sparkle Wallet Icon Container
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF6FF),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.wallet_outlined,
                                    size: 36,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  // Top-Right Sparkle
                                  Positioned(
                                    top: 14,
                                    right: 14,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 10,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                  // Bottom-Left Sparkle
                                  Positioned(
                                    bottom: 14,
                                    left: 14,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      size: 8,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Header Title
                          MyText(
                            text: AppLocalizations.of(context)!
                                .redeemPointsToWallet,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 18,
                                  color: textDarkColor,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),

                          // Conversion Subtitle
                          MyText(
                            text: redeemRateText,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 14,
                                  color: hintTextColor,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Enter points label
                          MyText(
                            text: AppLocalizations.of(context)!
                                .enterPointsToRedeem,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Input Text Field
                          CustomTextField(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            controller:
                                context.read<AccBloc>().rewardAmountController,
                            maxLine: 1,
                            onChange: (value) {
                              context.read<AccBloc>().addRewardMoney =
                                  int.tryParse(value);
                              double? redeemedAmount = (int.tryParse(context
                                          .read<AccBloc>()
                                          .rewardAmountController
                                          .text) ??
                                      0) /
                                  userData!
                                      .loyaltyPoints!.data.conversionQuotient;
                              context.read<AccBloc>().add(
                                    UpdateRedeemedAmountEvent(
                                      redeemedAmount: redeemedAmount,
                                    ),
                                  );
                            },
                            keyboardType: TextInputType.number,
                            hintText: "e.g. 100",
                            hintTextStyle: TextStyle(
                              fontSize: 14,
                              color: hintTextColor.withOpacity(0.6),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              color: textDarkColor,
                            ),
                            prefixIcon: Icon(
                              Icons.star_outline_rounded,
                              color: hintTextColor,
                            ),
                            fillColor: isDark
                                ? const Color(0xFF1E293B).withOpacity(0.3)
                                : Colors.transparent,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : AppColors.borderColors,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : AppColors.borderColors,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // Quick Select Options (If points > 1000)
                          if (userData!
                                  .loyaltyPoints!.data.balanceRewardPoints >
                              1000) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: ['100', '200', '300'].map((val) {
                                final points = int.parse(val);
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: InkWell(
                                      onTap: () {
                                        context
                                            .read<AccBloc>()
                                            .rewardAmountController
                                            .text = val;
                                        context.read<AccBloc>().addRewardMoney =
                                            points;
                                        context.read<AccBloc>().add(
                                              UpdateRedeemedAmountEvent(
                                                redeemedAmount: points /
                                                    userData!
                                                        .loyaltyPoints!
                                                        .data
                                                        .conversionQuotient,
                                              ),
                                            );
                                      },
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF1E293B)
                                                : AppColors.borderColors,
                                            width: 1,
                                          ),
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                                  .withOpacity(0.5)
                                              : const Color(0xFFF8F9FC),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        alignment: Alignment.center,
                                        child: MyText(
                                          text: val,
                                          textStyle: TextStyle(
                                            color: textDarkColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Redeemed Amount Container
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withOpacity(0.5)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MyText(
                                    text: redeemedAmountLabel,
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                MyText(
                                  text:
                                      "${userData!.currencySymbol} ${context.read<AccBloc>().redeemedAmount}",
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Redeem Button
                          CustomButton(
                            buttonName:
                                AppLocalizations.of(context)!.redeemPoints,
                            buttonColor: AppColors.buttonColor,
                            width: size.width,
                            height: 52,
                            borderRadius: 12,
                            textSize: 16,
                            onTap: () {
                              if ((context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text
                                      .isEmpty &&
                                  context.read<AccBloc>().addRewardMoney ==
                                      null)) {
                                showToast(
                                    message: AppLocalizations.of(context)!
                                        .enterRequiredField);
                              } else if (context
                                      .read<AccBloc>()
                                      .rewardAmountController
                                      .text
                                      .isNotEmpty &&
                                  int.tryParse(context
                                          .read<AccBloc>()
                                          .rewardAmountController
                                          .text)! <
                                      userData!.loyaltyPoints!.data
                                          .minimumRewardPoints) {
                                showToast(
                                    message: AppLocalizations.of(context)!
                                        .rewardsGreaterText);
                              } else {
                                Navigator.of(context).pop();
                                context.read<AccBloc>().add(
                                      RedeemPointsEvent(
                                        amount: context
                                            .read<AccBloc>()
                                            .rewardAmountController
                                            .text,
                                      ),
                                    );
                                context
                                    .read<AccBloc>()
                                    .rewardAmountController
                                    .clear();
                              }
                            },
                          ),
                        ],
                      ),
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
