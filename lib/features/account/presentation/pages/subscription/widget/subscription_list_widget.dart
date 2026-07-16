import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/subcription_list_model.dart';
import 'payment_gateway_list.dart';
import 'subscription_shimmer.dart';

class SubscriptionListWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  final String currencySymbol;
  final List<SubscriptionData> subscriptionListDatas;
  const SubscriptionListWidget(
      {super.key,
      required this.cont,
      required this.subscriptionListDatas,
      required this.currencySymbol,
      required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
        final accBloc = context.read<AccBloc>();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF171A1F);
        final descColor =
            isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9095A1);
        final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

        return subscriptionListDatas.isNotEmpty
            ? SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (accBloc.showRefresh) ...[
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    accBloc.showRefresh = false;
                                    accBloc.add(GetWalletHistoryListEvent(
                                        pageIndex: 1));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.refresh_outlined),
                                        const SizedBox(height: 4),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .refresh,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall!,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            // 1. Choose your Subscription
                            Text(
                              '1. ${AppLocalizations.of(context)!.chooseYourSubscription}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // List of plans
                            ListView.builder(
                              itemCount: subscriptionListDatas.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemBuilder: (_, index) {
                                final plan = subscriptionListDatas[index];
                                final isSelected =
                                    accBloc.choosenPlanindex == index;
                                return InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                          SubscriptionOnTapEvent(
                                              selectedPlanIndex: index),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                              ? const Color(0xFF1E293B)
                                                  .withOpacity(0.2)
                                              : const Color(0xFFEFF6FF))
                                          : (isDark
                                              ? const Color(0xFF131E35)
                                              : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryColor
                                            : (isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : const Color(0xFFE2E8F0)),
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.04),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Custom Radio selection circle
                                        Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? primaryColor
                                                  : (isDark
                                                      ? const Color(0xFF475569)
                                                      : const Color(
                                                          0xFFCBD5E1)),
                                              width: isSelected ? 1 : 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: isSelected
                                              ? Container(
                                                  height: 8,
                                                  width: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),

                                        // Crown Icon inside circular container
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                primaryColor.withOpacity(0.1),
                                          ),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            AppImages.leaderBoardCrown,
                                            width: 24,
                                            height: 24,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Plan details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text:
                                                    '${plan.name} $currencySymbol ${plan.amount}',
                                                textStyle: TextStyle(
                                                  color: textColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: primaryColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  plan.description ?? '',
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Pinned Area
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF070D19)
                            : const Color(0xFFF8F9FC),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 2. Choose payment method
                          Text(
                            '2. ${AppLocalizations.of(context)!.choosePaymentMethod}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Horizontal payment options
                          Row(
                            children: [
                              // Card Method
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                          SubscriptionPaymentOnTapEvent(
                                              selectedPayIndex: 0),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          accBloc.choosenSubscriptionPayIndex ==
                                                  0
                                              ? (isDark
                                                  ? const Color(0xFF1E293B)
                                                      .withOpacity(0.2)
                                                  : const Color(0xFFEFF6FF))
                                              : (isDark
                                                  ? const Color(0xFF131E35)
                                                  : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            accBloc.choosenSubscriptionPayIndex ==
                                                    0
                                                ? primaryColor
                                                : (isDark
                                                    ? Colors.white
                                                        .withOpacity(0.08)
                                                    : const Color(0xFFE2E8F0)),
                                        width:
                                            accBloc.choosenSubscriptionPayIndex ==
                                                    0
                                                ? 1.5
                                                : 1.0,
                                      ),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.04),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Radio circle top right
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 18,
                                            width: 18,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  accBloc.choosenSubscriptionPayIndex ==
                                                          0
                                                      ? primaryColor
                                                      : Colors.transparent,
                                              border: Border.all(
                                                color:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            0
                                                        ? primaryColor
                                                        : (isDark
                                                            ? const Color(
                                                                0xFF475569)
                                                            : const Color(
                                                                0xFFCBD5E1)),
                                                width:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            0
                                                        ? 1
                                                        : 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child:
                                                accBloc.choosenSubscriptionPayIndex ==
                                                        0
                                                    ? Container(
                                                        height: 7,
                                                        width: 7,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : null,
                                          ),
                                        ),

                                        // Content Center
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.credit_card_outlined,
                                                size: 32,
                                                color:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            0
                                                        ? primaryColor
                                                        : descColor,
                                              ),
                                              const SizedBox(height: 8),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .card,
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
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
                              const SizedBox(width: 16),

                              // Wallet Method
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    context.read<AccBloc>().add(
                                          SubscriptionPaymentOnTapEvent(
                                              selectedPayIndex: 2),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 110,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          accBloc.choosenSubscriptionPayIndex ==
                                                  2
                                              ? (isDark
                                                  ? const Color(0xFF1E293B)
                                                      .withOpacity(0.2)
                                                  : const Color(0xFFEFF6FF))
                                              : (isDark
                                                  ? const Color(0xFF131E35)
                                                  : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            accBloc.choosenSubscriptionPayIndex ==
                                                    2
                                                ? primaryColor
                                                : (isDark
                                                    ? Colors.white
                                                        .withOpacity(0.08)
                                                    : const Color(0xFFE2E8F0)),
                                        width:
                                            accBloc.choosenSubscriptionPayIndex ==
                                                    2
                                                ? 1.5
                                                : 1.0,
                                      ),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.04),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                    ),
                                    child: Stack(
                                      children: [
                                        // Radio circle top right
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            height: 18,
                                            width: 18,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  accBloc.choosenSubscriptionPayIndex ==
                                                          2
                                                      ? primaryColor
                                                      : Colors.transparent,
                                              border: Border.all(
                                                color:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            2
                                                        ? primaryColor
                                                        : (isDark
                                                            ? const Color(
                                                                0xFF475569)
                                                            : const Color(
                                                                0xFFCBD5E1)),
                                                width:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            2
                                                        ? 1
                                                        : 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child:
                                                accBloc.choosenSubscriptionPayIndex ==
                                                        2
                                                    ? Container(
                                                        height: 7,
                                                        width: 7,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : null,
                                          ),
                                        ),

                                        // Content Center
                                        Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .account_balance_wallet_outlined,
                                                size: 32,
                                                color:
                                                    accBloc.choosenSubscriptionPayIndex ==
                                                            2
                                                        ? primaryColor
                                                        : descColor,
                                              ),
                                              const SizedBox(height: 8),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .wallet,
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: textColor,
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
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Confirm Button
                          InkWell(
                            onTap: () async {
                              if (accBloc.choosenSubscriptionPayIndex == 2) {
                                if (subscriptionListDatas[
                                            accBloc.choosenPlanindex]
                                        .amount! >=
                                    userData!.wallet!.data.amountBalance) {
                                  context
                                      .read<AccBloc>()
                                      .add(WalletEmptyEvent());
                                } else if (subscriptionListDatas[
                                            accBloc.choosenPlanindex]
                                        .amount! <=
                                    userData!.wallet!.data.amountBalance) {
                                  context.read<AccBloc>().add(
                                        SubscribeToPlanEvent(
                                          paymentOpt: accBloc
                                              .choosenSubscriptionPayIndex!,
                                          amount: (subscriptionListDatas[
                                                      accBloc.choosenPlanindex]
                                                  .amount!)
                                              .toInt(),
                                          planId: subscriptionListDatas[
                                                  accBloc.choosenPlanindex]
                                              .id!,
                                        ),
                                      );
                                }
                              } else if (accBloc.choosenSubscriptionPayIndex ==
                                  0) {
                                accBloc.walletAmountController.clear();
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: false,
                                  enableDrag: false,
                                  isDismissible: true,
                                  builder: (_) {
                                    return BlocProvider.value(
                                      value: context.read<AccBloc>(),
                                      child: PaymentGatewayListWidget(
                                        cont: context,
                                        walletPaymentGatways:
                                            accBloc.walletPaymentGatways,
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.confirm,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Positioned(
                                    right: 0,
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Security Disclaimer
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: descColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context)!
                                      .subscriptionPaymentText,
                                  style: TextStyle(
                                    color: descColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: EdgeInsets.only(
                  top: size.width * 0.05,
                ),
                child: SubscriptionShimmer(size: size),
              );
      }),
    );
  }
}
