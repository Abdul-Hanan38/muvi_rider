import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/earnings_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';

class EarningsPage extends StatefulWidget {
  static const String routeName = '/earningsPage';
  final EarningArguments? args;

  const EarningsPage({super.key, this.args});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

List dragValue = [];

class _EarningsPageState extends State<EarningsPage> {
  Widget _buildDayPill(
    BuildContext context,
    String dayKey,
    dynamic dayValue,
    bool display,
    EarningsData weekData,
    AccBloc accBloc,
    bool isDark,
  ) {
    final parts = dayKey.split('-');
    final dayName = parts.isNotEmpty ? parts[0] : '';
    final dayNumber = parts.length > 1 ? parts[1] : '';
    final isSelected = accBloc.choosenEarningsDate == dayKey;

    return Expanded(
      child: GestureDetector(
        onTap: display
            ? () {
                if (int.parse(weekData.toDate.toString().split('-')[0]) <
                    int.parse(dayKey.toString().split('-')[1])) {
                  accBloc.add(GetDailyEarningsEvent(
                      date: weekData.fromDate.toString().replaceFirst(
                          weekData.fromDate.toString().split('-')[0],
                          dayKey.toString().split('-')[1])));
                } else {
                  accBloc.add(GetDailyEarningsEvent(
                      date: weekData.toDate.toString().replaceFirst(
                          weekData.toDate.toString().split('-')[0],
                          dayKey.toString().split('-')[1])));
                }
              }
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF131E35) : const Color(0xFFF1F3F6)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? const Color(0xFF1F2D4A)
                      : const Color(0xFFE2E8F0)),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: dayName,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (display
                          ? (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B))
                          : (isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1))),
                ),
              ),
              const SizedBox(height: 6),
              MyText(
                text: dayNumber,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (display
                          ? (isDark ? Colors.white : const Color(0xFF1F2937))
                          : (isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final textLightColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return BlocProvider(
      create: (context) => AccBloc()..add(GetEarningsEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is EarningsLoadingStartState) {
            CustomLoader.loader(context);
          }
          if (state is EarningsLoadingStopState) {
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
          if (state is ShowErrorState) {
            return showToast(message: state.message);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            final hasEarnings = accBloc.earningsList.isNotEmpty;

            if (!hasEarnings) {
              return Scaffold(
                backgroundColor: backgroundColor,
                body: const SizedBox(),
              );
            }

            final chosenWeekIndex = accBloc.choosenEarningsWeeks ?? 0;
            final currentWeek = accBloc.earningsList[chosenWeekIndex];
            final currency = accBloc.earningCurrency;

            final loginText = userData!.role != 'owner'
                ? '${AppLocalizations.of(context)!.login} : ${currentWeek.totalLoggedInHours}'
                : '${AppLocalizations.of(context)!.tripsTaken} : ${accBloc.dailyEarningsList?.totalTrips.toString() ?? '0'}';

            // Calculate Max Value for the Bar Chart
            double maxVal = 0.0;
            currentWeek.dates.forEach((k, v) {
              final num val =
                  v is num ? v : double.tryParse(v.toString()) ?? 0.0;
              if (val > maxVal) {
                maxVal = val.toDouble();
              }
            });
            if (maxVal <= 0) {
              maxVal = 10.0;
            }
            // Round up to nearest multiple of 5 for nicer grid spacing
            final double targetMax = ((maxVal / 5).ceil() * 5).toDouble();

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: SafeArea(
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(
                        top: 8, left: 16, right: 16, bottom: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if ((widget.args != null &&
                            widget.args!.from! == 'dashboard'))
                          PositionedDirectional(
                            start: 0,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Icon(
                                Icons.arrow_back,
                                color: textDarkColor,
                                size: 20,
                              ),
                            ),
                          ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.earnings,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: textDarkColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 2),
                          ],
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
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),

                              // Weekly Earnings Card (Blue Gradient)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F1A30)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .weeklyEarnings,
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    MyText(
                                      text:
                                          '$currency ${currentWeek.totalAmount}',
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                color: Color(0xFF93C5FD),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: MyText(
                                                  text:
                                                      '${currentWeek.fromDate} - ${currentWeek.toDate}',
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.access_time,
                                                color: Color(0xFF93C5FD),
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: MyText(
                                                  text: loginText,
                                                  textStyle: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        // Trips Sub-card
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1D283F)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .directions_car_filled,
                                                      color: Color(0xFF1E5AF3),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .trips,
                                                        textStyle: TextStyle(
                                                          color: textLightColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                MyText(
                                                  text: currentWeek.totalTrips
                                                      .toString(),
                                                  textStyle: TextStyle(
                                                    color: textDarkColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Wallet Sub-card
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1D283F)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .account_balance_wallet,
                                                      color: Color(0xFF1E5AF3),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .wallet,
                                                        textStyle: TextStyle(
                                                          color: textLightColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                MyText(
                                                  text:
                                                      '$currency ${currentWeek.totalWalletAmount}',
                                                  textStyle: TextStyle(
                                                    color: textDarkColor,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Total Earnings Sub-card
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1D283F)
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.payments,
                                                      color: Color(0xFF10B981),
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .totalEarnings,
                                                        textStyle: TextStyle(
                                                          color: textLightColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                MyText(
                                                  text:
                                                      '$currency ${currentWeek.totalAmount}',
                                                  textStyle: const TextStyle(
                                                    color: Color(0xFF10B981),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Horizontal Day selector pills inside week PageView
                              GestureDetector(
                                onHorizontalDragStart: (v) {
                                  dragValue.clear();
                                },
                                onHorizontalDragUpdate: (v) {
                                  dragValue.add(v.globalPosition.dx);
                                },
                                onHorizontalDragEnd: (v) {
                                  if (dragValue[dragValue.length - 1] >
                                      dragValue[dragValue.length - 2]) {
                                    if (accBloc.earningsList.length - 1 >
                                        accBloc.choosenEarningsWeeks!) {
                                      accBloc.add(ChangeEarningsWeekEvent(
                                          week: accBloc.choosenEarningsWeeks! +
                                              1));
                                    }
                                  }
                                  if (dragValue[dragValue.length - 1] <
                                      dragValue[dragValue.length - 2]) {
                                    if (accBloc.choosenEarningsWeeks! != 0) {
                                      accBloc.add(ChangeEarningsWeekEvent(
                                          week: accBloc.choosenEarningsWeeks! -
                                              1));
                                    }
                                  }
                                },
                                child: SizedBox(
                                  width: size.width,
                                  height: 72,
                                  child: PageView(
                                    reverse: true,
                                    controller: accBloc.earningsController,
                                    onPageChanged: (v) {
                                      accBloc.choosenEarningsWeeks = v;
                                      accBloc.add(
                                          ChangeEarningsWeekEvent(week: v));
                                      final selectedWeekData =
                                          accBloc.earningsList[v];
                                      final firstDateKey =
                                          selectedWeekData.dates.keys.first;
                                      if (v ==
                                          accBloc.earningsList.length - 1) {
                                        accBloc.add(
                                          GetDailyEarningsEvent(
                                            date: selectedWeekData.fromDate
                                                .toString()
                                                .replaceFirst(
                                                  selectedWeekData.fromDate
                                                      .toString()
                                                      .split('-')[0],
                                                  firstDateKey
                                                      .toString()
                                                      .split('-')[1],
                                                ),
                                          ),
                                        );
                                      } else {
                                        accBloc.add(
                                          GetDailyEarningsEvent(date: 'today'),
                                        );
                                      }
                                    },
                                    scrollDirection: Axis.horizontal,
                                    children: accBloc.earningsList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final weekData = entry.value;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: weekData.dates.entries
                                            .map((dateEntry) {
                                          final dayKey = dateEntry.key;
                                          final dayValue = dateEntry.value;

                                          bool display = false;
                                          if (int.parse(weekData.toDate
                                                  .toString()
                                                  .split('-')[0]) <
                                              int.parse(dayKey
                                                  .toString()
                                                  .split('-')[1])) {
                                            if (DateTime.now()
                                                    .difference(DateFormat(
                                                            'dd-MMM-yy')
                                                        .parse(weekData.fromDate
                                                            .toString()
                                                            .replaceFirst(
                                                                weekData
                                                                    .fromDate
                                                                    .toString()
                                                                    .split(
                                                                        '-')[0],
                                                                dayKey
                                                                    .toString()
                                                                    .split(
                                                                        '-')[1])))
                                                    .inHours >=
                                                0) {
                                              display = true;
                                            }
                                          } else {
                                            if (DateTime.now()
                                                    .difference(DateFormat(
                                                            'dd-MMM-yy')
                                                        .parse(weekData.toDate
                                                            .toString()
                                                            .replaceFirst(
                                                                weekData.toDate
                                                                    .toString()
                                                                    .split(
                                                                        '-')[0],
                                                                dayKey
                                                                    .toString()
                                                                    .split(
                                                                        '-')[1])))
                                                    .inHours >=
                                                0) {
                                              display = true;
                                            }
                                          }

                                          return _buildDayPill(
                                              context,
                                              dayKey,
                                              dayValue,
                                              display,
                                              weekData,
                                              accBloc,
                                              isDark);
                                        }).toList(),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Earnings Overview & Bar Chart
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1D283F)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                  boxShadow: isDark
                                      ? []
                                      : [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Card Header
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .earningsOverview,
                                          textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textDarkColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Bar Chart Area
                                    SizedBox(
                                      height: 180,
                                      child: Stack(
                                        children: [
                                          // Grid lines and Y-Axis Labels
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Grid line 1 (Top)
                                                SizedBox(
                                                  height: 14,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: MyText(
                                                            text: targetMax
                                                                .toInt()
                                                                .toString(),
                                                            textStyle: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textLightColor),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: _DashedLine(
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFF1D283F)
                                                                : const Color(
                                                                    0xFFE2E8F0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Grid line 2
                                                SizedBox(
                                                  height: 14,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: MyText(
                                                            text: (targetMax *
                                                                    0.67)
                                                                .toInt()
                                                                .toString(),
                                                            textStyle: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textLightColor),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: _DashedLine(
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFF1D283F)
                                                                : const Color(
                                                                    0xFFE2E8F0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Grid line 3
                                                SizedBox(
                                                  height: 14,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: MyText(
                                                            text: (targetMax *
                                                                    0.33)
                                                                .toInt()
                                                                .toString(),
                                                            textStyle: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textLightColor),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: _DashedLine(
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFF1D283F)
                                                                : const Color(
                                                                    0xFFE2E8F0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Grid line 4 (Bottom Solid Axis Line)
                                                SizedBox(
                                                  height: 14,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: MyText(
                                                            text: '0',
                                                            textStyle: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    textLightColor),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Container(
                                                          height: 1,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF2E3B54)
                                                              : const Color(
                                                                  0xFFCBD5E1),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Bars and Day Characters Row
                                          Positioned.fill(
                                            child: Row(
                                              children: [
                                                // Matches the width of left elements: 30 (SizedBox) + 12 (spacing)
                                                const SizedBox(width: 42),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: currentWeek
                                                          .dates.entries
                                                          .map((dateEntry) {
                                                        final dayKey =
                                                            dateEntry.key;
                                                        final num v = dateEntry
                                                                .value is num
                                                            ? dateEntry.value
                                                            : double.tryParse(
                                                                    dateEntry
                                                                        .value
                                                                        .toString()) ??
                                                                0.0;
                                                        final double barHeight =
                                                            targetMax > 0
                                                                ? (v / targetMax) *
                                                                    140
                                                                : 0.0;
                                                        final dayChar = dayKey
                                                                .toString()
                                                                .isNotEmpty
                                                            ? dayKey
                                                                .toString()[0]
                                                            : '';

                                                        return SizedBox(
                                                          width: 24,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 153,
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomCenter,
                                                                  child:
                                                                      Container(
                                                                    width: 12,
                                                                    height: barHeight >
                                                                            0
                                                                        ? barHeight
                                                                        : 2.0,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppColors
                                                                          .primary,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .vertical(
                                                                        top: Radius
                                                                            .circular(4),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Center(
                                                                  child: MyText(
                                                                    text:
                                                                        dayChar,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    textStyle:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          textLightColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }).toList(),
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
                              const SizedBox(height: 20),

                              // Bottom details: Total Login & Distance
                              if (accBloc.dailyEarningsList != null) ...[
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1D283F)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Total Login
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.access_time_filled,
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .login,
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: textDarkColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MyText(
                                              text: accBloc.dailyEarningsList!
                                                  .totalHoursWorked,
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 1,
                                        color: isDark
                                            ? const Color(0xFF1D283F)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      // Total Distance
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF10B981)
                                                            .withOpacity(0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    color: Color(0xFF10B981),
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .totalDistance,
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: textDarkColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MyText(
                                              text:
                                                  '${accBloc.dailyEarningsList!.totalTripsKm.toStringAsFixed(2)} ${userData!.distanceUnit}',
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF10B981),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Summary List of Trips
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: MyText(
                                    text: AppLocalizations.of(context)!.summary,
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: textDarkColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (accBloc.dailyEarningsList!.data.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        accBloc.dailyEarningsList!.data.length,
                                    itemBuilder: (context, i) {
                                      final trip =
                                          accBloc.dailyEarningsList!.data[i];
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF1D283F)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.directions_car_filled,
                                                color: AppColors.primary,
                                                size: 20,
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
                                                        .trips,
                                                    textStyle: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: textDarkColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  MyText(
                                                    text: trip.tripTime,
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      color: textLightColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            MyText(
                                              text:
                                                  '${accBloc.dailyEarningsList!.currency} ${trip.tripCommission}',
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                else
                                  Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      Image.asset(
                                        AppImages.earningsNoData,
                                        width: size.width * 0.4,
                                        height: size.width * 0.4,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 12),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .noSummaryText,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          color: textLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                              const SizedBox(height: 24),
                            ],
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
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  final Color color;
  const _DashedLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
