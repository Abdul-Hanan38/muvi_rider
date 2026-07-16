import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/functions.dart';

class BiddingOutStationListWidget extends StatelessWidget {
  final BuildContext cont;
  const BiddingOutStationListWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);

    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();

          return Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                SizedBox(height: size.width * 0.1),

                // ── Top Header ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                        onPressed: () {
                          Future.delayed(const Duration(milliseconds: 100), () {
                            if (!context.mounted) return;
                            context
                                .read<HomeBloc>()
                                .add(ShowoutsationpageEvent(isVisible: false));
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.outStation,
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .browseAndAcceptOutstationRideText,
                              textStyle: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Column(
                      children: [
                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF064E3B)
                                        : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.directions_car_filled,
                                    color: isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF059669),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                  text: AppLocalizations.of(context)!.rides,
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Ride List or Empty State ─────────────────
                        Expanded(
                          child: homeBloc.outStationList.isNotEmpty
                              ? ListView(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  children: homeBloc.outStationList
                                      .asMap()
                                      .map((key, value) {
                                        final List preferenceIcons =
                                            homeBloc.outStationList[key]
                                                    ['preferences_icon'] ??
                                                [];

                                        List stops = [];
                                        if (homeBloc.outStationList[key]
                                                ['trip_stops'] !=
                                            'null') {
                                          stops = jsonDecode(
                                              homeBloc.outStationList[key]
                                                  ['trip_stops']);
                                        }

                                        double dist = calculateDistance(
                                          lat1:
                                              homeBloc.currentLatLng!.latitude,
                                          lon1:
                                              homeBloc.currentLatLng!.longitude,
                                          lat2: homeBloc.outStationList[key]
                                              ['pick_lat'],
                                          lon2: homeBloc.outStationList[key]
                                              ['pick_lng'],
                                          unit: userData?.distanceUnit ?? 'km',
                                        );

                                        // Build timeline items
                                        final List<Map<String, dynamic>>
                                            timelineItems = [];
                                        timelineItems.add({
                                          'address':
                                              homeBloc.outStationList[key]
                                                      ['pick_address'] ??
                                                  '',
                                          'isPickup': true,
                                        });
                                        if (stops.isEmpty &&
                                            homeBloc.outStationList[key]
                                                    ['drop_address'] !=
                                                '') {
                                          timelineItems.add({
                                            'address':
                                                homeBloc.outStationList[key]
                                                        ['drop_address'] ??
                                                    '',
                                            'isPickup': false,
                                          });
                                        } else if (stops.isNotEmpty) {
                                          for (var stop in stops) {
                                            timelineItems.add({
                                              'address': stop['address'] ?? '',
                                              'isPickup': false,
                                            });
                                          }
                                        }

                                        final bool isRejected = (homeBloc
                                                            .outStationList[key]
                                                        ['drivers'] !=
                                                    null &&
                                                (homeBloc.outStationList[key]
                                                                ['drivers'][
                                                            'driver_${userData!.id}'] !=
                                                        null &&
                                                    homeBloc.outStationList[key]
                                                                    ['drivers'][
                                                                'driver_${userData!.id}']
                                                            ['is_rejected'] ==
                                                        'by_user')) ||
                                            homeBloc.bidDeclined;

                                        return MapEntry(
                                          key,
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            margin: const EdgeInsets.only(
                                                bottom: 16),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF161B2E)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isDark
                                                    ? const Color(0xFF232A45)
                                                    : const Color(0xFFF3F4F6),
                                                width: 1,
                                              ),
                                              boxShadow: isDark
                                                  ? []
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.01),
                                                        blurRadius: 10,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // ── User Info Row ──
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              homeBloc.outStationList[
                                                                      key]
                                                                  ['user_img']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          MyText(
                                                            text: homeBloc
                                                                    .outStationList[
                                                                key]['user_name'],
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF1F2937),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.star,
                                                                size: 14,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              const SizedBox(
                                                                  width: 2),
                                                              MyText(
                                                                text:
                                                                    '${homeBloc.outStationList[key]['ratings']}',
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: isDark
                                                                      ? const Color(
                                                                          0xFF9CA3AF)
                                                                      : const Color(
                                                                          0xFF4B5563),
                                                                ),
                                                              ),
                                                              if (homeBloc.outStationList[
                                                                              key]
                                                                          [
                                                                          'completed_ride_count'] !=
                                                                      '0' &&
                                                                  homeBloc.outStationList[
                                                                              key]
                                                                          [
                                                                          'completed_ride_count'] !=
                                                                      0) ...[
                                                                const SizedBox(
                                                                    width: 6),
                                                                MyText(
                                                                  text: '|',
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: isDark
                                                                        ? const Color(
                                                                            0xFF374151)
                                                                        : const Color(
                                                                            0xFFE5E7EB),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),
                                                                MyText(
                                                                  text:
                                                                      '${homeBloc.outStationList[key]['completed_ride_count']} ${AppLocalizations.of(context)!.trips}',
                                                                  textStyle:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: isDark
                                                                        ? const Color(
                                                                            0xFF9CA3AF)
                                                                        : const Color(
                                                                            0xFF4B5563),
                                                                  ),
                                                                ),
                                                              ],
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    // Price + Trip type badge
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        MyText(
                                                          text:
                                                              '${homeBloc.outStationList[key]['currency']} ${homeBloc.outStationList[key]['price']}',
                                                          textStyle: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: isDark
                                                                ? Colors.white
                                                                : const Color(
                                                                    0xFF1F2937),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        MyText(
                                                          text:
                                                              '${dist.toStringAsFixed(2)} ${userData?.distanceUnit.toUpperCase() ?? 'KM'} ${AppLocalizations.of(context)!.away}',
                                                          textStyle:
                                                              const TextStyle(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                        if (homeBloc.outStationList[
                                                                    key]
                                                                ['trip_type'] !=
                                                            null) ...[
                                                          const SizedBox(
                                                              height: 4),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        3),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDark
                                                                  ? const Color(
                                                                      0xFF2D2B00)
                                                                  : const Color(
                                                                      0xFFFFFBEB),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              border: Border.all(
                                                                  color: AppColors
                                                                      .yellowColor
                                                                      .withOpacity(
                                                                          0.5)),
                                                            ),
                                                            child: MyText(
                                                              text:
                                                                  '${homeBloc.outStationList[key]['trip_type']}',
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColors
                                                                    .yellowColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(height: 16),

                                                // ── Dates Row ──
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? const Color(
                                                                0xFF1E294B)
                                                            : const Color(
                                                                0xFFEFF6FF),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_today,
                                                            size: 12,
                                                            color: isDark
                                                                ? AppColors
                                                                    .secondary
                                                                : AppColors
                                                                    .primary,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          MyText(
                                                            text: homeBloc
                                                                    .outStationList[
                                                                key]['start_date'],
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isDark
                                                                  ? AppColors
                                                                      .secondary
                                                                  : AppColors
                                                                      .primary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (homeBloc.outStationList[
                                                            key]['trip_type'] ==
                                                        'Round Trip') ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF1E294B)
                                                              : const Color(
                                                                  0xFFEFF6FF),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .calendar_month,
                                                              size: 12,
                                                              color: isDark
                                                                  ? AppColors
                                                                      .secondary
                                                                  : AppColors
                                                                      .primary,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            MyText(
                                                              text: homeBloc
                                                                      .outStationList[key]
                                                                  [
                                                                  'return_date'],
                                                              textStyle:
                                                                  TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isDark
                                                                    ? AppColors
                                                                        .secondary
                                                                    : AppColors
                                                                        .primary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),

                                                const SizedBox(height: 16),

                                                // ── Dynamic Vertical Timeline ──
                                                Column(
                                                  children: List.generate(
                                                      timelineItems.length,
                                                      (index) {
                                                    final item =
                                                        timelineItems[index];
                                                    final bool isLast = index ==
                                                        timelineItems.length -
                                                            1;
                                                    final bool isPickup =
                                                        item['isPickup'] ??
                                                            false;
                                                    return IntrinsicHeight(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          SizedBox(
                                                            width: 24,
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(
                                                                    height: 2),
                                                                if (isPickup)
                                                                  Container(
                                                                    width: 14,
                                                                    height: 14,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: isDark
                                                                            ? const Color(0xFF34D399)
                                                                            : const Color(0xFF10B981),
                                                                        width:
                                                                            2,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            6,
                                                                        height:
                                                                            6,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          color: isDark
                                                                              ? const Color(0xFF34D399)
                                                                              : const Color(0xFF10B981),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                else
                                                                  Image.asset(
                                                                    AppImages
                                                                        .mapPinNew,
                                                                    width: 14,
                                                                    height: 14,
                                                                  ),
                                                                if (!isLast)
                                                                  Expanded(
                                                                    child:
                                                                        CustomPaint(
                                                                      painter:
                                                                          _VerticalDashedLinePainter(
                                                                        color: isDark
                                                                            ? const Color(0xFF374151)
                                                                            : const Color(0xFFD1D5DB),
                                                                        strokeWidth:
                                                                            1.5,
                                                                        dashHeight:
                                                                            4,
                                                                        dashSpace:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  )
                                                                else
                                                                  const SizedBox(
                                                                      height:
                                                                          12),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          12),
                                                              child: MyText(
                                                                text: item[
                                                                        'address'] ??
                                                                    '',
                                                                textStyle:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isDark
                                                                      ? const Color(
                                                                          0xFFD1D5DB)
                                                                      : const Color(
                                                                          0xFF374151),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),

                                                // ── Preferences ──
                                                if (preferenceIcons
                                                    .isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${AppLocalizations.of(context)!.preferences} :- ',
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9CA3AF)
                                                              : const Color(
                                                                  0xFF6B7280),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            _preferenceIconsRow(
                                                          context: context,
                                                          icons:
                                                              preferenceIcons,
                                                          size: size.width,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                // ── Pet / Luggage badges ──
                                                if (homeBloc.outStationList[key]
                                                            [
                                                            'is_pet_available'] ==
                                                        true ||
                                                    homeBloc.outStationList[key]
                                                            [
                                                            'is_luggage_available'] ==
                                                        true) ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${AppLocalizations.of(context)!.preferences} :- ',
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9CA3AF)
                                                              : const Color(
                                                                  0xFF6B7280),
                                                        ),
                                                      ),
                                                      if (homeBloc.outStationList[
                                                                  key][
                                                              'is_pet_available'] ==
                                                          true)
                                                        Icon(
                                                          Icons.pets,
                                                          size:
                                                              size.width * 0.05,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9CA3AF)
                                                              : const Color(
                                                                  0xFF4B5563),
                                                        ),
                                                      if (homeBloc.outStationList[
                                                                  key][
                                                              'is_luggage_available'] ==
                                                          true)
                                                        Icon(
                                                          Icons.luggage,
                                                          size:
                                                              size.width * 0.05,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9CA3AF)
                                                              : const Color(
                                                                  0xFF4B5563),
                                                        ),
                                                    ],
                                                  ),
                                                ],

                                                // ── Instruction ──
                                                if (homeBloc.outStationList[key]
                                                        [
                                                        'pick_poc_instruction'] !=
                                                    '') ...[
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MyText(
                                                        text:
                                                            '${AppLocalizations.of(context)!.instruction} :- ',
                                                        textStyle: TextStyle(
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF9CA3AF)
                                                              : const Color(
                                                                  0xFF6B7280),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: MyText(
                                                          text: homeBloc
                                                              .outStationList[
                                                                  key][
                                                                  'pick_poc_instruction']
                                                              .toString(),
                                                          textStyle: TextStyle(
                                                            fontSize: 13,
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFFD1D5DB)
                                                                : const Color(
                                                                    0xFF4B5563),
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],

                                                const SizedBox(height: 16),

                                                // ── Action Buttons ──
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: CustomButton(
                                                        buttonName:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .skip,
                                                        textSize: 15,
                                                        textColor:
                                                            AppColors.red,
                                                        onTap: () {
                                                          homeBloc.add(
                                                              DeclineBidRideEvent(
                                                            id: homeBloc
                                                                    .outStationList[
                                                                key]['request_id'],
                                                          ));
                                                          homeBloc.add(
                                                              ShowoutsationpageEvent(
                                                                  isVisible:
                                                                      false));
                                                        },
                                                        width: double.infinity,
                                                        height: 48,
                                                        borderRadius: 12,
                                                        buttonColor: isDark
                                                            ? const Color(
                                                                0xFF2D1E24)
                                                            : const Color(
                                                                0xFFFFF5F5),
                                                        border: Border.all(
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF7F1D1D)
                                                              : const Color(
                                                                  0xFFFCA5A5),
                                                          width: 1,
                                                        ),
                                                        leading: const Icon(
                                                          Icons.close_rounded,
                                                          color: AppColors.red,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: CustomButton(
                                                        buttonName:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .accept,
                                                        textSize: 15,
                                                        textColor: Colors.white,
                                                        onTap: () {
                                                          homeBloc.add(
                                                              ShowBidRideEvent(
                                                            id: homeBloc
                                                                    .outStationList[
                                                                key]['request_id'],
                                                            pickLat: homeBloc
                                                                    .outStationList[
                                                                key]['pick_lat'],
                                                            pickLng: homeBloc
                                                                    .outStationList[
                                                                key]['pick_lng'],
                                                            dropLat: homeBloc
                                                                    .outStationList[
                                                                key]['drop_lat'],
                                                            dropLng: homeBloc
                                                                    .outStationList[
                                                                key]['drop_lng'],
                                                            stops: stops,
                                                            pickAddress: homeBloc
                                                                    .outStationList[key]
                                                                [
                                                                'pick_address'],
                                                            dropAddress: homeBloc
                                                                    .outStationList[key]
                                                                [
                                                                'drop_address'],
                                                            acceptedRideFare:
                                                                homeBloc.outStationList[
                                                                        key]
                                                                    ['price'],
                                                            polyString: homeBloc
                                                                        .outStationList[key]
                                                                    [
                                                                    'polyline'] ??
                                                                '',
                                                            distance: homeBloc
                                                                    .outStationList[
                                                                key]['distance'],
                                                            duration: homeBloc
                                                                        .outStationList[key]
                                                                    [
                                                                    'duration'] ??
                                                                '0',
                                                            isOutstationRide:
                                                                true,
                                                            isNormalBidRide:
                                                                false,
                                                          ));
                                                        },
                                                        width: double.infinity,
                                                        height: 48,
                                                        borderRadius: 12,
                                                        buttonColor: isDark
                                                            ? const Color(
                                                                0xFF3B82F6)
                                                            : const Color(
                                                                0xFF0038FF),
                                                        leading: const Icon(
                                                          Icons
                                                              .check_circle_outline_rounded,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // ── Rejected Notice ──
                                                if (isRejected) ...[
                                                  const SizedBox(height: 8),
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .outstationRejectText,
                                                    maxLines: 4,
                                                    textAlign: TextAlign.center,
                                                    textStyle: const TextStyle(
                                                      color: AppColors.red,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                      .values
                                      .toList(),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFEFF6FF),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppImages.noBiddingFoundImage,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .noRequest,
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32),
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .notifyNewOutstationRequestAvailableText,
                                        textStyle: TextStyle(
                                          fontSize: 13,
                                          color: isDark
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF6B7280),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        // ── Tip Box ──────────────────────────────────
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF16223F)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : Colors.white,
                                ),
                                child: const Icon(
                                  Icons.lightbulb_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .historyTipText,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .acceptOutstationRidesEarlyText,
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _preferenceIconsRow({
    required BuildContext context,
    required List icons,
    required double size,
  }) {
    if (icons.isEmpty) return const SizedBox();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: List.generate(icons.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(1),
              child: CachedNetworkImage(
                imageUrl: icons[index].toString(),
                fit: BoxFit.cover,
                width: 15,
                height: 15,
                placeholder: (_, __) => const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.error,
                  size: 14,
                  color: Colors.red,
                ),
              ),
            ),
            if (index != icons.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  ',',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  _VerticalDashedLinePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashHeight = 4,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashHeight != dashHeight ||
        oldDelegate.dashSpace != dashSpace;
  }
}
