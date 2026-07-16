import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../auth/presentation/pages/login_page.dart';

class FleetDashboard extends StatefulWidget {
  static const String routeName = '/fleetDashboard';
  final FleetDashboardArguments args;

  const FleetDashboard({super.key, required this.args});

  @override
  State<FleetDashboard> createState() => _FleetDashboardState();
}

class _FleetDashboardState extends State<FleetDashboard> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()
          ..add(GetFleetDashboardEvent(fleetId: widget.args.fleetId)),
        child:
            BlocListener<AccBloc, AccState>(listener: (context, state) async {
          if (state is FleetDashboardLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is FleetDashboardLoadingStopState) {
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
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBgColor =
              isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
          final cardBgColor =
              isDark ? const Color(0xFF131E35) : const Color(0xFFFFFFFF);
          final borderColor =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
          final primaryText =
              isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
          final secondaryText =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;

          return Scaffold(
            backgroundColor: scaffoldBgColor,
            appBar: AppBar(
              backgroundColor: scaffoldBgColor,
              elevation: 0,
              centerTitle: true,
              title: MyText(
                text: AppLocalizations.of(context)!.cabPerformance,
                textStyle: TextStyle(
                  color: primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: primaryText),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SizedBox(
              height: size.height,
              width: size.width,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: (context.read<AccBloc>().fleetDashboardData !=
                                null)
                            ? Builder(builder: (context) {
                                final fleetData =
                                    context.read<AccBloc>().fleetDashboardData!;

                                String formatDuration(String? durationStr) {
                                  if (durationStr == null) {
                                    return '0 Hrs 0 mins';
                                  }
                                  final val =
                                      double.tryParse(durationStr) ?? 0.0;
                                  final parts =
                                      val.toStringAsFixed(2).split('.');
                                  return '${parts[0]} Hrs ${parts[1]} mins';
                                }

                                return Column(
                                  children: [
                                    // Cab Info Header Card
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderColor),
                                        boxShadow: isDark
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.02),
                                                  spreadRadius: 1,
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 56,
                                                width: 56,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        fleetData
                                                            .vehicleTypeIcon),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    MyText(
                                                      text:
                                                          fleetData.vehicleName,
                                                      textStyle: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: primaryText,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    MyText(
                                                      text: fleetData.licenseNo,
                                                      textStyle: TextStyle(
                                                        fontSize: 14,
                                                        color: secondaryText,
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
                                              // Booking
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF1E293B)
                                                        : const Color(
                                                            0xFFF8F9FC),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: borderColor),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .calendar_month_outlined,
                                                        color:
                                                            AppColors.primary,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      MyText(
                                                        text: fleetData
                                                            .totalTrips,
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .booking,
                                                        textStyle: TextStyle(
                                                          fontSize: 11,
                                                          color: secondaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Distance
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF1E293B)
                                                        : const Color(
                                                            0xFFF8F9FC),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: borderColor),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons.speed_outlined,
                                                        color:
                                                            AppColors.primary,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      MyText(
                                                        text:
                                                            '${fleetData.totalDistance} Km',
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .distance,
                                                        textStyle: TextStyle(
                                                          fontSize: 11,
                                                          color: secondaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Earnings
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12,
                                                      horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF1E293B)
                                                        : const Color(
                                                            0xFFF8F9FC),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                        color: borderColor),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      const Icon(
                                                        Icons.payments_outlined,
                                                        color:
                                                            AppColors.primary,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(height: 6),
                                                      MyText(
                                                        text:
                                                            '${userData!.currencySymbol} ${fleetData.totalEarnings}',
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: primaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .earnings,
                                                        textStyle: TextStyle(
                                                          fontSize: 11,
                                                          color: secondaryText,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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

                                    // Login Hour Details Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .loginHourDetails,
                                              textStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: primaryText,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                              height: 1, thickness: 1),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1E293B)
                                                          : const Color(
                                                              0xFFF8F9FC),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderColor),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        MyText(
                                                          text: formatDuration(
                                                              fleetData
                                                                  .totalDuration),
                                                          textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: primaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .totalLoginHours,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                secondaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1E293B)
                                                          : const Color(
                                                              0xFFF8F9FC),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderColor),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        MyText(
                                                          text: formatDuration(
                                                              fleetData
                                                                  .avgLoginHours),
                                                          textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: primaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .averageLoginHrs,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                secondaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Returning Details Card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cardBgColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: borderColor),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .returningDetails,
                                              textStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: primaryText,
                                              ),
                                            ),
                                          ),
                                          const Divider(
                                              height: 1, thickness: 1),
                                          Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1E293B)
                                                          : const Color(
                                                              0xFFF8F9FC),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderColor),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        MyText(
                                                          text:
                                                              '${userData!.currencySymbol} ${fleetData.totalRevenue}',
                                                          textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: primaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .totalRevenue,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                secondaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF1E293B)
                                                          : const Color(
                                                              0xFFF8F9FC),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                          color: borderColor),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        MyText(
                                                          text:
                                                              '${userData!.currencySymbol} ${fleetData.perDayRevenue}',
                                                          textStyle: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: primaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        MyText(
                                                          text: AppLocalizations
                                                                  .of(context)!
                                                              .averageRevenue,
                                                          textStyle: TextStyle(
                                                            fontSize: 12,
                                                            color:
                                                                secondaryText,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Overall Ratings Card
                                    if (double.tryParse(fleetData.avgRating) !=
                                            null &&
                                        double.parse(fleetData.avgRating) > 1)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: cardBgColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border:
                                              Border.all(color: borderColor),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .overallRatings,
                                                    textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryText,
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 18,
                                                        color:
                                                            Color(0xFFEAB308),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      MyText(
                                                        text:
                                                            '${fleetData.avgRating} out of 5',
                                                        textStyle: TextStyle(
                                                          color: primaryText,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            const Divider(
                                                height: 1, thickness: 1),
                                            Padding(
                                              padding: const EdgeInsets.all(16),
                                              child:
                                                  Builder(builder: (context) {
                                                double parseVal(String? val) =>
                                                    double.tryParse(
                                                        val ?? '0') ??
                                                    0.0;
                                                final avg = parseVal(
                                                    fleetData.avgRating);
                                                final r5 = parseVal(
                                                    fleetData.ratingFive);
                                                final r4 = parseVal(
                                                    fleetData.ratingFour);
                                                final r3 = parseVal(
                                                    fleetData.ratingThree);
                                                final r2 = parseVal(
                                                    fleetData.ratingTwo);
                                                final r1 = parseVal(
                                                    fleetData.ratingOne);

                                                double getBarWidth(
                                                    double ratingVal) {
                                                  if (avg == 0) return 0;
                                                  return size.width *
                                                      0.45 *
                                                      (ratingVal / avg);
                                                }

                                                String getPercentText(
                                                    double ratingVal) {
                                                  if (avg == 0) return '0%';
                                                  return '${((ratingVal / avg) * 100).toStringAsFixed(0)}%';
                                                }

                                                Widget buildRatingRow(
                                                    String label,
                                                    double ratingVal) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 6),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.2,
                                                          child: MyText(
                                                            text: label,
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryText,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Expanded(
                                                          child: Container(
                                                            height: 8,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              color: isDark
                                                                  ? const Color(
                                                                      0xFF1E293B)
                                                                  : const Color(
                                                                      0xFFF1F5F9),
                                                            ),
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Container(
                                                              width: getBarWidth(
                                                                  ratingVal),
                                                              height: 8,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                color:
                                                                    primaryBlue,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        SizedBox(
                                                          width: 40,
                                                          child: MyText(
                                                            text:
                                                                getPercentText(
                                                                    ratingVal),
                                                            textStyle:
                                                                TextStyle(
                                                              color:
                                                                  primaryText,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textAlign:
                                                                TextAlign.end,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }

                                                return Column(
                                                  children: [
                                                    buildRatingRow(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .excellent,
                                                        r5),
                                                    buildRatingRow(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .good,
                                                        r4),
                                                    buildRatingRow(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .below,
                                                        r3),
                                                    buildRatingRow(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .average,
                                                        r2),
                                                    buildRatingRow(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .bad,
                                                        r1),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 40),
                                  ],
                                );
                              })
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        })));
  }
}
