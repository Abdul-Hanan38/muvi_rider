import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_divider.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class EarningsWidget extends StatelessWidget {
  final BuildContext cont;
  const EarningsWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final textLightColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final homeBloc = context.read<HomeBloc>();

    // Calculate Active Time String using original logic
    final activeMinutesStr =
        (double.tryParse(userData!.totalMinutesOnline!) ?? 0).toInt();
    final activeDuration = Duration(minutes: activeMinutesStr);
    final activeTimeText =
        '${activeDuration.inHours.toString().padLeft(2, '0')}:${(activeDuration.inMinutes % 60).toString().padLeft(2, '0')} ${activeDuration.inHours == 0 ? 'min' : 'hr'}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        key: const Key('switcher'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
          SizedBox(height: size.width * 0.025),

          // OUTSTATION SECTION (UNCHANGED LOGIC)
          if (homeBloc.outStationList.isNotEmpty) ...[
            InkWell(
              onTap: () {
                homeBloc.add(ShowoutsationpageEvent(isVisible: true));
              },
              child: Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withAlpha((0.15 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.route,
                            size: 18, color: AppColors.lightGreen),
                        const SizedBox(width: 8),
                        MyText(
                          text: AppLocalizations.of(context)!.outstationRides,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.lightGreen,
                                  ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.textView,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14)
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Today's Earnings Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        homeBloc.add(GetUserDetailsEvent());
                      },
                      child: MyText(
                        text: AppLocalizations.of(context)!.todaysEarnings,
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textLightColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      text:
                          '${userData!.currencySymbol}${userData!.totalEarnings}',
                      textStyle: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textDarkColor,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  homeBloc.add(ChangeMenuEvent(menu: 2));
                  homeBloc.add(GetUserDetailsEvent());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E3B54)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      MyText(
                        text: AppLocalizations.of(context)!.textView,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.width * 0.025),

          const HorizontalDotDividerWidget(),
          SizedBox(height: size.width * 0.025),

          // Stats Section (Row of 3 cards)
          Row(
            children: [
              // Active Time Card
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C1A10)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF97316),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.access_time_filled,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyText(
                        text: activeTimeText,
                        textStyle: TextStyle(
                          color: textDarkColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        text: AppLocalizations.of(context)!.active,
                        textStyle: TextStyle(
                          color: textLightColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Distance Card
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1E36)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyText(
                        text: '${userData!.totalKms} ${userData!.distanceUnit}',
                        textStyle: TextStyle(
                          color: textDarkColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        text: AppLocalizations.of(context)!.distance,
                        textStyle: TextStyle(
                          color: textLightColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Rides Taken Card
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0E2515)
                        : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      MyText(
                        text: userData!.totalRidesTaken!,
                        textStyle: TextStyle(
                          color: textDarkColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        text: AppLocalizations.of(context)!.ridesTaken,
                        textStyle: TextStyle(
                          color: textLightColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Complete More Rides Banner Card
          if (homeBloc.rideList.isNotEmpty) ...[
            SizedBox(height: size.width * 0.02),
            InkWell(
              onTap: () {
                // Switches to main home view
                homeBloc.add(UpdateEvent());
                context.read<HomeBloc>().add(ShowBiddingPageEvent());
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B).withOpacity(0.4)
                      : const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1E5AF3).withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.wallet,
                      width: 44,
                      height: 44,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E5AF3).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Color(0xFF1E5AF3),
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!
                                .completeMoreRidesText,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .increaseYourEarningsText,
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: textLightColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF1E5AF3),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
