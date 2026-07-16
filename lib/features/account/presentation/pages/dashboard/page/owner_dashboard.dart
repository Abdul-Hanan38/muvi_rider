import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/earnings/page/earnings_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/dashboard/page/fleet_dashboard_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/vehicle_info/page/vehicle_data_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import 'driver_performance_page.dart';

class OwnerDashboard extends StatefulWidget {
  static const String routeName = '/ownerDashboard';
  final OwnerDashboardArguments args;
  const OwnerDashboard({super.key, required this.args});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()..add(GetOwnerDashboardEvent()),
        child:
            BlocListener<AccBloc, AccState>(listener: (context, state) async {
          if (state is DashboardLoadingStartState) {
            CustomLoader.loader(context);
          }

          if (state is DashboardLoadingStopState) {
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
                text: AppLocalizations.of(context)!.ownerDashboard,
                textStyle: TextStyle(
                  color: primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: widget.args.from == ''
                  ? IconButton(
                      icon: Icon(Icons.arrow_back, color: primaryText),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Active & Inactive Cabs cards
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, VehicleDataPage.routeName,
                                  arguments: VehicleDataArguments(from: 0));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.primary
                                                  .withOpacity(0.2)
                                              : const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.directions_car,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.active} ${AppLocalizations.of(context)!.cabs}',
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: primaryText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    text: (context.read<AccBloc>().fleetData !=
                                            null)
                                        ? context
                                            .read<AccBloc>()
                                            .fleetData!
                                            .activeFleets
                                        : '0',
                                    textStyle: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .totalRunning,
                                    textStyle: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, VehicleDataPage.routeName,
                                  arguments: VehicleDataArguments(from: 1));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          spreadRadius: 1,
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF334155)
                                                  .withOpacity(0.3)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.directions_car,
                                          color: secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: MyText(
                                          text:
                                              '${AppLocalizations.of(context)!.inactive} ${AppLocalizations.of(context)!.cabs}',
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: primaryText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    text: (context.read<AccBloc>().fleetData !=
                                            null)
                                        ? context
                                            .read<AccBloc>()
                                            .fleetData!
                                            .inactiveFleets
                                        : '0',
                                    textStyle: TextStyle(
                                      color: primaryText,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .notRunning,
                                    textStyle: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Blocked cabs card (if count > 0)
                    if (context.read<AccBloc>().fleetData != null &&
                        context.read<AccBloc>().fleetData!.blockedFleets !=
                            '0') ...[
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, VehicleDataPage.routeName,
                              arguments: VehicleDataArguments(from: 2));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      // ignore: prefer_const_constructors
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFEF4444).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.block,
                                  color: Color(0xFFEF4444),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text:
                                          '${AppLocalizations.of(context)!.blocked} ${AppLocalizations.of(context)!.cabs}',
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: primaryText,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .blockedCabs,
                                      textStyle: TextStyle(
                                        color: secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              MyText(
                                text: context
                                    .read<AccBloc>()
                                    .fleetData!
                                    .blockedFleets,
                                textStyle: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Revenue Card
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, EarningsPage.routeName,
                            arguments: EarningArguments(from: 'dashboard'));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!.revenue,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: MyText(
                                    text: (context.read<AccBloc>().fleetData !=
                                            null)
                                        ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.revenue}'
                                        : '-',
                                    textStyle: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: primaryText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: primaryBlue,
                                  size: 28,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1, thickness: 1),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                // Cash
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.payments,
                                          color: Color(0xFF10B981),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      MyText(
                                        text: (context
                                                    .read<AccBloc>()
                                                    .fleetData !=
                                                null)
                                            ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.cash}'
                                            : '-',
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        text:
                                            AppLocalizations.of(context)!.cash,
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color: secondaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Digital
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3B82F6)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.credit_card,
                                          color: Color(0xFF3B82F6),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      MyText(
                                        text: (context
                                                    .read<AccBloc>()
                                                    .fleetData !=
                                                null)
                                            ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.digitalEarnings}'
                                            : '-',
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .digitalPayment,
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color: secondaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                // Discount
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF97316)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.local_offer,
                                          color: Color(0xFFF97316),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      MyText(
                                        text: (context
                                                    .read<AccBloc>()
                                                    .fleetData !=
                                                null)
                                            ? '${userData!.currencySymbol} ${context.read<AccBloc>().fleetData!.discount}'
                                            : '-',
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .discount,
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          color: secondaryText,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Cab Performance Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.cabPerformance,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, VehicleDataPage.routeName,
                                arguments: VehicleDataArguments(from: 0));
                          },
                          child: MyText(
                            text: AppLocalizations.of(context)!.viewAll,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Cab list carousel
                    (context.read<AccBloc>().fleetEarnings != null &&
                            context.read<AccBloc>().fleetEarnings!.isNotEmpty)
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  context.read<AccBloc>().fleetEarnings!.length,
                              itemBuilder: (context, i) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, FleetDashboard.routeName,
                                        arguments: FleetDashboardArguments(
                                          fleetId: context
                                              .read<AccBloc>()
                                              .fleetEarnings![i]
                                              .fleetId,
                                        ));
                                  },
                                  child: Container(
                                    width: size.width * 0.55,
                                    padding: const EdgeInsets.all(16),
                                    margin: EdgeInsets.only(
                                      right: context
                                                  .read<AccBloc>()
                                                  .textDirection ==
                                              'ltr'
                                          ? 16
                                          : 0,
                                      left: context
                                                  .read<AccBloc>()
                                                  .textDirection !=
                                              'ltr'
                                          ? 16
                                          : 0,
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.directions_car,
                                                color: AppColors.primary,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MyText(
                                                text: context
                                                    .read<AccBloc>()
                                                    .fleetEarnings![i]
                                                    .licenseNo,
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryText,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        MyText(
                                          text:
                                              '${userData!.currencySymbol} ${context.read<AccBloc>().fleetEarnings![i].totalEarnings}',
                                          textStyle: TextStyle(
                                            color: primaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Color(0xFFEAB308),
                                                ),
                                                const SizedBox(width: 4),
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .fleetEarnings![i]
                                                      .averageRating,
                                                  textStyle: TextStyle(
                                                    color: primaryText,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MyText(
                                              text:
                                                  '${AppLocalizations.of(context)!.rides}: ${context.read<AccBloc>().fleetEarnings![i].totalCompletedRequests}',
                                              textStyle: TextStyle(
                                                fontSize: 12,
                                                color: secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : (context.read<AccBloc>().fleetEarnings != null &&
                                context.read<AccBloc>().fleetEarnings!.isEmpty)
                            ? Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      AppImages.dashboardEmptyData,
                                      width: size.width * 0.4,
                                      height: size.width * 0.25,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 8),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .noDataFound,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),

                    const SizedBox(height: 24),

                    // Driver Performance Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.driverPerformance,
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/driversPage');
                          },
                          child: MyText(
                            text: AppLocalizations.of(context)!.viewAll,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Driver list carousel
                    (context.read<AccBloc>().fleetDriverData != null &&
                            context.read<AccBloc>().fleetDriverData!.isNotEmpty)
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: context
                                  .read<AccBloc>()
                                  .fleetDriverData!
                                  .length,
                              itemBuilder: (context, i) {
                                if (!context
                                    .read<AccBloc>()
                                    .fleetDriverData![i]
                                    .isApproved) {
                                  return const SizedBox.shrink();
                                }
                                return InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        DriverPerformancePage.routeName,
                                        arguments: DriverDashboardArguments(
                                            driverId: context
                                                .read<AccBloc>()
                                                .fleetDriverData![i]
                                                .driverId,
                                            driverName: context
                                                .read<AccBloc>()
                                                .fleetDriverData![i]
                                                .name,
                                            profile: context
                                                .read<AccBloc>()
                                                .fleetDriverData![i]
                                                .profile));
                                  },
                                  child: Container(
                                    width: size.width * 0.55,
                                    padding: const EdgeInsets.all(16),
                                    margin: EdgeInsets.only(
                                      right: context
                                                  .read<AccBloc>()
                                                  .textDirection ==
                                              'ltr'
                                          ? 16
                                          : 0,
                                      left: context
                                                  .read<AccBloc>()
                                                  .textDirection !=
                                              'ltr'
                                          ? 16
                                          : 0,
                                    ),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundImage: NetworkImage(
                                                  context
                                                      .read<AccBloc>()
                                                      .fleetDriverData![i]
                                                      .profile),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: MyText(
                                                text: context
                                                    .read<AccBloc>()
                                                    .fleetDriverData![i]
                                                    .name,
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryText,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        MyText(
                                          text:
                                              '${userData!.currencySymbol} ${context.read<AccBloc>().fleetDriverData![i].totalEarnings}',
                                          textStyle: TextStyle(
                                            color: primaryText,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: Color(0xFFEAB308),
                                                ),
                                                const SizedBox(width: 4),
                                                MyText(
                                                  text: context
                                                      .read<AccBloc>()
                                                      .fleetDriverData![i]
                                                      .averageRating,
                                                  textStyle: TextStyle(
                                                    color: primaryText,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            MyText(
                                              text:
                                                  '${AppLocalizations.of(context)!.rides}: ${context.read<AccBloc>().fleetDriverData![i].totalCompletedRequests}',
                                              textStyle: TextStyle(
                                                fontSize: 12,
                                                color: secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : (context.read<AccBloc>().fleetDriverData != null &&
                                context
                                    .read<AccBloc>()
                                    .fleetDriverData!
                                    .isEmpty)
                            ? Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      AppImages.noDataFound,
                                      width: size.width * 0.4,
                                      height: size.width * 0.25,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(height: 8),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .noDataFound,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        })));
  }
}
