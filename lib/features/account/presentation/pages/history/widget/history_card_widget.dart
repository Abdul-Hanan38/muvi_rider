import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/history_model.dart';

class HistoryCardWidget extends StatelessWidget {
  final BuildContext cont;
  final HistoryData history;
  const HistoryCardWidget({
    super.key,
    required this.cont,
    required this.history,
  });

  Map<String, String> _splitDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return {'date': '', 'time': ''};
    }
    if (dateTimeStr.contains(',')) {
      final parts = dateTimeStr.split(',');
      return {
        'date': parts[0].trim(),
        'time': parts.sublist(1).join(',').trim(),
      };
    }
    final regex = RegExp(r'(.*)\s(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm))');
    final match = regex.firstMatch(dateTimeStr);
    if (match != null && match.groupCount == 2) {
      return {
        'date': match.group(1)!.trim(),
        'time': match.group(2)!.trim(),
      };
    }
    final words = dateTimeStr.split(' ');
    if (words.length >= 3 &&
        (words.last.toUpperCase() == 'AM' ||
            words.last.toUpperCase() == 'PM')) {
      final time = '${words[words.length - 2]} ${words.last}';
      final date = words.sublist(0, words.length - 2).join(' ');
      return {
        'date': date.trim(),
        'time': time.trim(),
      };
    }
    return {'date': dateTimeStr, 'time': ''};
  }

  Color _getCarColor(String colorName) {
    switch (colorName.toLowerCase().trim()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        if (colorName.startsWith('#')) {
          try {
            final hex = colorName.replaceAll('#', '');
            return Color(int.parse('FF$hex', radix: 16));
          } catch (_) {}
        }
        return Colors.grey;
    }
  }

  String _getFareText() {
    if (history.isBidRide == 1) {
      return '${history.requestedCurrencySymbol} ${history.acceptedRideFare}';
    } else if (history.isCompleted == 1) {
      try {
        final symbol = history.requestBill.data.requestedCurrencySymbol;
        final amount = history.requestBill.data.totalAmount;
        return '$symbol $amount';
      } catch (_) {
        return '${history.requestedCurrencySymbol} ${history.requestEtaAmount}';
      }
    } else {
      return '${history.requestedCurrencySymbol} ${history.requestEtaAmount}';
    }
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    final isCompleted = history.isCompleted == 1;
    final isCancelled = history.isCancelled == 1;
    final isLater = history.isLater == true;

    String text = '';
    Color bg;
    Color textIconColor;
    Color borderColor;
    IconData icon;

    if (isCompleted) {
      text = AppLocalizations.of(context)!.completed;
      bg = isDark ? const Color(0x1F22C55E) : const Color(0xFFDCFCE7);
      textIconColor =
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
      borderColor = isDark ? const Color(0x3D22C55E) : const Color(0xFF86EFAC);
      icon = Icons.check_circle_outline_rounded;
    } else if (isCancelled) {
      text = AppLocalizations.of(context)!.cancelled;
      bg = isDark ? const Color(0x1FEF4444) : const Color(0xFFFEE2E2);
      textIconColor =
          isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);
      borderColor = isDark ? const Color(0x3DEF4444) : const Color(0xFFFCA5A5);
      icon = Icons.cancel_outlined;
    } else if (isLater) {
      if (history.isRental == false) {
        text = AppLocalizations.of(context)!.upcoming;
      } else {
        text =
            '${AppLocalizations.of(context)!.rental} ${history.rentalPackageName}';
      }
      bg = isDark ? const Color(0x1F3B82F6) : const Color(0xFFEFF6FF);
      textIconColor =
          isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
      borderColor = isDark ? const Color(0x3D3B82F6) : const Color(0xFF93C5FD);
      icon = Icons.watch_later_outlined;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textIconColor, size: 14),
          const SizedBox(width: 4),
          MyText(
            text: text,
            textStyle: TextStyle(
              color: textIconColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBgColor = isDark ? const Color(0xFF131C2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final dateStr = (history.laterRide == true)
        ? history.tripStartTimeWithDate
        : history.isCompleted == 1
            ? history.convertedCompletedAt
            : history.isCancelled == 1
                ? history.convertedCancelledAt
                : history.convertedCreatedAt;

    final dateTimeMap = _splitDateTime(dateStr);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorderColor, width: 1),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Calendar & Price details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Calendar Icon Container
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0x1F3B82F6)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Date/Time Column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: dateTimeMap['date'] ?? '',
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: dateTimeMap['time'] ?? '',
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            if (history.returnTime != null &&
                                history.returnTime.toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .historyReturnTimeValue
                                    .replaceAll(
                                        '*****', history.returnTime.toString()),
                                textStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    // Price Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText(
                          text: _getFareText(),
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: AppLocalizations.of(context)!.totalFare,
                          textStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Middle Section: Dynamic Timeline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 18,
                            child: Column(
                              children: [
                                const SizedBox(height: 6),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 1.5,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.15)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0x1F22C55E)
                                            : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .historyPickupCaps,
                                        textStyle:
                                            theme.textTheme.bodySmall!.copyWith(
                                          color: isDark
                                              ? const Color(0xFF4ADE80)
                                              : const Color(0xFF15803D),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    MyText(
                                      text: history.cvTripStartTime,
                                      textStyle:
                                          theme.textTheme.bodySmall!.copyWith(
                                        color: subtitleColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                MyText(
                                  text: history.pickAddress,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Drop Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 18,
                          child: Column(
                            children: [
                              SizedBox(height: 6),
                              Icon(
                                Icons.location_on,
                                color: Color(0xFFEF4444),
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0x1FEF4444)
                                          : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .historyDropCaps,
                                      textStyle:
                                          theme.textTheme.bodySmall!.copyWith(
                                        color: isDark
                                            ? const Color(0xFFFCA5A5)
                                            : const Color(0xFFB91C1C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  MyText(
                                    text: history.cvCompletedAt,
                                    textStyle:
                                        theme.textTheme.bodySmall!.copyWith(
                                      color: subtitleColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              MyText(
                                text: (history.requestStops != null &&
                                        history.requestStops!.isNotEmpty)
                                    ? history.requestStops!.last['address']
                                    : history.dropAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                    height: 1,
                    thickness: 1,
                  ),
                ),

                // Bottom Section: Vehicle & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Vehicle Info
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: history.vehicleTypeImage.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: history.vehicleTypeImage,
                                    fit: BoxFit.contain,
                                    placeholder: (_, __) => const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) =>
                                        Image.asset(AppImages.noImage),
                                  )
                                : Image.asset(AppImages.noImage),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: MyText(
                                        text: history.vehicleTypeName,
                                        overflow: TextOverflow.ellipsis,
                                        textStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    if (history.isOutStation == 1) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0x1F60A5FA)
                                              : const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0x3D60A5FA)
                                                : const Color(0xFF93C5FD),
                                            width: 1,
                                          ),
                                        ),
                                        child: MyText(
                                          text: (history.isRoundTrip == 1)
                                              ? AppLocalizations.of(context)!
                                                  .roundTrip
                                              : AppLocalizations.of(context)!
                                                  .oneWayTrip,
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                            color: isDark
                                                ? const Color(0xFF60A5FA)
                                                : const Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (history.isOutStation == 1 &&
                                    history.isCancelled != 1 &&
                                    history.isCompleted != 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (history.driverDetail != null)
                                          ? AppColors.green.withOpacity(0.1)
                                          : AppColors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: MyText(
                                      text: (history.driverDetail != null)
                                          ? AppLocalizations.of(context)!
                                              .assinged
                                          : AppLocalizations.of(context)!
                                              .unAssinged,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                            color:
                                                (history.driverDetail != null)
                                                    ? AppColors.green
                                                    : AppColors.red,
                                          ),
                                    ),
                                  )
                                else if (history.carColor.isNotEmpty) ...[
                                  // Color Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color:
                                                _getCarColor(history.carColor),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        MyText(
                                          text: history.carColor,
                                          textStyle: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  MyText(
                                    text: history.carColor,
                                    textStyle: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Badge
                    _buildStatusBadge(context, isDark),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
