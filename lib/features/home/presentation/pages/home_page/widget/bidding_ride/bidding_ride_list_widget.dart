import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../core/utils/functions.dart';

class BiddingRideListWidget extends StatefulWidget {
  final BuildContext cont;
  const BiddingRideListWidget({super.key, required this.cont});

  @override
  State<BiddingRideListWidget> createState() => _BiddingRideListWidgetState();
}

class _BiddingRideListWidgetState extends State<BiddingRideListWidget> {
  final ScrollController _chipScrollController = ScrollController();

  double _parseDistance(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to round to the nearest 0.10 interval
  String _formatPrice(dynamic price) {
    if (price == null) return '0.00';
    double parsed = 0.0;
    if (price is num) {
      parsed = price.toDouble();
    } else if (price is String) {
      parsed = double.tryParse(price) ?? 0.0;
    }
    return ((parsed * 10).round() / 10).toStringAsFixed(2);
  }

  String _rideInstruction(Map ride) {
    const pickupKeys = [
      'pick_poc_instruction',
      'pickup_poc_instruction',
      'pickPocInstruction',
      'pickupPocInstruction',
      'taxi_instruction',
    ];
    const dropoffKeys = [
      'drop_poc_instruction',
      'dropoff_poc_instruction',
      'dropPocInstruction',
      'dropoffPocInstruction',
    ];

    String firstInstruction(List<String> keys) {
      for (final key in keys) {
        final instruction = ride[key]?.toString().trim() ?? '';
        if (instruction.isNotEmpty && instruction.toLowerCase() != 'null') {
          return instruction;
        }
      }
      return '';
    }

    final pickup = firstInstruction(pickupKeys);
    final dropoff = firstInstruction(dropoffKeys);
    if (pickup.isNotEmpty && dropoff.isNotEmpty && pickup != dropoff) {
      return '$pickup • $dropoff';
    }
    if (pickup.isNotEmpty) return pickup;
    if (dropoff.isNotEmpty) return dropoff;

    for (final key in const ['instruction', 'instructions']) {
      final instruction = ride[key]?.toString().trim() ?? '';
      if (instruction.isNotEmpty && instruction.toLowerCase() != 'null') {
        return instruction;
      }
    }
    return '';
  }

  void _scheduleChipScroll(int index, int total) {
    if (total <= 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chipScrollController.hasClients) return;
      final maxScroll = _chipScrollController.position.maxScrollExtent;
      if (maxScroll <= 0) return;
      final double step =
          (maxScroll / (total - 1)).clamp(0.0, maxScroll).toDouble();
      final int clampedIndex = index.clamp(0, total - 1);
      final double target =
          (step * clampedIndex).clamp(0.0, maxScroll).toDouble();
      _chipScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);

    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final homeBloc = context.read<HomeBloc>();
          final distanceOptions = homeBloc.distanceBetweenList;
          final hasDistanceOptions = distanceOptions.isNotEmpty;
          final List<double> distanceValues = hasDistanceOptions
              ? distanceOptions
                  .map<double>((option) => _parseDistance(
                      option['dist'] ?? option['value'] ?? option['name']))
                  .toList()
              : const [0];
          int selectedIndex = 0;
          if (hasDistanceOptions) {
            final currentDistance =
                homeBloc.distanceBetween ?? distanceValues.first;
            selectedIndex = distanceValues
                .indexWhere((value) => (value - currentDistance).abs() < 0.001);
            if (selectedIndex == -1) {
              selectedIndex = distanceValues
                  .indexWhere((value) => value >= currentDistance);
              if (selectedIndex == -1) {
                selectedIndex = distanceValues.length - 1;
              }
            }
          }
          if (hasDistanceOptions) {
            _scheduleChipScroll(selectedIndex, distanceOptions.length);
          }
          final double sliderMin = 0;
          final double sliderMax =
              hasDistanceOptions ? (distanceValues.length - 1).toDouble() : 1;
          final double sliderValue =
              hasDistanceOptions ? selectedIndex.toDouble() : 0;
          final int sliderDivisions = hasDistanceOptions
              ? (distanceValues.length > 1 ? distanceValues.length - 1 : 1)
              : 1;

          return Container(
            color: backgroundColor,
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 12),
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
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.biddingRides,
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
                                  .biddingRidePageSubText,
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
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.04),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF161B2E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
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
                                      color: Colors.black.withOpacity(0.02),
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
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1E294B)
                                          : const Color(0xFFEFF6FF),
                                    ),
                                    child: Icon(
                                      Icons.gps_fixed,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
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
                                          text: AppLocalizations.of(context)!
                                              .distanceSelector,
                                          textStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .chooseMaxDistanceText,
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
                              const SizedBox(height: 16),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  inactiveTrackColor: isDark
                                      ? const Color(0xFF232A45)
                                      : const Color(0xFFE5E7EB),
                                  thumbColor: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  overlayColor: (isDark
                                          ? AppColors.secondary
                                          : AppColors.primary)
                                      .withOpacity(0.2),
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  min: sliderMin,
                                  max: sliderMax,
                                  divisions: sliderDivisions,
                                  value: sliderValue,
                                  onChanged: (v) {
                                    if (hasDistanceOptions) {
                                      final index = v
                                          .round()
                                          .clamp(0, distanceValues.length - 1);
                                      homeBloc.add(ChangeDistanceEvent(
                                          distance: distanceValues[index]));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                controller: _chipScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF232A45)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .km
                                            .toUpperCase(),
                                        textStyle: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(distanceOptions.length,
                                        (i) {
                                      final option = distanceOptions[i];
                                      final rawLabel =
                                          option['name'] ?? option['dist'] ?? 0;
                                      final double labelValue =
                                          _parseDistance(rawLabel);
                                      final labelText = (labelValue % 1 == 0)
                                          ? labelValue.toInt().toString()
                                          : labelValue.toStringAsFixed(1);
                                      final bool isSelected =
                                          i == selectedIndex;

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: InkWell(
                                          onTap: () {
                                            homeBloc.add(ChangeDistanceEvent(
                                                distance: distanceValues[i]));
                                            _scheduleChipScroll(
                                                i, distanceOptions.length);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isDark
                                                      ? const Color(0xFF1E3A8A)
                                                          .withOpacity(0.3)
                                                      : const Color(0xFFEFF6FF))
                                                  : (isDark
                                                      ? const Color(0xFF161B2E)
                                                      : Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: isSelected
                                                    ? (isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary)
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF232A45)
                                                        : const Color(
                                                            0xFFE5E7EB)),
                                                width: isSelected ? 1.5 : 1,
                                              ),
                                            ),
                                            child: MyText(
                                              text:
                                                  '$labelText ${AppLocalizations.of(context)!.km.toUpperCase()}',
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? (isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary)
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF9CA3AF)
                                                        : const Color(
                                                            0xFF1F2937)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                        Expanded(
                          child: (homeBloc.rideList.isNotEmpty)
                              ? ListView(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  children: homeBloc.rideList
                                      .asMap()
                                      .map((key, value) {
                                        final rideInstruction =
                                            _rideInstruction(value);
                                        final List preferenceIcons =
                                            homeBloc.rideList[key]
                                                    ['preferences_icon'] ??
                                                [];
                                        List stops = [];
                                        if (homeBloc.rideList[key]
                                                ['trip_stops'] !=
                                            'null') {
                                          stops = jsonDecode(homeBloc
                                              .rideList[key]['trip_stops']);
                                        }
                                        double dist = calculateDistance(
                                          lat1:
                                              homeBloc.currentLatLng!.latitude,
                                          lon1:
                                              homeBloc.currentLatLng!.longitude,
                                          lat2: homeBloc.rideList[key]
                                              ['pick_lat'],
                                          lon2: homeBloc.rideList[key]
                                              ['pick_lng'],
                                          unit: userData?.distanceUnit ?? 'km',
                                        );
                                        homeBloc.distanceValue = dist;
                                        const double distanceToleranceKm = 0.5;

                                        final double selectedKm =
                                            homeBloc.distanceBetween ?? 0;
                                        final bool isWithinRange = dist <=
                                            (selectedKm + distanceToleranceKm);

                                        if (!isWithinRange) {
                                          return MapEntry(
                                              key, const SizedBox.shrink());
                                        }

                                        final List<Map<String, dynamic>>
                                            timelineItems = [];
                                        timelineItems.add({
                                          'address': homeBloc.rideList[key]
                                                  ['pick_address'] ??
                                              '',
                                          'isPickup': true,
                                        });
                                        if (stops.isEmpty &&
                                            homeBloc.rideList[key]
                                                    ['drop_address'] !=
                                                '') {
                                          timelineItems.add({
                                            'address': homeBloc.rideList[key]
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
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              homeBloc.rideList[
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
                                                                    .rideList[key]
                                                                ['user_name'],
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
                                                                    '${homeBloc.rideList[key]['ratings']}',
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
                                                              if (homeBloc.rideList[
                                                                              key]
                                                                          [
                                                                          'completed_ride_count'] !=
                                                                      '0' &&
                                                                  homeBloc.rideList[
                                                                              key]
                                                                          [
                                                                          'completed_ride_count'] !=
                                                                      0) ...[
                                                                const SizedBox(
                                                                    width: 6),
                                                                MyText(
                                                                  text: "|",
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
                                                                      '${homeBloc.rideList[key]['completed_ride_count']} ${AppLocalizations.of(context)!.trips}',
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
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        MyText(
                                                          text:
                                                              '${homeBloc.rideList[key]['currency']} ${_formatPrice(homeBloc.rideList[key]['price'])}',
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
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
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
                                                                          VerticalDashedLinePainter(
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
                                                if (preferenceIcons
                                                        .isNotEmpty ||
                                                    rideInstruction.isNotEmpty)
                                                  const SizedBox(height: 12),
                                                if (preferenceIcons
                                                    .isNotEmpty) ...[
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
                                                            preferenceIconsRow(
                                                          context: context,
                                                          icons:
                                                              preferenceIcons,
                                                          size: size.width,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                ],
                                                if (rideInstruction
                                                    .isNotEmpty) ...[
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
                                                          text: rideInstruction,
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
                                                  const SizedBox(height: 8),
                                                ],
                                                const SizedBox(height: 16),
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
                                                                    .rideList[key]
                                                                ['request_id'],
                                                          ));
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
                                                                .textView,
                                                        textSize: 15,
                                                        textColor: Colors.white,
                                                        onTap: () {
                                                          homeBloc.add(ShowBidRideEvent(
                                                              id: homeBloc.rideList[key][
                                                                  'request_id'],
                                                              pickLat: homeBloc
                                                                      .rideList[key]
                                                                  ['pick_lat'],
                                                              pickLng: homeBloc
                                                                      .rideList[key]
                                                                  ['pick_lng'],
                                                              dropLat: homeBloc
                                                                  .rideList[key][
                                                                      'drop_lat']
                                                                  .toDouble(),
                                                              dropLng: homeBloc
                                                                  .rideList[key]
                                                                      ['drop_lng']
                                                                  .toDouble(),
                                                              stops: stops,
                                                              pickAddress: homeBloc.rideList[key]['pick_address'] ?? '',
                                                              dropAddress: homeBloc.rideList[key]['drop_address'] ?? '',
                                                              acceptedRideFare: homeBloc.rideList[key]['price'] ?? '0',
                                                              polyString: (homeBloc.rideList[key]['polyline'] ?? homeBloc.rideList[key]['poly_line'] ?? '').toString(),
                                                              distance: homeBloc.rideList[key]['distance'] ?? '0',
                                                              duration: homeBloc.rideList[key]['duration'] ?? '0',
                                                              isOutstationRide: false,
                                                              isNormalBidRide: true));
                                                          if (Navigator.of(
                                                                  context)
                                                              .canPop()) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          }
                                                        },
                                                        width: double.infinity,
                                                        height: 48,
                                                        borderRadius: 12,
                                                        leading: const Icon(
                                                          Icons
                                                              .visibility_rounded,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                            .biddingNotifyNewRideRequestAvailbleText,
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
                                          .biddingAdjustingDistanceSeeMoreRidesText,
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

  Widget preferenceIconsRow({
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

class VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashSpace;

  VerticalDashedLinePainter({
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
  bool shouldRepaint(covariant VerticalDashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashHeight != dashHeight ||
        oldDelegate.dashSpace != dashSpace;
  }
}
