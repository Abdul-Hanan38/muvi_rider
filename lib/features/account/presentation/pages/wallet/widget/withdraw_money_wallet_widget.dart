import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WithdrawMoneyWalletWidget extends StatelessWidget {
  final BuildContext cont;
  final String minWalletAmount;
  const WithdrawMoneyWalletWidget(
      {super.key, required this.cont, required this.minWalletAmount});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF0A0F1D) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return SafeArea(
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.05),
                  topRight: Radius.circular(size.width * 0.05),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.05,
                  size.width * 0.03,
                  size.width * 0.05,
                  size.width * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Drag handle pill
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    // Header
                    MyText(
                      text: AppLocalizations.of(context)!.withdraw,
                      textStyle: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    MyText(
                      text:
                          AppLocalizations.of(context)!.withdrawalMoneySubText,
                      textStyle: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Amount Input Container
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131B2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Left Currency Badge
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFFDBEAFE),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: MyText(
                              text: userData!.currencySymbol.toString(),
                              textStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF1D4ED8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // TextField
                          Expanded(
                            child: TextField(
                              controller: context
                                  .read<AccBloc>()
                                  .withdrawAmountController,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  context.read<AccBloc>().addMoney =
                                      double.tryParse(value) ?? 0.0;
                                } else {
                                  context.read<AccBloc>().addMoney = 0.0;
                                }
                              },
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    AppLocalizations.of(context)!.enterAmount,
                                hintStyle: TextStyle(
                                  color: textSecondary.withOpacity(0.7),
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          // Suffix
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: MyText(
                              text: ".00",
                              textStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Select Section
                    MyText(
                      text: AppLocalizations.of(context)!.quickSelectText,
                      textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [1, 2, 3].map((multiplier) {
                        final double selectAmount =
                            double.parse(minWalletAmount) * multiplier;
                        final String amountText = selectAmount % 1 == 0
                            ? selectAmount.toInt().toString()
                            : selectAmount.toStringAsFixed(2);

                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: multiplier == 3 ? 0 : 12.0,
                            ),
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<AccBloc>()
                                    .withdrawAmountController
                                    .text = selectAmount.toInt().toString();
                                context.read<AccBloc>().addMoney = selectAmount;
                              },
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131B2E)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: isDark
                                          ? const Color(0xFF3B82F6)
                                          : const Color(0xFF003CC9),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    MyText(
                                      text:
                                          "${userData!.currencySymbol} $amountText",
                                      textStyle: TextStyle(
                                        color: textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Info Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B).withOpacity(0.4)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFDBEAFE),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyText(
                              text: AppLocalizations.of(context)!
                                  .withdrawalProcessedLinkedBankText,
                              textStyle: TextStyle(
                                color: textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: MyText(
                                text: AppLocalizations.of(context)!.cancel,
                                textStyle: TextStyle(
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Withdraw
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if (context
                                      .read<AccBloc>()
                                      .withdrawAmountController
                                      .text
                                      .isNotEmpty &&
                                  double.parse(context
                                          .read<AccBloc>()
                                          .withdrawResponse!
                                          .walletBalance) >=
                                      double.parse(context
                                          .read<AccBloc>()
                                          .withdrawAmountController
                                          .text)) {
                                context.read<AccBloc>().add(
                                    RequestWithdrawEvent(
                                        amount: context
                                            .read<AccBloc>()
                                            .withdrawAmountController
                                            .text));
                              } else {
                                context.showSnackBar(
                                    color: AppColors.red,
                                    message: AppLocalizations.of(context)!
                                        .insufficientWithdraw);
                              }
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                              ),
                              alignment: Alignment.center,
                              child: MyText(
                                text: AppLocalizations.of(context)!.withdraw,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Security Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: textSecondary,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .secureEncrypedTransactionText,
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
