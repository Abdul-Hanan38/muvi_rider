import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/help/page/help_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/history/page/history_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import '../../../../common/app_arguments.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../language/presentation/page/choose_language_page.dart';
import 'dashboard/page/owner_dashboard.dart';
import 'driver_report/pages/reports_page.dart';
import 'earnings/page/earnings_page.dart';
import 'fleet_driver/page/fleet_drivers_page.dart';
import 'incentive/page/incentive_page.dart';
import 'levelup/page/driver_levels_page.dart';
import 'myroute_booking/page/myroute_booking.dart';
import 'notification/page/notification_page.dart';
import 'profile/page/profile_info_page.dart';
import 'refferal/page/referral_page.dart';
import 'rewards/page/rewards_page.dart';
import 'settings/page/settings_page.dart';
import 'sos/pages/sos_page.dart';
import 'subscription/page/subscription_page.dart';
import 'vehicle_info/page/vehicle_data_page.dart';
import 'wallet/page/wallet_page.dart';

class AccountPage extends StatelessWidget {
  static const String routeName = '/accountPage';
  final AccountPageArguments arg;

  const AccountPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent())
        ..add(UserDataInitEvent(userDetails: arg.userData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UserDetailState) {
            Navigator.pushNamed(
              context,
              ProfileInfoPage.routeName,
            ).then((value) {
              if (!context.mounted) return;
              context.read<AccBloc>().add(AccGetUserDetailsEvent());
            });
          }
          if (state is LogoutSuccess || state is LogoutFailureState) {
            await AppSharedPreference.getUserTypeStatus();
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginPage.routeName,
                (route) => false,
              );
            }
            await AppSharedPreference.logoutRemove();
          } else if (state is DeleteAccountSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, ChooseLanguagePage.routeName, (route) => false,
                arguments: ChangeLanguageArguments(from: 0));
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          } else if (state is DeleteAccountFailureState) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBgColor = isDark ? const Color(0xFF131C2E) : Colors.white;
          final cardBorderColor =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

          return SafeArea(
            child: Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor:
                    isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC),
                body: CustomScrollView(
                  slivers: [
                    /// 1. TOP HEADER
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          width: size.width,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(24),
                            border:
                                Border.all(color: cardBorderColor, width: 1),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: CustomPaint(
                                    size: const Size(30, 24),
                                    painter: DotGridPainter(
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                              .withOpacity(0.2)
                                          : const Color(0xFF0284C7)
                                              .withOpacity(0.12),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  child: Row(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CustomPaint(
                                            size: const Size(90, 90),
                                            painter: DottedCirclePainter(
                                              color: isDark
                                                  ? AppColors.primary
                                                      .withOpacity(0.3)
                                                  : AppColors.primary
                                                      .withOpacity(0.12),
                                              radiusFactor: 1.0,
                                            ),
                                          ),
                                          CustomPaint(
                                            size: const Size(90, 90),
                                            painter: DottedCirclePainter(
                                              color: isDark
                                                  ? AppColors.primary
                                                      .withOpacity(0.5)
                                                  : AppColors.primary
                                                      .withOpacity(0.2),
                                              radiusFactor: 0.85,
                                            ),
                                          ),
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              child: userData!
                                                      .profilePicture.isNotEmpty
                                                  ? Image.network(
                                                      userData!.profilePicture,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                              AppImages
                                                                  .defaultProfile,
                                                              fit:
                                                                  BoxFit.cover),
                                                    )
                                                  : Image.asset(
                                                      AppImages.defaultProfile,
                                                      fit: BoxFit.cover),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyText(
                                              text: userData!.name,
                                              textStyle: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            if (userData!.role == "driver")
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  color: isDark
                                                      ? const Color(0xFF78350F)
                                                          .withOpacity(0.3)
                                                      : const Color(0xFFFFFBEB),
                                                  border: Border.all(
                                                    color: isDark
                                                        ? const Color(
                                                                0xFFD97706)
                                                            .withOpacity(0.3)
                                                        : const Color(
                                                            0xFFFEF3C7),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.star_rounded,
                                                      size: 14,
                                                      color: Color(0xFFF59E0B),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    MyText(
                                                      text: userData!.rating,
                                                      textStyle: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isDark
                                                            ? const Color(
                                                                0xFFF59E0B)
                                                            : const Color(
                                                                0xFFB45309),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, HelpPage.routeName);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF1E293B)
                                                    .withOpacity(0.4)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: const Color(0xFF10B981)
                                                  .withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.help_outline_rounded,
                                                size: 16,
                                                color: Color(0xFF10B981),
                                              ),
                                              const SizedBox(width: 6),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .help,
                                                textStyle: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                ),
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
                        ),
                      ),
                    ),

                    /// 2. SCROLLABLE CONTENT
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // --- ACCOUNT SECTION ---
                          _buildSectionHeader(
                            context: context,
                            title: AppLocalizations.of(context)!.yourAccount,
                            description: AppLocalizations.of(context)!
                                .profileSettingsLableText,
                          ),
                          MenuSectionCard(
                            children: _intersperseDividers(
                              [
                                _buildMenuItem(
                                  context: context,
                                  label: AppLocalizations.of(context)!
                                      .personalInformation,
                                  subtitle: userData!.mobile,
                                  icon: Icons.person_outline_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  iconBgColor: isDark
                                      ? const Color(0xFF1E3A8A).withOpacity(0.3)
                                      : const Color(0xFFEFF6FF),
                                  onTap: () {
                                    Navigator.pushNamed(
                                            context, ProfileInfoPage.routeName,
                                            arguments: arg)
                                        .then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    });
                                  },
                                ),
                                _buildMenuItem(
                                  context: context,
                                  label: userData!.role != 'owner'
                                      ? AppLocalizations.of(context)!.myVehicle
                                      : AppLocalizations.of(context)!
                                          .manageFleet,
                                  subtitle: userData!.role != 'owner'
                                      ? AppLocalizations.of(context)!
                                          .myVehiclesLableText
                                      : AppLocalizations.of(context)!
                                          .manageFleetLableText,
                                  icon: Icons.directions_car_outlined,
                                  iconColor: const Color(0xFF6366F1),
                                  iconBgColor: isDark
                                      ? const Color(0xFF312E81).withOpacity(0.3)
                                      : const Color(0xFFEEF2FF),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    VehicleDataPage.routeName,
                                    arguments: VehicleDataArguments(from: 0),
                                  ),
                                ),
                                _buildMenuItem(
                                  context: context,
                                  label:
                                      AppLocalizations.of(context)!.documents,
                                  subtitle: AppLocalizations.of(context)!
                                      .documentLableText,
                                  icon: Icons.description_outlined,
                                  iconColor: const Color(0xFF10B981),
                                  iconBgColor: isDark
                                      ? const Color(0xFF064E3B).withOpacity(0.3)
                                      : const Color(0xFFECFDF5),
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                            DriverProfilePage.routeName,
                                            arguments: VehicleUpdateArguments(
                                                from: 'docs'))
                                        .then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(UpdateEvent());
                                    });
                                  },
                                ),
                                if (userData!.showWalletFeatureOnMobileApp ==
                                    '1')
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!.wallet,
                                    subtitle: AppLocalizations.of(context)!
                                        .walletLableText,
                                    icon: Icons.account_balance_wallet_outlined,
                                    iconColor: const Color(0xFFD946EF),
                                    iconBgColor: isDark
                                        ? const Color(0xFF701A75)
                                            .withOpacity(0.3)
                                        : const Color(0xFFFDF4FF),
                                    onTap: () => Navigator.pushNamed(
                                        context, WalletHistoryPage.routeName),
                                  ),
                                if (userData!.role == 'owner') ...[
                                  _buildMenuItem(
                                    context: context,
                                    label:
                                        AppLocalizations.of(context)!.drivers,
                                    subtitle: AppLocalizations.of(context)!
                                        .fleetDriverLableText,
                                    icon: Icons.local_shipping_outlined,
                                    iconColor: const Color(0xFFF97316),
                                    iconBgColor: isDark
                                        ? const Color(0xFF7C2D12)
                                            .withOpacity(0.3)
                                        : const Color(0xFFFFF7ED),
                                    onTap: () => Navigator.pushNamed(
                                        context, FleetDriversPage.routeName),
                                  ),
                                  _buildMenuItem(
                                    context: context,
                                    label:
                                        AppLocalizations.of(context)!.dashboard,
                                    subtitle: AppLocalizations.of(context)!
                                        .dashboardLableText,
                                    icon: Icons.dashboard_outlined,
                                    iconColor: const Color(0xFF84CC16),
                                    iconBgColor: isDark
                                        ? const Color(0xFF3F6212)
                                            .withOpacity(0.3)
                                        : const Color(0xFFF7FEE7),
                                    onTap: () => Navigator.pushNamed(
                                        context, OwnerDashboard.routeName,
                                        arguments:
                                            OwnerDashboardArguments(from: '')),
                                  ),
                                ],
                              ],
                              context,
                            ),
                          ),

                          // --- BENEFITS SECTION ---
                          if (userData!.role == 'driver') ...[
                            _buildSectionHeader(
                              context: context,
                              title: AppLocalizations.of(context)!.benefits,
                              description: AppLocalizations.of(context)!
                                  .benefitsLableText,
                            ),
                            MenuSectionCard(
                              children: _intersperseDividers(
                                [
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .myEarnings,
                                    subtitle: AppLocalizations.of(context)!
                                        .earningsLableText,
                                    icon: Icons.attach_money_rounded,
                                    iconColor: const Color(0xFF10B981),
                                    iconBgColor: isDark
                                        ? const Color(0xFF064E3B)
                                            .withOpacity(0.3)
                                        : const Color(0xFFECFDF5),
                                    onTap: () => Navigator.pushNamed(
                                        context, EarningsPage.routeName,
                                        arguments: EarningArguments(
                                            from: 'dashboard')),
                                  ),
                                  _buildMenuItem(
                                    context: context,
                                    label:
                                        AppLocalizations.of(context)!.history,
                                    subtitle: AppLocalizations.of(context)!
                                        .historyLableText,
                                    icon: Icons.history_rounded,
                                    iconColor: const Color(0xFF64748B),
                                    iconBgColor: isDark
                                        ? const Color(0xFF334155)
                                            .withOpacity(0.3)
                                        : const Color(0xFFF1F5F9),
                                    onTap: () => Navigator.pushNamed(
                                        context, HistoryPage.routeName,
                                        arguments: HistoryAccountPageArguments(
                                            isFrom: 'account',
                                            isSupportTicketEnabled: userData!
                                                .enableSupportTicketFeature,
                                            enableInvoiceDownload: userData!
                                                .enableInvoiceDownload)),
                                  ),
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .reportsText,
                                    subtitle: AppLocalizations.of(context)!
                                        .reportsLableText,
                                    icon: Icons.bar_chart_outlined,
                                    iconColor: const Color(0xFF3B82F6),
                                    iconBgColor: isDark
                                        ? const Color(0xFF1E3A8A)
                                            .withOpacity(0.3)
                                        : const Color(0xFFEFF6FF),
                                    onTap: () => Navigator.pushNamed(
                                        context, ReportsPage.routeName),
                                  ),
                                  if (userData!.showDriverLevel == true)
                                    _buildMenuItem(
                                      context: context,
                                      label: AppLocalizations.of(context)!
                                          .rewardsText,
                                      subtitle: AppLocalizations.of(context)!
                                          .rewardsLableText,
                                      icon: Icons.card_giftcard_rounded,
                                      iconColor: const Color(0xFFEC4899),
                                      iconBgColor: isDark
                                          ? const Color(0xFF9D174D)
                                              .withOpacity(0.3)
                                          : const Color(0xFFFDF2F8),
                                      onTap: () => Navigator.pushNamed(
                                          context, RewardsPage.routeName),
                                    ),
                                  if (userData!.showIncentiveFeatureForDriver ==
                                          "1" &&
                                      userData!.availableIncentive != null)
                                    _buildMenuItem(
                                      context: context,
                                      label: AppLocalizations.of(context)!
                                          .incentives,
                                      subtitle: AppLocalizations.of(context)!
                                          .incentivesLableText,
                                      icon: Icons.workspace_premium_outlined,
                                      iconColor: const Color(0xFFF59E0B),
                                      iconBgColor: isDark
                                          ? const Color(0xFF78350F)
                                              .withOpacity(0.3)
                                          : const Color(0xFFFEF3C7),
                                      onTap: () => Navigator.pushNamed(
                                          context, IncentivePage.routeName),
                                    ),
                                  if (userData!.showDriverLevel == true)
                                    _buildMenuItem(
                                      context: context,
                                      label: AppLocalizations.of(context)!
                                          .levelupText,
                                      subtitle: AppLocalizations.of(context)!
                                          .levelUpLableText,
                                      icon: Icons.trending_up_rounded,
                                      iconColor: const Color(0xFF3B82F6),
                                      iconBgColor: isDark
                                          ? const Color(0xFF1E3A8A)
                                              .withOpacity(0.3)
                                          : const Color(0xFFEFF6FF),
                                      onTap: () => Navigator.pushNamed(
                                          context, DriverLevelsPage.routeName),
                                    ),
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .referAndEarn,
                                    subtitle: AppLocalizations.of(context)!
                                        .referralLableText,
                                    icon: Icons.group_outlined,
                                    iconColor: const Color(0xFFF59E0B),
                                    iconBgColor: isDark
                                        ? const Color(0xFF78350F)
                                            .withOpacity(0.3)
                                        : const Color(0xFFFEF3C7),
                                    onTap: () => Navigator.pushNamed(
                                        context, ReferralPage.routeName,
                                        arguments: ReferralArguments(
                                            title: AppLocalizations.of(context)!
                                                .referAndEarn,
                                            userData: arg.userData)),
                                  ),
                                ],
                                context,
                              ),
                            ),
                          ],

                          // --- PREFERENCES SECTION ---
                          _buildSectionHeader(
                            context: context,
                            title: AppLocalizations.of(context)!.preferences,
                            description: AppLocalizations.of(context)!
                                .preferencesLableText,
                          ),
                          MenuSectionCard(
                            children: _intersperseDividers(
                              [
                                if (userData!.role == 'driver' &&
                                    userData!.hasSubscription! &&
                                    (userData!.driverMode == 'subscription' ||
                                        userData!.driverMode == 'both'))
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .mySubscription,
                                    subtitle: AppLocalizations.of(context)!
                                        .subscriptionLableText,
                                    icon: Icons.credit_card_outlined,
                                    iconColor: const Color(0xFF6366F1),
                                    iconBgColor: isDark
                                        ? const Color(0xFF312E81)
                                            .withOpacity(0.3)
                                        : const Color(0xFFEEF2FF),
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                              SubscriptionPage.routeName,
                                              arguments:
                                                  SubscriptionPageArguments(
                                                      isFromAccPage: true))
                                          .then((value) {
                                        if (!context.mounted) return;
                                        context
                                            .read<AccBloc>()
                                            .add(UpdateEvent());
                                      });
                                    },
                                  ),
                                if (userData!.role != 'owner')
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .notifications,
                                    subtitle: AppLocalizations.of(context)!
                                        .notificationLableText,
                                    icon: Icons.notifications_none_rounded,
                                    iconColor: const Color(0xFFEF4444),
                                    iconBgColor: isDark
                                        ? const Color(0xFF7F1D1D)
                                            .withOpacity(0.3)
                                        : const Color(0xFFFEF2F2),
                                    onTap: () => Navigator.pushNamed(
                                        context, NotificationPage.routeName),
                                  ),
                                _buildMenuItem(
                                  context: context,
                                  label:
                                      AppLocalizations.of(context)!.languages,
                                  subtitle: AppLocalizations.of(context)!
                                      .languagesLableText,
                                  icon: Icons.language_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  iconBgColor: isDark
                                      ? const Color(0xFF1E3A8A).withOpacity(0.3)
                                      : const Color(0xFFEFF6FF),
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                            ChooseLanguagePage.routeName,
                                            arguments: ChangeLanguageArguments(
                                                from: 1))
                                        .then((value) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(AccGetDirectionEvent());
                                    });
                                  },
                                ),
                                if (userData!.role != 'owner' &&
                                    userData!.enableMyRouteFeature == '1')
                                  _buildMenuItem(
                                    context: context,
                                    label: AppLocalizations.of(context)!
                                        .myRouteBooking,
                                    subtitle: AppLocalizations.of(context)!
                                        .myRouteBookingLableText,
                                    icon: Icons.location_on_outlined,
                                    iconColor: const Color(0xFF10B981),
                                    iconBgColor: isDark
                                        ? const Color(0xFF064E3B)
                                            .withOpacity(0.3)
                                        : const Color(0xFFECFDF5),
                                    showroute: true,
                                    showrouteValue:
                                        userData!.enableMyRouteBooking == '1',
                                    onTap: () {
                                      Navigator.pushNamed(
                                              context, RouteBooking.routeName)
                                          .then((value) {
                                        accBloc.add(AccGetUserDetailsEvent());
                                      });
                                    },
                                  ),
                                if (userData!.role != 'owner')
                                  _buildMenuItem(
                                    context: context,
                                    label:
                                        AppLocalizations.of(context)!.sosText,
                                    subtitle: AppLocalizations.of(context)!
                                        .sosLableText,
                                    icon: Icons.support_agent_rounded,
                                    iconColor: const Color(0xFFEF4444),
                                    iconBgColor: isDark
                                        ? const Color(0xFF7F1D1D)
                                            .withOpacity(0.3)
                                        : const Color(0xFFFEF2F2),
                                    onTap: () {
                                      Navigator.pushNamed(
                                              context, SosPage.routeName,
                                              arguments: SOSPageArguments(
                                                  sosData: userData!.sos!.data))
                                          .then((value) {
                                        if (!context.mounted || value == null) {
                                          return;
                                        }
                                        final sos = value as List<SOSDatum>;
                                        context.read<AccBloc>().sosdata = sos;
                                        userData!.sos!.data = sos;
                                        context
                                            .read<AccBloc>()
                                            .add(UpdateEvent());
                                      });
                                    },
                                  ),
                              ],
                              context,
                            ),
                          ),

                          // --- SETTINGS SECTION ---
                          _buildSectionHeader(
                            context: context,
                            title: AppLocalizations.of(context)!.settings,
                            description: AppLocalizations.of(context)!
                                .appSettingsLableText,
                          ),
                          MenuSectionCard(
                            children: _intersperseDividers(
                              [
                                _buildMenuItem(
                                  context: context,
                                  label: AppLocalizations.of(context)!.settings,
                                  subtitle: AppLocalizations.of(context)!
                                      .settingsLableText,
                                  icon: Icons.settings_outlined,
                                  iconColor: const Color(0xFF64748B),
                                  iconBgColor: isDark
                                      ? const Color(0xFF334155).withOpacity(0.3)
                                      : const Color(0xFFF1F5F9),
                                  onTap: () => Navigator.pushNamed(
                                      context, SettingsPage.routeName),
                                ),
                                _buildMenuItem(
                                  context: context,
                                  label: AppLocalizations.of(context)!.logout,
                                  subtitle: AppLocalizations.of(context)!
                                      .logoutLableText,
                                  icon: Icons.logout_rounded,
                                  iconColor: const Color(0xFFEF4444),
                                  iconBgColor: isDark
                                      ? const Color(0xFF7F1D1D).withOpacity(0.3)
                                      : const Color(0xFFFEF2F2),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext _) {
                                        return BlocProvider.value(
                                          value:
                                              BlocProvider.of<AccBloc>(context),
                                          child: CustomDoubleButtonDialoge(
                                            title: AppLocalizations.of(context)!
                                                .comeBackSoon,
                                            content:
                                                AppLocalizations.of(context)!
                                                    .logoutSure,
                                            noBtnName:
                                                AppLocalizations.of(context)!
                                                    .no,
                                            yesBtnName:
                                                AppLocalizations.of(context)!
                                                    .yes,
                                            yesBtnFunc: () {
                                              context
                                                  .read<AccBloc>()
                                                  .add(LogoutEvent());
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                              context,
                            ),
                          ),

                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Menu Group Card Widget ---------------------------------------------------
class MenuSectionCard extends StatelessWidget {
  final List<Widget> children;

  const MenuSectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF131C2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}

// Concentric dotted circles painter
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double radiusFactor;

  DottedCirclePainter({required this.color, required this.radiusFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = min(size.width, size.height) / 2;
    final double radius = maxRadius * radiusFactor;

    final int dotCount = (2 * pi * radius / 6).floor();
    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 2 * pi) / dotCount;
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radiusFactor != radiusFactor;
  }
}

// Dot grid painter for decoration
class DotGridPainter extends CustomPainter {
  final Color color;

  DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    double spacingX = 6;
    double spacingY = 6;
    int cols = 5;
    int rows = 4;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacingX + 3, r * spacingY + 3),
          1.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// Section Header Widget
Widget _buildSectionHeader({
  required BuildContext context,
  required String title,
  required String description,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12, left: 2, right: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            MyText(
              text: title,
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        MyText(
          text: description,
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    ),
  );
}

// Menu Item Widget
Widget _buildMenuItem({
  required BuildContext context,
  required String label,
  required String subtitle,
  required VoidCallback onTap,
  IconData? icon,
  String? imagePath,
  Color? iconColor,
  Color? iconBgColor,
  bool showroute = false,
  bool showrouteValue = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor ??
                  (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(
                    icon,
                    color: iconColor ??
                        (isDark ? Colors.white : const Color(0xFF475569)),
                    size: 20,
                  )
                : (imagePath != null
                    ? Image.asset(
                        imagePath,
                        width: 20,
                        height: 20,
                        color: iconColor ??
                            (isDark ? Colors.white : const Color(0xFF475569)),
                        fit: BoxFit.contain,
                      )
                    : const SizedBox()),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: label,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  MyText(
                    text: subtitle,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (showroute)
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: showrouteValue,
                activeColor: isDark ? Colors.white : AppColors.primary,
                activeTrackColor: isDark
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.3),
                inactiveTrackColor:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                onChanged: null,
              ),
            )
          else
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              size: 20,
            ),
        ],
      ),
    ),
  );
}

// Intersperse divider widgets helper
List<Widget> _intersperseDividers(List<Widget> items, BuildContext context) {
  if (items.isEmpty) return [];
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final List<Widget> result = [];
  for (int i = 0; i < items.length; i++) {
    result.add(items[i]);
    if (i < items.length - 1) {
      result.add(
        Divider(
          height: 1,
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          indent: 70,
          endIndent: 16,
        ),
      );
    }
  }
  return result;
}

Widget circleProfile(Size size, BuildContext context) {
  return CircleAvatar(
      radius: size.width * 0.09,
      backgroundColor: Theme.of(context).dividerColor,
      backgroundImage: userData!.profilePicture.isNotEmpty
          ? NetworkImage(userData!.profilePicture)
          : null);
}

Widget customDivider(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Divider(
      height: 1,
      thickness: 0.4,
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    ),
  );
}

Widget weeklyEarningsWidget(BuildContext context, Size size) {
  final bloc = context.watch<AccBloc>();

  final amount = (bloc.earningsList.isNotEmpty)
      ? '${bloc.earningCurrency} ${bloc.earningsList[bloc.choosenEarningsWeeks!].totalAmount}'
      : '';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                text: AppLocalizations.of(context)!.weeklyEarnings,
                textStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
              MyText(
                text: amount,
                textStyle: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ],
    ),
  );
}
