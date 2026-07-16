import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/rewards/widget/reward_page_shimmer.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/reward_points_widget.dart';

class RewardsPage extends StatelessWidget {
  static const String routeName = '/driverRewardsPage';

  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(DriverRewardInitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UpdateRedeemedAmountState) {
            context.read<AccBloc>().redeemedAmount = state.redeemedAmount!;
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
          if (state is HowItWorksState) {
            showDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) {
                  return BlocProvider.value(
                    value: context.read<AccBloc>(),
                    child: BlocBuilder<AccBloc, AccState>(
                      builder: (context, state) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        final dialogBgColor =
                            isDark ? const Color(0xFF131E35) : Colors.white;
                        final textDarkColor =
                            isDark ? Colors.white : const Color(0xFF1F2937);
                        final hintTextColor = isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B);

                        final step1Title = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointOne;
                        final step1Desc = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointOneText;

                        final step2Title = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointTwo;
                        final step2Desc = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointTwoText;

                        final step3Title = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointThree;
                        final step3Desc = AppLocalizations.of(context)!
                            .rewardsHowItWorksPointThreeText;

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
                                // Content
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      size.width * 0.05,
                                      size.width * 0.08,
                                      size.width * 0.05,
                                      size.width * 0.05,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Gift / Coin Sparkle Illustration
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? const Color(0xFF1E293B)
                                                : const Color(0xFFEFF6FF),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                left: 18,
                                                top: 18,
                                                child: Icon(
                                                  Icons.card_giftcard_rounded,
                                                  size: 40,
                                                  color: isDark
                                                      ? const Color(0xFF818CF8)
                                                      : const Color(0xFF3B82F6),
                                                ),
                                              ),
                                              Positioned(
                                                right: 14,
                                                bottom: 14,
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.amber,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(1),
                                                  child: const Icon(
                                                    Icons.star_rounded,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 10,
                                                right: 12,
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  size: 10,
                                                  color: isDark
                                                      ? Colors.amberAccent
                                                      : Colors.blueAccent,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 12,
                                                left: 10,
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  size: 8,
                                                  color: isDark
                                                      ? Colors.amberAccent
                                                      : Colors.blueAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Title
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .howItWorks,
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: textDarkColor,
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // Indicator Line
                                        Container(
                                          width: 40,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : const Color(0xFF001CAD),
                                            borderRadius:
                                                BorderRadius.circular(1.5),
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Step 1 Row
                                        buildTimelineStep(
                                          isDark: isDark,
                                          textDarkColor: textDarkColor,
                                          hintTextColor: hintTextColor,
                                          icon: Icons.stars_rounded,
                                          iconColor: const Color(0xFF3B82F6),
                                          iconBgColor: isDark
                                              ? const Color(0xFF3B82F6)
                                                  .withOpacity(0.15)
                                              : const Color(0xFFEFF6FF),
                                          dotColor: const Color(0xFF3B82F6),
                                          title: step1Title,
                                          subtitle: step1Desc,
                                          isLast: false,
                                        ),

                                        // Step 2 Row
                                        buildTimelineStep(
                                          isDark: isDark,
                                          textDarkColor: textDarkColor,
                                          hintTextColor: hintTextColor,
                                          icon: Icons
                                              .account_balance_wallet_outlined,
                                          iconColor: const Color(0xFF10B981),
                                          iconBgColor: isDark
                                              ? const Color(0xFF10B981)
                                                  .withOpacity(0.15)
                                              : const Color(0xFFECFDF5),
                                          dotColor: const Color(0xFF10B981),
                                          title: step2Title,
                                          subtitle: step2Desc,
                                          isLast: false,
                                        ),

                                        // Step 3 Row
                                        buildTimelineStep(
                                          isDark: isDark,
                                          textDarkColor: textDarkColor,
                                          hintTextColor: hintTextColor,
                                          icon: Icons.card_giftcard_rounded,
                                          iconColor: const Color(0xFF8B5CF6),
                                          iconBgColor: isDark
                                              ? const Color(0xFF8B5CF6)
                                                  .withOpacity(0.15)
                                              : const Color(0xFFF5F3FF),
                                          dotColor: const Color(0xFF8B5CF6),
                                          title: step3Title,
                                          subtitle: step3Desc,
                                          isLast: true,
                                        ),
                                        const SizedBox(height: 8),

                                        // Bottom Banner
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1E293B)
                                                    .withOpacity(0.4)
                                                : const Color(0xFFEFF6FF),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFDBEAFE),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isDark
                                                      ? AppColors.primary
                                                          .withOpacity(0.2)
                                                      : const Color(0xFFDBEAFE),
                                                ),
                                                child: Icon(
                                                  Icons.shield_outlined,
                                                  color: isDark
                                                      ? AppColors.secondary
                                                      : AppColors.primary,
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .morePointsMoreRewardsText,
                                                      textStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: textDarkColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .keepRidingAndKeepEarningText,
                                                      textStyle: TextStyle(
                                                        fontSize: 11,
                                                        color: hintTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Overlapping Golden Coins Stack
                                              SizedBox(
                                                width: 44,
                                                height: 32,
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      left: 0,
                                                      bottom: 0,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.amber,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          userData?.currencySymbol ??
                                                              "₹",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 12,
                                                      bottom: 1,
                                                      child: Container(
                                                        width: 18,
                                                        height: 18,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .amber.shade600,
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          userData?.currencySymbol ??
                                                              "₹",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 8,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                      left: 6,
                                                      top: 0,
                                                      child: Container(
                                                        width: 22,
                                                        height: 22,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .amber.shade400,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                              blurRadius: 3,
                                                              offset:
                                                                  const Offset(
                                                                      0, 1),
                                                            ),
                                                          ],
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          userData?.currencySymbol ??
                                                              "₹",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
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
                                  ),
                                ),

                                // Close Button (placed last to overlay correctly)
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.black.withOpacity(0.04),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black.withOpacity(0.8),
                                      ),
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
                });
          }
          if (state is DriverRewardPointsState) {
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                      value: context.read<AccBloc>(),
                      child: RewardPointsWidget(cont: context));
                });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final backgroundColor =
                isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
            final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
            final textDarkColor =
                isDark ? Colors.white : const Color(0xFF1F2937);

            final bloc = context.watch<AccBloc>();
            final pointsData = userData?.loyaltyPoints?.data;
            final pointsBalance = pointsData?.balanceRewardPoints ?? 0.0;
            final enableConversion =
                pointsData?.enableRewardConversation == "1";

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.rewardsText,
                automaticallyImplyLeading: true,
                backgroundColor: backgroundColor,
                textColor: textDarkColor,
                leadingColor: textDarkColor,
                showBorder: false,
              ),
              body: SafeArea(
                child: (bloc.isLoading &&
                        bloc.firstLoadReward &&
                        !bloc.loadMoreReward)
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: RewardsShimmer(),
                      )
                    : SingleChildScrollView(
                        controller: bloc.rewardsScrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // "My Rewards" Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .myRewardsText,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    bloc.add(HowItWorksEvent());
                                  },
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .howItWorks,
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Points Balance Card
                            InkWell(
                              onTap: enableConversion
                                  ? () {
                                      bloc.rewardAmountController.clear();
                                      bloc.addRewardMoney = null;
                                      bloc.add(DriverRewardPointsEvent());
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF13254B)
                                      : const Color(0xFFFFF9EE),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1E3564)
                                        : const Color(0xFFFDE8C4),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Medal Circle Icon
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E3564)
                                            : const Color(0xFFFFF1D6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.workspace_premium_rounded,
                                        color: Color(0xFFF59E0B),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .yourPoints,
                                            textStyle: TextStyle(
                                              fontSize: 13,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          MyText(
                                            text: "$pointsBalance",
                                            textStyle: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: textDarkColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (enableConversion)
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8),
                                        size: 16,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // "Point History" Header
                            MyText(
                              text: AppLocalizations.of(context)!.pointsHistory,
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDarkColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Points History Content
                            bloc.driverRewardsList.isNotEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 1,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      boxShadow: [
                                        if (!isDark)
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.01),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              bloc.driverRewardsList.length,
                                          itemBuilder: (context, index) {
                                            final item =
                                                bloc.driverRewardsList[index];
                                            final isCredit =
                                                item.isCredit == true;

                                            return Row(
                                              children: [
                                                // Icon Circle
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isCredit
                                                        ? (isDark
                                                            ? const Color(
                                                                    0xFF10B981)
                                                                .withOpacity(
                                                                    0.2)
                                                            : const Color(
                                                                0xFFE2F7EB))
                                                        : (isDark
                                                            ? const Color(
                                                                    0xFFEF413B)
                                                                .withOpacity(
                                                                    0.2)
                                                            : const Color(
                                                                0xFFFDE8E8)),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Icon(
                                                    isCredit
                                                        ? Icons
                                                            .card_giftcard_rounded
                                                        : Icons.redo_rounded,
                                                    color: isCredit
                                                        ? const Color(
                                                            0xFF10B981)
                                                        : const Color(
                                                            0xFFEF413B),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Details column
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MyText(
                                                        text: isCredit
                                                            ? AppLocalizations
                                                                    .of(
                                                                        context)!
                                                                .rideReward
                                                            : AppLocalizations
                                                                    .of(context)!
                                                                .pointsRedeemed,
                                                        textStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: textDarkColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      MyText(
                                                        text: item.createdAt,
                                                        textStyle: TextStyle(
                                                          fontSize: 12,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF64748B)
                                                              : const Color(
                                                                  0xFF94A3B8),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Amount indicator
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    MyText(
                                                      text: isCredit
                                                          ? "+ "
                                                          : "- ",
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isCredit
                                                            ? const Color(
                                                                0xFF10B981)
                                                            : const Color(
                                                                0xFFEF413B),
                                                      ),
                                                    ),
                                                    MyText(
                                                      text: item.rewardPoints
                                                          .toString(),
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isCredit
                                                            ? const Color(
                                                                0xFF10B981)
                                                            : const Color(
                                                                0xFFEF413B),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return Divider(
                                              height: 24,
                                              thickness: 1,
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFF1F5F9),
                                            );
                                          },
                                        ),
                                        if (bloc.loadMoreReward &&
                                            !bloc.isLoading &&
                                            !bloc.firstLoadReward)
                                          const Center(
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 16),
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 1,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.noRewardsImage,
                                          height: 120,
                                        ),
                                        const SizedBox(height: 16),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noRewardsTopText,
                                          textAlign: TextAlign.center,
                                          textStyle: TextStyle(
                                            color: textDarkColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noRewardSubText,
                                          textAlign: TextAlign.center,
                                          textStyle: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF94A3B8),
                                            fontSize: 13,
                                          ),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget customRowText(
      BuildContext context, String text, Size size, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF001CAD),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MyText(
            text: text,
            maxLines: 4,
            textStyle: TextStyle(
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              fontSize: 14,
              height: 1.4,
            ),
            textAlign: TextAlign.start,
          ),
        )
      ],
    );
  }

  Widget buildTimelineStep({
    required bool isDark,
    required Color textDarkColor,
    required Color hintTextColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color dotColor,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 16,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isLast)
                  Positioned(
                    top: 24,
                    bottom: -24,
                    child: Container(
                      width: 1,
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                Positioned(
                  top: 20,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF13254B).withOpacity(0.5)
                    : const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: title,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyText(
                    text: subtitle,
                    textStyle: TextStyle(
                      fontSize: 13,
                      color: hintTextColor,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
