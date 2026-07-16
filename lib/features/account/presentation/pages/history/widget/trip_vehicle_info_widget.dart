import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class TripVehicleInfoWidget extends StatelessWidget {
  final BuildContext cont;
  final TripHistoryPageArguments arg;
  const TripVehicleInfoWidget({
    super.key,
    required this.cont,
    required this.arg,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium styling colors
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final dividerColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final isCompleted = arg.historyData.isCompleted == 1;

          return Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(width: 1, color: cardBorder),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row - Vehicle and Ride Type Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side - Vehicle image & Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            image: arg.historyData.vehicleTypeImage.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                        arg.historyData.vehicleTypeImage),
                                    fit: BoxFit.cover,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(AppImages.noImage),
                                    fit: BoxFit.cover,
                                  ),
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF8FAFC),
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          text: arg.historyData.vehicleTypeName,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textPrimary,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),

                    // Right Side - Ride Type & Time Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.typeOfRide,
                          textStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: MyText(
                            text: _getRideTypeText(context),
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (arg.historyData.isOutStation == 1) ...[
                          const SizedBox(height: 4),
                          MyText(
                            text: (arg.historyData.isRoundTrip != '')
                                ? AppLocalizations.of(context)!.roundTrip
                                : AppLocalizations.of(context)!.oneWayTrip,
                            textStyle: const TextStyle(
                              color: AppColors.yellowColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        MyText(
                          text: _getFormattedTime(),
                          textStyle: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (isCompleted) ...[
                  const SizedBox(height: 20),
                  Divider(color: dividerColor, height: 1),
                  const SizedBox(height: 16),

                  // Duration & Distance columns side-by-side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Duration column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 16,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                  text: AppLocalizations.of(context)!.duration,
                                  textStyle: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: MyText(
                                text:
                                    '${arg.historyData.totalTime} ${AppLocalizations.of(context)!.mins}',
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vertical divider between Duration and Distance
                      Container(
                        width: 1,
                        height: 36,
                        color: dividerColor,
                      ),

                      // Distance column
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.alt_route_outlined,
                                    size: 16,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  MyText(
                                    text:
                                        AppLocalizations.of(context)!.distance,
                                    textStyle: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 24),
                                child: MyText(
                                  text:
                                      '${arg.historyData.totalDistance} ${arg.historyData.unit}',
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Color row at the bottom
                  if (arg.historyData.carColor.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 16,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 8),
                            MyText(
                              text: AppLocalizations.of(context)!.colorText,
                              textStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF831843).withOpacity(0.2)
                                : const Color(0xFFFCE7F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: MyText(
                            text: arg.historyData.carColor,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? const Color(0xFFF472B6)
                                  : const Color(0xFFDB2777),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getRideTypeText(BuildContext context) {
    final h = arg.historyData;
    if (h.isOutStation == 0 && h.isRental == false && h.goodsType == '-') {
      return AppLocalizations.of(context)!.regular;
    } else if (h.isOutStation == 0 &&
        h.isRental == false &&
        h.goodsType != '-') {
      return AppLocalizations.of(context)!.delivery;
    } else if (h.isOutStation == 0 &&
        h.isRental == true &&
        h.goodsType == '-') {
      return '${AppLocalizations.of(context)!.rental} - ${h.rentalPackageName}';
    } else if (h.isOutStation == 0 &&
        h.isRental == true &&
        h.goodsType != '-') {
      return '${AppLocalizations.of(context)!.deliveryRental} - ${h.rentalPackageName}';
    } else if (h.isOutStation == 1 &&
        h.isRental == false &&
        h.goodsType == '-') {
      return AppLocalizations.of(context)!.outStation;
    } else if (h.isOutStation == 1 &&
        h.isRental == false &&
        h.goodsType != '-') {
      return AppLocalizations.of(context)!.deliveryOutStation;
    }
    return '';
  }

  String _getFormattedTime() {
    final h = arg.historyData;
    if (h.laterRide == true && h.isOutStation == 1) {
      return h.tripStartTime;
    } else if (h.laterRide == true && h.isOutStation != 1) {
      return h.tripStartTimeWithDate;
    } else if (h.isCompleted == 1) {
      return h.convertedCompletedAt;
    } else if (h.isCancelled == 1) {
      return h.convertedCancelledAt;
    } else {
      return h.convertedCreatedAt;
    }
  }
}
