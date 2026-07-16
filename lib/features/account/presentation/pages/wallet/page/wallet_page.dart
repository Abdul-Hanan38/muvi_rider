// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/page/withdraw_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/wallet/widget/wallet_shimmer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/add_money_wallet.dart';
import '../widget/card_list_widget.dart';
import '../widget/wallet_history_data_widget.dart';
import '../widget/wallet_transfer_money_widget.dart';

class WalletHistoryPage extends StatelessWidget {
  static const String routeName = '/walletHistory';

  const WalletHistoryPage({
    super.key,
  });

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

    // AccBloc is provided as a singleton via BlocProvider.value in app_routes.dart
    // so we never create a new bloc here (which would fire duplicate API calls).
    return BlocListener<AccBloc, AccState>(
      listener: (context, state) async {
        final accBloc = context.read<AccBloc>();
        if (state is AuthInitialState) {
          CustomLoader.loader(context);
        } else if (state is MoneyTransferedSuccessState) {
          Navigator.pop(context);
        } else if (state is WalletPageReUpdateState) {
          accBloc.showRefresh = true;
          Navigator.of(context, rootNavigator: true).popUntil((route) =>
              route.isFirst ||
              route.settings.name == WalletHistoryPage.routeName);
          accBloc.add(
            AddMoneyWebViewUrlEvent(
              currencySymbol: state.currencySymbol,
              from: '',
              requestId: state.requestId,
              planId: '',
              money: state.money,
              url: state.url,
              userId: state.userId,
              context: context,
            ),
          );
        } else if (state is UserUnauthenticatedState) {
          await AppSharedPreference.getUserType();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.routeName,
            (route) => false,
          );
        } else if (state is PaymentUpdateState) {
          debugPrint('PaymentUpdateState: ${state.status}');

          if (!context.mounted) return;

          // 1️⃣ Close any open bottom sheet / webview safely
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          if (state.status) {
            // 2️⃣ SUCCESS → Refresh wallet only
            final accBloc = context.read<AccBloc>();

            accBloc.showRefresh = false;
            accBloc.resetWalletFreshness();
            accBloc.add(GetWalletInitEvent(forceRefresh: true));

            //  DO NOT navigate to WalletHistoryPage again
          } else {
            // 3️⃣ FAILURE → Show dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return AlertDialog(
                  content: SizedBox(
                    height: size.height * 0.45,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.paymentFail,
                          width: size.width * 0.4,
                        ),
                        SizedBox(height: size.width * 0.02),
                        MyText(
                          text:
                              AppLocalizations.of(dialogContext)!.paymentFailed,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: size.width * 0.03),
                        CustomButton(
                          buttonName: AppLocalizations.of(dialogContext)!.ok,
                          width: size.width * 0.4,
                          height: size.width * 0.12,
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        } else if (state is BankUpdateSuccessState) {
          context.read<AccBloc>().add(GetWithdrawInitEvent());
        }
      },
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        final accBloc = context.read<AccBloc>();
        return SafeArea(
          child: Scaffold(
            backgroundColor: pageBg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.wallet,
                textStyle: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () {
                Future<void> onrefresh() async {
                  accBloc.resetWalletFreshness();
                  accBloc.add(GetWalletInitEvent(forceRefresh: true));
                }

                return onrefresh();
              },
              child: SingleChildScrollView(
                controller: accBloc.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  constraints: BoxConstraints(minHeight: size.height),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Refresh Button
                      if (accBloc.showRefresh)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.03),
                            child: InkWell(
                              onTap: () {
                                accBloc.showRefresh = false;
                                accBloc.add(
                                    GetWalletHistoryListEvent(pageIndex: 1));
                              },
                              child: Column(
                                children: [
                                  Icon(Icons.refresh_outlined,
                                      size: 28, color: textSecondary),
                                  SizedBox(height: size.width * 0.01),
                                  MyText(
                                    text: AppLocalizations.of(context)!.refresh,
                                    textStyle: TextStyle(
                                        color: textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      // ─── Wallet Balance Card ───────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          size.width * 0.04,
                          size.width * 0.02,
                          size.width * 0.04,
                          size.width * 0.04,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isDark
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF1A3A8F),
                                      Color(0xFF0F1F5C),
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
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Decorative wave circles
                              Positioned(
                                right: -20,
                                top: -20,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.07),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 40,
                                bottom: -30,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                              ),
                              // Card content
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.06,
                                  horizontal: size.width * 0.05,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .walletBalance,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ValueListenableBuilder<bool>(
                                          valueListenable: showBalance,
                                          builder: (_, visible, __) =>
                                              GestureDetector(
                                            onTap: () => showBalance.value =
                                                !showBalance.value,
                                            child: Icon(
                                              visible
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.width * 0.03),
                                    if (accBloc.isLoading && !accBloc.loadMore)
                                      SizedBox(
                                        height: size.width * 0.08,
                                        width: size.width * 0.08,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else if (accBloc.walletResponse != null)
                                      ValueListenableBuilder<bool>(
                                        valueListenable: showBalance,
                                        builder: (_, visible, __) => Text(
                                          visible
                                              ? '${accBloc.walletResponse!.currencySymbol} ${double.tryParse(accBloc.walletResponse!.walletBalance) != null ? double.tryParse(accBloc.walletResponse!.walletBalance)!.toStringAsFixed(2) : accBloc.walletResponse!.walletBalance}'
                                              : '••••••',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
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

                      // ─── Quick Action Buttons ──────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          size.width * 0.04,
                          0,
                          size.width * 0.04,
                          size.width * 0.04,
                        ),
                        child: Row(
                          children: [
                            if (userData!
                                    .showWalletAddMoneyFeatureOnMobileApp ==
                                '1') ...[
                              Expanded(
                                child: _buildActionButton(
                                  context: context,
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  cardBorder: cardBorder,
                                  textPrimary: isDark
                                      ? textPrimary
                                      : const Color(0xFF1A3A8F),
                                  label: AppLocalizations.of(context)!.addMoney,
                                  icon: Icons.account_balance_wallet_outlined,
                                  iconColor: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  onPressed: () {
                                    context
                                        .read<AccBloc>()
                                        .walletAmountController
                                        .clear();
                                    context.read<AccBloc>().addMoney = null;
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      isDismissible: true,
                                      useSafeArea: true,
                                      backgroundColor: AppColors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                      ),
                                      builder: (_) {
                                        return FractionallySizedBox(
                                          heightFactor: 1.0,
                                          child: AddMoneyWalletWidget(
                                            cont: context,
                                            minWalletAmount: context
                                                .read<AccBloc>()
                                                .walletResponse!
                                                .minimumAmountAddedToWallet,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: size.width * 0.03),
                            ],
                            Expanded(
                              child: _buildActionButton(
                                context: context,
                                isDark: isDark,
                                cardBg: cardBg,
                                cardBorder: cardBorder,
                                textPrimary: textPrimary,
                                label: AppLocalizations.of(context)!.withdraw,
                                icon: Icons.move_to_inbox_outlined,
                                iconColor: isDark
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF059669),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    WithdrawPage.routeName,
                                    arguments: WithdrawPageArguments(
                                      minWalletAmount: context
                                          .read<AccBloc>()
                                          .walletResponse!
                                          .minimumAmountAddedToWallet,
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (userData!
                                    .showWalletMoneyTransferFeatureOnMobileApp ==
                                '1') ...[
                              SizedBox(width: size.width * 0.03),
                              Expanded(
                                child: _buildActionButton(
                                  context: context,
                                  isDark: isDark,
                                  cardBg: cardBg,
                                  cardBorder: cardBorder,
                                  textPrimary: textPrimary,
                                  label: AppLocalizations.of(context)!
                                      .transferText,
                                  icon: Icons.open_in_new_rounded,
                                  iconColor: isDark
                                      ? const Color(0xFFA78BFA)
                                      : const Color(0xFF7C3AED),
                                  onPressed: () {
                                    context
                                        .read<AccBloc>()
                                        .transferAmount
                                        .clear();
                                    context
                                        .read<AccBloc>()
                                        .transferPhonenumber
                                        .clear();
                                    context.read<AccBloc>().dropdownValue =
                                        'user';
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      isDismissible: true,
                                      builder: (_) {
                                        return WalletTransferMoneyWidget(
                                            cont: context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ─── Saved Cards Section ───────────────────────────
                      if (context.read<AccBloc>().walletResponse != null &&
                          context
                              .read<AccBloc>()
                              .walletResponse!
                              .enableSaveCard)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .savedCards,
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        CardListWidget.routeName,
                                        arguments: PaymentMethodArguments(
                                            userData: userData!),
                                      ).then((value) {
                                        if (!context.mounted) return;
                                        context.read<AccBloc>().add(
                                            GetWalletHistoryListEvent(
                                                pageIndex: 1));
                                        context
                                            .read<AccBloc>()
                                            .add(CardListEvent());
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.viewAll,
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.secondary
                                                : AppColors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: isDark
                                              ? AppColors.secondary
                                              : AppColors.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.width * 0.03),
                              // No cards empty state
                              if (context
                                  .read<AccBloc>()
                                  .savedCardsList
                                  .isEmpty)
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border:
                                        Border.all(color: cardBorder, width: 1),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 28, horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Card stack illustration
                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                            width: 90,
                                            height: 58,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFDCE4F2),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 10),
                                                Container(
                                                  height: 12,
                                                  color: isDark
                                                      ? const Color(0xFF0F172A)
                                                      : const Color(0xFFB0C2DE),
                                                ),
                                                const Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 14,
                                                        height: 8,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.6),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Container(
                                                        width: 24,
                                                        height: 6,
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.4),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: -4,
                                            bottom: -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                                border: Border.all(
                                                    color: cardBg, width: 2),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .noCardsAdded,
                                        textStyle: TextStyle(
                                          color: textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .noCardsAdded,
                                        textAlign: TextAlign.center,
                                        textStyle: TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: double.infinity,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              CardListWidget.routeName,
                                              arguments: PaymentMethodArguments(
                                                  userData: userData!),
                                            ).then((value) {
                                              if (!context.mounted) return;
                                              context.read<AccBloc>().add(
                                                  GetWalletHistoryListEvent(
                                                      pageIndex: 1));
                                              context
                                                  .read<AccBloc>()
                                                  .add(CardListEvent());
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              gradient: isDark
                                                  ? const LinearGradient(
                                                      colors: [
                                                        AppColors.primary,
                                                        AppColors.secondary,
                                                      ],
                                                    )
                                                  : const LinearGradient(
                                                      colors: [
                                                        AppColors.primary,
                                                        AppColors.secondary,
                                                      ],
                                                    ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Spacer(),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .addACard,
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    color: isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary,
                                                    size: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: context
                                      .read<AccBloc>()
                                      .savedCardsList
                                      .length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: size.width * 0.02),
                                  itemBuilder: (context, index) {
                                    final card = context
                                        .read<AccBloc>()
                                        .savedCardsList
                                        .elementAt(index);
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.primary,
                                            AppColors.secondary,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Image.asset(
                                                AppImages.simCard,
                                                height: size.width * 0.1,
                                                width: size.width * 0.1,
                                              ),
                                              Image.asset(
                                                (card.cardType
                                                        .toLowerCase()
                                                        .contains('visa'))
                                                    ? AppImages.visa
                                                    : (card.cardType
                                                            .toLowerCase()
                                                            .contains('eftpos'))
                                                        ? AppImages.eftpos
                                                        : (card.cardType
                                                                .toLowerCase()
                                                                .contains(
                                                                    'american'))
                                                            ? AppImages
                                                                .americanExpress
                                                            : (card.cardType
                                                                    .toLowerCase()
                                                                    .contains(
                                                                        'jcb'))
                                                                ? AppImages.jcb
                                                                : (card.cardType
                                                                        .toLowerCase()
                                                                        .contains(
                                                                            'discover || dinners'))
                                                                    ? AppImages
                                                                        .discover
                                                                    : AppImages
                                                                        .master,
                                                height: size.width * 0.1,
                                                width: size.width * 0.2,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.width * 0.04),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              MyText(
                                                text:
                                                    '**** **** **** ${card.lastNumber}',
                                                textStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: size.width * 0.05,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),

                      SizedBox(height: size.width * 0.05),

                      // ─── Recent Transactions Section ───────────────────
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .recentTransactions,
                              textStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.width * 0.03),

                      // Transaction List
                      if (context.read<AccBloc>().isLoading &&
                          context.read<AccBloc>().firstLoad)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return ShimmerWalletHistory(size: size);
                            },
                          ),
                        )
                      else if (context
                          .read<AccBloc>()
                          .walletHistoryList
                          .isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: cardBorder, width: 1),
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: WalletHistoryDataWidget(
                                  walletHistoryList:
                                      context.read<AccBloc>().walletHistoryList,
                                  cont: context,
                                ),
                              ),
                              if (context.read<AccBloc>().loadMore)
                                Padding(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  child: const CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              else if (context
                                          .read<AccBloc>()
                                          .walletPaginations !=
                                      null &&
                                  context
                                          .read<AccBloc>()
                                          .walletPaginations!
                                          .pagination
                                          .currentPage <
                                      context
                                          .read<AccBloc>()
                                          .walletPaginations!
                                          .pagination
                                          .totalPages)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: size.width * 0.02),
                                  child: InkWell(
                                    onTap: () {
                                      final accBloc = context.read<AccBloc>();
                                      accBloc.loadMore = true;
                                      accBloc.add(UpdateEvent());
                                      accBloc.add(GetWalletHistoryListEvent(
                                          pageIndex: accBloc.walletPaginations!
                                                  .pagination.currentPage +
                                              1));
                                    },
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .loadMore,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: size.width * 0.2),
                            child: Column(
                              children: [
                                Image.asset(
                                  AppImages.noWalletHistoryImage,
                                  height: size.width * 0.5,
                                ),
                                SizedBox(height: size.width * 0.05),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .noWalletHistory,
                                  textStyle: TextStyle(
                                    color: textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: size.width * 0.05),

                      // ─── Payment Methods Section ───────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(size.width * 0.04, 0,
                            size.width * 0.04, size.width * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text:
                                  AppLocalizations.of(context)!.paymentMethods,
                              textStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: size.width * 0.03),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cardBorder, width: 1),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              padding: EdgeInsets.all(size.width * 0.04),
                              child: Builder(
                                builder: (_) {
                                  final bankDetails =
                                      context.read<AccBloc>().bankDetails;
                                  final hasAny = bankDetails
                                      .where((e) =>
                                          e['driver_bank_info']['data']
                                              .toString() !=
                                          '[]')
                                      .isNotEmpty;
                                  if (bankDetails.isEmpty || !hasAny) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_balance_outlined,
                                          size: 48,
                                          color: textSecondary,
                                        ),
                                        SizedBox(height: size.width * 0.03),
                                        SizedBox(
                                          width: size.width * 0.8,
                                          child: MyText(
                                            text: AppLocalizations.of(context)!
                                                .noPaymentMethodLink,
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: textSecondary,
                                            ),
                                            maxLines: 3,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: bankDetails.length,
                                    separatorBuilder: (_, __) =>
                                        Divider(height: 1, color: cardBorder),
                                    itemBuilder: (_, i) {
                                      final bank = bankDetails.elementAt(i);
                                      final hasData = bank['driver_bank_info']
                                                  ['data']
                                              .toString() !=
                                          '[]';
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.pushNamed(
                                            context,
                                            WithdrawPage.routeName,
                                            arguments: WithdrawPageArguments(
                                              minWalletAmount: context
                                                  .read<AccBloc>()
                                                  .walletResponse!
                                                  .minimumAmountAddedToWallet,
                                              initialBankIndex: i,
                                              openEdit: hasData,
                                            ),
                                          ).then((_) {
                                            if (!context.mounted) return;
                                            context
                                                .read<AccBloc>()
                                                .add(GetWithdrawInitEvent());
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: size.width * 0.035),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFFEFF6FF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.account_balance_rounded,
                                                  color: isDark
                                                      ? AppColors.secondary
                                                      : AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: MyText(
                                                  text: bank['method_name'],
                                                  textStyle: TextStyle(
                                                    color: textPrimary,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                hasData
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .textView
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .textAdd,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? AppColors.secondary
                                                      : AppColors.primary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: size.width * 0.03),
                            BlocBuilder<AccBloc, AccState>(
                              builder: (context, state) {
                                final acc = context.read<AccBloc>();
                                final hasAnyLinked = acc.bankDetails.any((e) =>
                                    e['driver_bank_info']['data'].toString() !=
                                    '[]');
                                if (hasAnyLinked) {
                                  return const SizedBox.shrink();
                                }
                                void showMethodsSheet() {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (_) {
                                      return BlocBuilder<AccBloc, AccState>(
                                        builder: (_, state) {
                                          return SafeArea(
                                            child: Container(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              width: size.width,
                                              padding: EdgeInsets.all(
                                                  size.width * 0.05),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: size.width * 0.9,
                                                    child: MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .paymentMethods,
                                                      textStyle:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyLarge!
                                                              .copyWith(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark,
                                                              ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.05),
                                                  if (context
                                                      .read<AccBloc>()
                                                      .bankDetails
                                                      .isNotEmpty)
                                                    ListView.builder(
                                                      itemCount: context
                                                          .read<AccBloc>()
                                                          .bankDetails
                                                          .length,
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      padding: EdgeInsets.zero,
                                                      itemBuilder: (_, i) {
                                                        final bank = context
                                                            .read<AccBloc>()
                                                            .bankDetails
                                                            .elementAt(i);
                                                        final hasData =
                                                            bank['driver_bank_info']
                                                                        ['data']
                                                                    .toString() !=
                                                                '[]';
                                                        return InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pushNamed(
                                                              context,
                                                              WithdrawPage
                                                                  .routeName,
                                                              arguments:
                                                                  WithdrawPageArguments(
                                                                minWalletAmount: context
                                                                    .read<
                                                                        AccBloc>()
                                                                    .walletResponse!
                                                                    .minimumAmountAddedToWallet,
                                                                initialBankIndex:
                                                                    i,
                                                                openEdit:
                                                                    hasData,
                                                              ),
                                                            ).then((result) {
                                                              if (!context
                                                                  .mounted)
                                                                return;
                                                              acc.add(
                                                                  GetWithdrawInitEvent());
                                                              if (result ==
                                                                  true) {
                                                                // After successful update, re-open sheet to reflect changes
                                                                WidgetsBinding
                                                                    .instance
                                                                    .addPostFrameCallback(
                                                                        (_) {
                                                                  showMethodsSheet();
                                                                });
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            width: size.width *
                                                                0.9,
                                                            margin: EdgeInsets.only(
                                                                bottom:
                                                                    size.width *
                                                                        0.025),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    size.width *
                                                                        0.05),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Theme.of(
                                                                      context)
                                                                  .disabledColor
                                                                  .withAlpha((0.3 *
                                                                          255)
                                                                      .toInt()),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: MyText(
                                                                    text: bank[
                                                                        'method_name'],
                                                                    textStyle: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyLarge!
                                                                        .copyWith(
                                                                          color:
                                                                              Theme.of(context).primaryColorDark,
                                                                        ),
                                                                  ),
                                                                ),
                                                                MyText(
                                                                  text: hasData
                                                                      ? AppLocalizations.of(
                                                                              context)!
                                                                          .textView
                                                                      : AppLocalizations.of(
                                                                              context)!
                                                                          .textAdd,
                                                                  textStyle: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                        color: Theme.of(context)
                                                                            .primaryColorDark,
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.08),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }

                                return CustomButton(
                                  buttonName: AppLocalizations.of(context)!
                                      .linkBankAccount,
                                  onTap: () {
                                    final banks = acc.bankDetails;
                                    if (banks.isEmpty) {
                                      acc.add(GetWithdrawInitEvent());
                                      return;
                                    }
                                    showMethodsSheet();
                                  },
                                  width: double.infinity,
                                  height: size.width * 0.12,
                                  buttonColor: const Color(0xFF0D47A1),
                                  textColor: AppColors.white,
                                  textSize: 16,
                                  borderRadius: 8,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ─── Security Footer ───────────────────────────────
                      Padding(
                        padding: EdgeInsets.fromLTRB(size.width * 0.04, 0,
                            size.width * 0.04, size.width * 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .walletYourTranslationAreSafeText,
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
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
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required String label,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: 10),
            MyText(
              text: label,
              textAlign: TextAlign.center,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
