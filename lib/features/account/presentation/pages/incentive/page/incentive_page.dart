import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/utils/custom_appbar.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/incentive_date_widget.dart';
import '../widget/upcoming_incentives_widget.dart';

class IncentivePage extends StatelessWidget {
  static const String routeName = '/incentivePage';

  const IncentivePage({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetIncentiveEvent(
            type: userData!.availableIncentive == '0' ||
                    userData?.availableIncentive == '2'
                ? 0
                : 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is IncentiveLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is ShowErrorState) {
            showToast(message: state.message);
          }

          if (state is IncentiveLoadingStopState) {
            CustomLoader.dismiss(context);
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
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBg = isDark ? const Color(0xFF0D1527) : Colors.white;
          final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
          final textMutedColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

          return Scaffold(
              backgroundColor: scaffoldBg,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.incentives,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
                showBorder: false,
                backgroundColor: scaffoldBg,
                textColor: textDarkColor,
                leadingColor: textDarkColor,
              ),
              body: SafeArea(
                  child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05, vertical: 12),
                child: Column(
                  children: [
                    Column(
                      children: [
                        userData?.availableIncentive == '2'
                            ? Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131E35)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                height: 50,
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (context
                                                  .read<AccBloc>()
                                                  .choosenIncentiveData !=
                                              0) {
                                            context.read<AccBloc>().add(
                                                GetIncentiveEvent(type: 0));
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenIncentiveData ==
                                                      0)
                                                  ? primaryColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 16,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .choosenIncentiveData ==
                                                          0)
                                                      ? Colors.white
                                                      : textMutedColor,
                                                ),
                                                const SizedBox(width: 8),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .dailyCaps
                                                      .toUpperCase(),
                                                  textStyle: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenIncentiveData ==
                                                            0)
                                                        ? Colors.white
                                                        : textMutedColor,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if (context
                                                  .read<AccBloc>()
                                                  .choosenIncentiveData !=
                                              1) {
                                            context.read<AccBloc>().add(
                                                GetIncentiveEvent(type: 1));
                                          }
                                        },
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: (context
                                                          .read<AccBloc>()
                                                          .choosenIncentiveData ==
                                                      1)
                                                  ? primaryColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.calendar_month_outlined,
                                                  size: 16,
                                                  color: (context
                                                              .read<AccBloc>()
                                                              .choosenIncentiveData ==
                                                          1)
                                                      ? Colors.white
                                                      : textMutedColor,
                                                ),
                                                const SizedBox(width: 8),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .weeklyCaps
                                                      .toUpperCase(),
                                                  textStyle: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: (context
                                                                .read<AccBloc>()
                                                                .choosenIncentiveData ==
                                                            1)
                                                        ? Colors.white
                                                        : textMutedColor,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : userData?.availableIncentive == '0'
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .dailyCaps
                                              .toUpperCase(),
                                          textStyle: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: textDarkColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : userData?.availableIncentive == '1'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(
                                                size.width * 0.05),
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .weeklyCaps
                                                      .toUpperCase(),
                                              textStyle: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: size.width * 0.22,
                          child: IncentiveDateWidget(cont: context),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        if (context.read<AccBloc>().selectedIncentiveHistory !=
                            null) ...[
                          Builder(
                            builder: (context) {
                              final isMissed = context
                                  .read<AccBloc>()
                                  .selectedIncentiveHistory!
                                  .upcomingIncentives
                                  .any((element) =>
                                      element.isCompleted == false);
                              final isEarned = !isMissed;

                              return Container(
                                width: size.width,
                                decoration: BoxDecoration(
                                  color: isEarned
                                      ? (isDark
                                          ? const Color(0xFF0F2E1E)
                                              .withOpacity(0.4)
                                          : const Color(0xFFEFFDF4))
                                      : (isDark
                                          ? const Color(0xFF3B1E1E)
                                              .withOpacity(0.4)
                                          : const Color(0xFFFEF2F2)),
                                  border: Border.all(
                                    color: isEarned
                                        ? (isDark
                                            ? const Color(0xFF1E4D34)
                                            : const Color(0xFFDCFCE7))
                                        : (isDark
                                            ? const Color(0xFF6B2121)
                                            : const Color(0xFFFEE2E2)),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Stack(
                                  children: [
                                    // Subtle background gift card watermark on the right
                                    Positioned(
                                      right: -8,
                                      top: -8,
                                      child: Icon(
                                        Icons.redeem_rounded,
                                        size: 80,
                                        color: isEarned
                                            ? (isDark
                                                ? Colors.green.withOpacity(0.04)
                                                : Colors.green
                                                    .withOpacity(0.06))
                                            : (isDark
                                                ? Colors.red.withOpacity(0.04)
                                                : Colors.red.withOpacity(0.06)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: isEarned
                                                      ? (isDark
                                                          ? const Color(
                                                              0xFF1B3D2B)
                                                          : const Color(
                                                              0xFFDCFCE7))
                                                      : (isDark
                                                          ? const Color(
                                                              0xFF4C1D1D)
                                                          : const Color(
                                                              0xFFFEE2E2)),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.redeem_rounded,
                                                  color: isEarned
                                                      ? (isDark
                                                          ? const Color(
                                                              0xFF4ADE80)
                                                          : const Color(
                                                              0xFF16A34A))
                                                      : (isDark
                                                          ? const Color(
                                                              0xFFF87171)
                                                          : const Color(
                                                              0xFFDC2626)),
                                                  size: 24,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text:
                                                          "${AppLocalizations.of(context)!.earnUptoText} ${userData!.currencySymbol} ${context.read<AccBloc>().selectedIncentiveHistory!.earnUpto}",
                                                      textStyle: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textDarkColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .byCompletingRideText
                                                          .replaceAll(
                                                              "12",
                                                              context
                                                                  .read<
                                                                      AccBloc>()
                                                                  .selectedIncentiveHistory!
                                                                  .totalRides
                                                                  .toString()),
                                                      textStyle: TextStyle(
                                                        fontSize: 13,
                                                        color: textMutedColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: isEarned
                                                  ? (isDark
                                                      ? const Color(0xFF122C1E)
                                                      : const Color(0xFFDCFCE7)
                                                          .withOpacity(0.5))
                                                  : (isDark
                                                      ? const Color(0xFF2D1414)
                                                      : const Color(0xFFFEE2E2)
                                                          .withOpacity(0.5)),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isEarned
                                                      ? Icons
                                                          .check_circle_rounded
                                                      : Icons.cancel_rounded,
                                                  color: isEarned
                                                      ? (isDark
                                                          ? const Color(
                                                              0xFF4ADE80)
                                                          : const Color(
                                                              0xFF16A34A))
                                                      : (isDark
                                                          ? const Color(
                                                              0xFFF87171)
                                                          : const Color(
                                                              0xFFDC2626)),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: MyText(
                                                    text: isEarned
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .earnedIncentiveText
                                                        : AppLocalizations.of(
                                                                context)!
                                                            .missedIncentiveText,
                                                    textStyle: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: isEarned
                                                          ? (isDark
                                                              ? const Color(
                                                                  0xFF4ADE80)
                                                              : const Color(
                                                                  0xFF15803D))
                                                          : (isDark
                                                              ? const Color(
                                                                  0xFFF87171)
                                                              : const Color(
                                                                  0xFFB91C1C)),
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
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                    (context.read<AccBloc>().incentiveHistory.isNotEmpty &&
                            context.read<AccBloc>().incentiveDates.isNotEmpty)
                        ? Expanded(
                            child: BlocBuilder<AccBloc, AccState>(
                              builder: (context, state) {
                                if (state is ShowUpcomingIncentivesState) {
                                  return ShowUpcomingIncentivesWidget(
                                      cont: context,
                                      upcomingIncentives:
                                          state.upcomingIncentives);
                                }
                                return Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .selectDateForIncentives,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!
                                      .incentiveEmptyText,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: AppColors.white),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              )));
        }),
      ),
    );
  }
}
