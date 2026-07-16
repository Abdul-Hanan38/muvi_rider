import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/widget/wallet_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../widget/withdraw_history_data_widget.dart';
import '../widget/withdraw_money_wallet_widget.dart';

class WithdrawPage extends StatelessWidget {
  static const String routeName = '/withdrawPage';
  final WithdrawPageArguments arg;
  const WithdrawPage({super.key, required this.arg});

  Widget _buildUpiLogo() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785, // 45 degrees
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final ValueNotifier<bool> showBalance = ValueNotifier<bool>(true);
    return BlocProvider(
      create: (context) => AccBloc()..add(GetWithdrawInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is WithdrawDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is WithdrawDataLoadingStopState) {
            CustomLoader.dismiss(context);
            final acc = context.read<AccBloc>();
            if (arg.initialBankIndex != null &&
                arg.initialBankIndex! >= 0 &&
                acc.bankDetails.isNotEmpty &&
                arg.initialBankIndex! < acc.bankDetails.length &&
                acc.addBankInfo == false &&
                acc.editBank == false) {
              final idx = arg.initialBankIndex!;
              final hasData =
                  acc.bankDetails[idx]['driver_bank_info']['data'].toString() !=
                      '[]';
              final openEdit = arg.openEdit == true;
              if (openEdit && hasData) {
                acc.add(EditBankEvent(choosen: idx));
              } else {
                acc.add(AddBankEvent(choosen: idx));
              }
            }
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          } else if (state is BankUpdateSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.paymentMethodSuccess)),
            );
            Navigator.pop(context, true);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final acc = context.read<AccBloc>();
          if (arg.initialBankIndex != null &&
              acc.bankDetails.isNotEmpty &&
              arg.initialBankIndex! >= 0 &&
              arg.initialBankIndex! < acc.bankDetails.length &&
              acc.addBankInfo == false &&
              acc.editBank == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (acc.addBankInfo || acc.editBank) return;
              final idx = arg.initialBankIndex!;
              final hasData =
                  acc.bankDetails[idx]['driver_bank_info']['data'].toString() !=
                      '[]';
              final openEdit = arg.openEdit == true;
              if (openEdit && hasData) {
                acc.add(EditBankEvent(choosen: idx));
              } else {
                acc.add(AddBankEvent(choosen: idx));
              }
            });
          }
          return Scaffold(
            backgroundColor: pageBg,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    size: 20,
                  ),
                ),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.recentWithdrawal,
                textStyle: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Scrollable content area:
                      Expanded(
                        child: SingleChildScrollView(
                          controller: acc.scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWalletBalanceCard(
                                context,
                                size,
                                acc,
                                isDark,
                                showBalance,
                                cardBg,
                                cardBorder,
                                textPrimary,
                                textSecondary,
                              ),
                              _buildRecentWithdrawalsSection(
                                context,
                                size,
                                acc,
                                isDark,
                                cardBg,
                                cardBorder,
                                textPrimary,
                                textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Pinned bottom area:
                      _buildSecureWarningBanner(isDark, cardBg, cardBorder,
                          textPrimary, textSecondary, size, context),
                      _buildRequestWithdrawalButton(
                        context: context,
                        size: size,
                        acc: acc,
                        isDark: isDark,
                        minWalletAmount: arg.minWalletAmount,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                      ),
                    ],
                  ),
                  if (context.read<AccBloc>().addBankInfo ||
                      (context.read<AccBloc>().editBank))
                    Positioned.fill(
                      child: Container(
                        color: pageBg,
                        child: Column(
                          children: [
                            // ─── Premium Gradient Header ────────────────────
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0F1B35),
                                          Color(0xFF131B2E),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                size.width * 0.05,
                                16,
                                size.width * 0.05,
                                28,
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Outer glow ring
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.2),
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      // Icon circle
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_rounded,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                      ),
                                      // Edit badge
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.edit_rounded,
                                            color: isDark
                                                ? AppColors.secondary
                                                : AppColors.primary,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.read<AccBloc>().editBank
                                        ? AppLocalizations.of(context)!
                                            .editBankDetails
                                        : AppLocalizations.of(context)!
                                            .bankDetails,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .withdrawalYourDetailsAreSecurelyText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.75),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ─── Scrollable Form Fields ──────────────────────
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  size.width * 0.05,
                                  24,
                                  size.width * 0.05,
                                  24,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section label
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.secondary
                                                : AppColors.primary,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .withdrawalAccountInformationText,
                                          textStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    // List of inputs
                                    if (context
                                        .read<AccBloc>()
                                        .choosenBankList
                                        .isNotEmpty)
                                      ListView.builder(
                                        itemCount: context
                                            .read<AccBloc>()
                                            .choosenBankList
                                            .length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        padding: EdgeInsets.zero,
                                        itemBuilder: (context, index) {
                                          final item = context
                                              .read<AccBloc>()
                                              .choosenBankList[index];
                                          final label =
                                              (item['placeholder'] ?? '')
                                                  .toString();
                                          final isRequired =
                                              item['is_required'].toString() ==
                                                  '1';
                                          final isUpi = label
                                                  .toLowerCase()
                                                  .contains('upi') ||
                                              label
                                                  .toLowerCase()
                                                  .contains('gpay');
                                          final isPhone = label
                                                  .toLowerCase()
                                                  .contains('mobile') ||
                                              label
                                                  .toLowerCase()
                                                  .contains('phone');

                                          Widget prefix;
                                          if (isUpi) {
                                            prefix = Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 12),
                                              child: _buildUpiLogo(),
                                            );
                                          } else if (isPhone) {
                                            prefix = Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 12),
                                              child: Icon(
                                                Icons.phone_rounded,
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                                size: 20,
                                              ),
                                            );
                                          } else {
                                            prefix = Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 12),
                                              child: Icon(
                                                Icons
                                                    .account_balance_wallet_rounded,
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                                size: 20,
                                              ),
                                            );
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: cardBg,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                    color: cardBorder,
                                                    width: 1),
                                                boxShadow: isDark
                                                    ? []
                                                    : [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                  alpha: 0.04),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      MyText(
                                                        text: label,
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: textSecondary,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                      if (isRequired)
                                                        const Text(
                                                          " *",
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFFEF4444),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  CustomTextField(
                                                    keyboardType:
                                                        item['input_field_type'] ==
                                                                "text"
                                                            ? TextInputType.text
                                                            : TextInputType
                                                                .number,
                                                    controller: context
                                                        .read<AccBloc>()
                                                        .bankDetailsText[index],
                                                    hintText:
                                                        "Enter $label here",
                                                    borderRadius: 10,
                                                    filled: true,
                                                    fillColor: isDark
                                                        ? const Color(
                                                            0xFF0D1524)
                                                        : const Color(
                                                            0xFFF8FAFC),
                                                    prefixIcon: prefix,
                                                    prefixConstraints:
                                                        const BoxConstraints(
                                                      minWidth: 48,
                                                      minHeight: 48,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: textPrimary,
                                                    ),
                                                    hintTextStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: textSecondary
                                                          .withOpacity(0.5),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 14),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF1E293B)
                                                            : const Color(
                                                                0xFFE2E8F0),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide: BorderSide(
                                                        color: isDark
                                                            ? AppColors
                                                                .secondary
                                                            : AppColors.primary,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    // Info tip card
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF0F2D5A)
                                                .withValues(alpha: 0.5)
                                            : const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.primary
                                                  .withValues(alpha: 0.4)
                                              : const Color(0xFFBFDBFE),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            color: isDark
                                                ? AppColors.secondary
                                                : AppColors.primary,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: MyText(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .withdrawalIncorrectBankDetailsText,
                                              textStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ─── Pinned Action Buttons ───────────────────────
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.05),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (context
                                                .read<AccBloc>()
                                                .editBank) {
                                              Navigator.pop(context);
                                              context.read<AccBloc>().add(
                                                  EditBankEvent(choosen: null));
                                            } else {
                                              Navigator.pop(context);
                                              context.read<AccBloc>().add(
                                                  AddBankEvent(choosen: null));
                                            }
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: AppColors.red,
                                                width: 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .cancel,
                                              textStyle: const TextStyle(
                                                color: AppColors.red,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            Map body = {
                                              "method_id": context
                                                      .read<AccBloc>()
                                                      .choosenBankList[0]
                                                  ['method_id'],
                                            };

                                            for (var i = 0;
                                                i <
                                                    context
                                                        .read<AccBloc>()
                                                        .choosenBankList
                                                        .length;
                                                i++) {
                                              if ((context
                                                              .read<AccBloc>()
                                                              .choosenBankList[
                                                                  i][
                                                                  'is_required']
                                                              .toString() ==
                                                          '1' &&
                                                      context
                                                          .read<AccBloc>()
                                                          .bankDetailsText[i]
                                                          .text
                                                          .isNotEmpty) ||
                                                  context
                                                      .read<AccBloc>()
                                                      .bankDetailsText[i]
                                                      .text
                                                      .isNotEmpty) {
                                                body["${context.read<AccBloc>().choosenBankList[i]['input_field_name']}"] =
                                                    context
                                                        .read<AccBloc>()
                                                        .bankDetailsText[i]
                                                        .text;
                                              } else if (context
                                                      .read<AccBloc>()
                                                      .choosenBankList[i]
                                                          ['is_required']
                                                      .toString() ==
                                                  '1') {
                                                showToast(
                                                    message: AppLocalizations
                                                            .of(context)!
                                                        .enterRequiredField);
                                                return;
                                              }
                                            }
                                            context.read<AccBloc>().add(
                                                UpdateBankDetailsEvent(
                                                    body: body));
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            alignment: Alignment.center,
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .confirm,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.width * 0.025,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        color: isDark
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF059669),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .withdrawalDataSafeText,
                                          textAlign: TextAlign.center,
                                          textStyle: TextStyle(
                                            color: textSecondary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWalletBalanceCard(
    BuildContext context,
    Size size,
    AccBloc acc,
    bool isDark,
    ValueNotifier<bool> showBalance,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.04),
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.width * 0.06,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF131B2E), Color(0xFF0F1626)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        border: isDark ? Border.all(color: cardBorder, width: 1) : null,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: AppLocalizations.of(context)!.walletBalance,
                textStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: showBalance,
                builder: (context, visible, _) {
                  return InkWell(
                    onTap: () => showBalance.value = !visible,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        visible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: size.width * 0.03),
          if (acc.isWithdrawLoading && !acc.loadWithdrawMore)
            SizedBox(
              height: size.width * 0.08,
              width: size.width * 0.08,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          else if (acc.withdrawResponse != null)
            ValueListenableBuilder<bool>(
              valueListenable: showBalance,
              builder: (context, visible, _) {
                final balanceStr = visible
                    ? '${userData!.currencySymbol}${acc.withdrawResponse!.walletBalance.toString()}'
                    : '${userData!.currencySymbol} ••••••';
                return MyText(
                  text: balanceStr,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          SizedBox(height: size.width * 0.05),
          InkWell(
            onTap: () => _showPaymentMethodsBottomSheet(
              context: context,
              size: size,
              acc: acc,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: size.width * 0.03),
              decoration: BoxDecoration(
                color: isDark ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDark
                    ? Border.all(color: const Color(0xFF1E3A8A), width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card_outlined,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  MyText(
                    text: AppLocalizations.of(context)!.updatePaymentMethod,
                    textStyle: TextStyle(
                      color: isDark ? AppColors.secondary : AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildRecentWithdrawalsSection(
    BuildContext context,
    Size size,
    AccBloc acc,
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      width: size.width,
      padding: EdgeInsets.fromLTRB(
        size.width * 0.04,
        size.width * 0.03,
        size.width * 0.04,
        size.width * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: AppLocalizations.of(context)!.recentWithdrawal,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.04),
          if (acc.isWithdrawLoading && acc.firstWithdrawLoad)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              itemBuilder: (context, index) {
                return ShimmerWalletHistory(size: size);
              },
            )
          else ...[
            WithdrawHistoryDataWidget(
              withdrawHistoryList: acc.withdrawData,
              cont: context,
            ),
            if (acc.loadWithdrawMore)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
                  child: SizedBox(
                    height: size.width * 0.06,
                    width: size.width * 0.06,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecureWarningBanner(
    bool isDark,
    Color cardBg,
    Color cardBorder,
    Color textPrimary,
    Color textSecondary,
    Size size,
    BuildContext context,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withOpacity(0.4)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDBEAFE),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: AppLocalizations.of(context)!
                      .withdrawalsLinkBankAccountText,
                  textStyle: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                MyText(
                  text: AppLocalizations.of(context)!
                      .withdrawalTransactionsSecureText,
                  textStyle: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestWithdrawalButton({
    required BuildContext context,
    required Size size,
    required AccBloc acc,
    required bool isDark,
    required dynamic minWalletAmount,
    required Color textPrimary,
    required Color textSecondary,
    required Color cardBg,
    required Color cardBorder,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: size.width * 0.04,
        right: size.width * 0.04,
        bottom: size.width * 0.04 + MediaQuery.of(context).padding.bottom,
        top: 8,
      ),
      child: InkWell(
        onTap: () {
          if (acc.bankDetails
              .where((e) => e['driver_bank_info']['data'].toString() != '[]')
              .isNotEmpty) {
            acc.withdrawAmountController.clear();
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (builder) {
                return WithdrawMoneyWalletWidget(
                  cont: context,
                  minWalletAmount: minWalletAmount,
                );
              },
            );
          } else {
            _showPaymentMethodsBottomSheet(
              context: context,
              size: size,
              acc: acc,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            );
          }
        },
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? AppColors.secondary : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: const Color(0xFF003CC9).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              MyText(
                text: AppLocalizations.of(context)!.requestWithdraw,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodsBottomSheet({
    required BuildContext context,
    required Size size,
    required AccBloc acc,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: acc,
          child: BlocBuilder<AccBloc, AccState>(
            builder: (context, state) {
              return Container(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.05,
                  size.width * 0.03,
                  size.width * 0.05,
                  size.width * 0.05 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        margin: EdgeInsets.only(bottom: size.width * 0.04),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    MyText(
                      text: AppLocalizations.of(context)!.paymentMethods,
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: size.width * 0.04),
                    if (acc.bankDetails.isNotEmpty)
                      ListView.builder(
                        itemCount: acc.bankDetails.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) {
                          final bank = acc.bankDetails[i];
                          final hasData =
                              bank['driver_bank_info']['data'].toString() !=
                                  '[]';
                          final String name =
                              (bank['method_name'] ?? '').toString();
                          final bool isGpay =
                              name.toLowerCase().contains('google') ||
                                  name.toLowerCase().contains('gpay');
                          final bool isPhonePay =
                              name.toLowerCase().contains('phone') ||
                                  name.toLowerCase().contains('paytm') ||
                                  name.toLowerCase().contains('pe');
                          final bool isBank =
                              name.toLowerCase().contains('bank');

                          Widget iconBadge;
                          if (isGpay) {
                            iconBadge = Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyText(
                                    text: "G",
                                    textStyle: TextStyle(
                                        color: Color(0xFF4285F4),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  MyText(
                                    text: "P",
                                    textStyle: TextStyle(
                                        color: Color(0xFFEA4335),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  MyText(
                                    text: "a",
                                    textStyle: TextStyle(
                                        color: Color(0xFFFBBC05),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  MyText(
                                    text: "y",
                                    textStyle: TextStyle(
                                        color: Color(0xFF34A853),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          } else if (isPhonePay) {
                            iconBadge = Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF2E1065)
                                    : const Color(0xFFFAF5FF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.phone_android_rounded,
                                color: isDark
                                    ? const Color(0xFFA78BFA)
                                    : const Color(0xFF7C3AED),
                                size: 20,
                              ),
                            );
                          } else if (isBank) {
                            iconBadge = Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.account_balance_rounded,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                size: 20,
                              ),
                            );
                          } else {
                            iconBadge = Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.credit_card_rounded,
                                color: textSecondary,
                                size: 20,
                              ),
                            );
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if (!hasData) {
                                acc.add(AddBankEvent(choosen: i));
                              } else {
                                acc.add(EditBankEvent(choosen: i));
                              }
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(bottom: size.width * 0.03),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF131B2E)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  iconBadge,
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MyText(
                                      text: name,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyText(
                                        text: !hasData
                                            ? AppLocalizations.of(context)!
                                                .textAdd
                                            : AppLocalizations.of(context)!
                                                .textView,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.secondary
                                              : AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12,
                                        color: isDark
                                            ? AppColors.secondary
                                            : AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),
                    // Lock Footer
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
                                .withdrawalPaymentInforText,
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
                    SizedBox(height: size.width * 0.1),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
