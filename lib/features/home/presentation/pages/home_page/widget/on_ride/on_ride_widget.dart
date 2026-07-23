// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class OnRideWidget extends StatelessWidget {
  final BuildContext cont;

  const OnRideWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = cont.read<HomeBloc>();

    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final sheetBgColor =
              isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);

          // Card wrapper helper to maintain uniform styling
          Widget buildPremiumCard({required Widget child}) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B2E) : Colors.white,
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
                          color: Colors.black.withOpacity(0.01),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: child,
            );
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: sheetBgColor,
            ),
            width: size.width,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card 1: Banner / Waiting Time Card
                buildPremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.people_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyText(
                              text: (userData?.onTripRequest!.arrivedAt == null)
                                  ? AppLocalizations.of(context)!.onWayToPickup
                                  : (userData?.onTripRequest!.isTripStart == 0)
                                      ? AppLocalizations.of(context)!
                                          .arrivedWaiting
                                      : AppLocalizations.of(context)!
                                          .onTheWayToDrop,
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (userData!.onTripRequest!.arrivedAt != null &&
                          userData!.onTripRequest!.isBidRide == "0" &&
                          !userData!.onTripRequest!.isRental) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    color: isDark
                                        ? AppColors.secondary
                                        : AppColors.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .onrideWaitingTimeText,
                                    textStyle: TextStyle(
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // MyText(
                              //   text:
                              //       '${(Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours.toString().padLeft(2, '0'))} : ${((Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inMinutes - (Duration(seconds: (context.read<HomeBloc>().waitingTimeBeforeStart + context.read<HomeBloc>().waitingTimeAfterStart)).inHours * 60)).toString().padLeft(2, '0'))} min',
                              //   textStyle: TextStyle(
                              //     color: isDark
                              //         ? AppColors.secondary
                              //         : AppColors.primary,
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 24,
                              //   ),
                              // ),

                              LiveWaitingTimeText(
                                initialSeconds: context
                                        .read<HomeBloc>()
                                        .waitingTimeBeforeStart +
                                    context
                                        .read<HomeBloc>()
                                        .waitingTimeAfterStart,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2D1F24)
                                : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF7F1D1D)
                                  : const Color(0xFFFDE68A),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 18,
                                color: isDark
                                    ? const Color(0xFFFCA5A5)
                                    : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: MyText(
                                  text: (userData!.onTripRequest!
                                                  .freeWaitingTimeBeforeStart ==
                                              0 ||
                                          userData!.onTripRequest!
                                                  .freeWaitingTimeAfterStart ==
                                              0)
                                      ? AppLocalizations.of(context)!
                                          .waitingChargeText
                                          .replaceAll('*',
                                              "${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.waitingCharge}")
                                      : AppLocalizations.of(context)!
                                          .waitingText
                                          .replaceAll("***",
                                              "${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.waitingCharge}")
                                          .replaceAll(
                                              "*",
                                              userData?.onTripRequest!
                                                          .isTripStart ==
                                                      0
                                                  ? "${userData!.onTripRequest!.freeWaitingTimeBeforeStart}"
                                                  : "${userData!.onTripRequest!.freeWaitingTimeAfterStart}"),
                                  maxLines: 5,
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? const Color(0xFFFCA5A5)
                                        : const Color(0xFF92400E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),

                // Card 2: Pickup/Drop Address Timeline
                buildPremiumCard(
                  child: Builder(builder: (context) {
                    final List<Map<String, dynamic>> addressItems = [];
                    addressItems.add({
                      'title': 'Pickup',
                      'address': userData!.onTripRequest!.pickAddress,
                      'isPickup': true,
                      'color': isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF10B981),
                      'phone': userData!.onTripRequest!.pickPocMobile,
                      'lat': userData!.onTripRequest!.pickLat,
                      'lng': userData!.onTripRequest!.pickLng,
                    });

                    if (userData!.onTripRequest!.requestStops.isNotEmpty) {
                      for (var i = 0;
                          i < userData!.onTripRequest!.requestStops.length;
                          i++) {
                        final stop = userData!.onTripRequest!.requestStops[i];
                        addressItems.add({
                          'title': 'Stop ${i + 1}',
                          'address': stop['address'],
                          'isPickup': false,
                          'color': isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                          'completed': stop['completed_at'] != null,
                          'phone': stop['poc_mobile'],
                          'lat': stop['latitude'],
                          'lng': stop['longitude'],
                        });
                      }
                    }

                    if (userData!.onTripRequest!.requestStops.isEmpty &&
                        userData!.onTripRequest!.dropAddress != null) {
                      addressItems.add({
                        'title': 'Drop',
                        'address': userData!.onTripRequest!.dropAddress,
                        'isPickup': false,
                        'color': AppColors.red,
                        'phone': userData!.onTripRequest!.dropPocMobile,
                        'lat': userData!.onTripRequest!.dropLat,
                        'lng': userData!.onTripRequest!.dropLng,
                      });
                    }

                    return Column(
                      children: List.generate(addressItems.length, (index) {
                        final item = addressItems[index];
                        final bool isLast = index == addressItems.length - 1;
                        final bool isPickup = item['isPickup'] ?? false;
                        final bool isCompleted = item['completed'] ?? false;

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 24,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    if (isPickup)
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: item['color'],
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: item['color'],
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Image.asset(
                                        AppImages.mapPinNew,
                                        width: 14,
                                        height: 14,
                                        color: isCompleted
                                            ? AppColors.secondary
                                            : AppColors.red,
                                      ),
                                    if (!isLast)
                                      Expanded(
                                        child: CustomPaint(
                                          painter: VerticalDashedLinePainter(
                                            color: isDark
                                                ? const Color(0xFF374151)
                                                : const Color(0xFFD1D5DB),
                                            strokeWidth: 1.5,
                                            dashHeight: 4,
                                            dashSpace: 3,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: item['title'],
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isCompleted
                                            ? AppColors.darkGrey
                                            : item['color'],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    MyText(
                                      text: item['address'],
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isCompleted
                                            ? AppColors.darkGrey
                                            : (isDark
                                                ? const Color(0xFFD1D5DB)
                                                : const Color(0xFF374151)),
                                      ),
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Call and navigation action row on the right
                              Row(
                                children: [
                                  if (item['phone'] != null &&
                                      item['phone'].toString().isNotEmpty) ...[
                                    Center(
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFEFF6FF),
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            context.read<HomeBloc>().add(
                                                OpenAnotherFeatureEvent(
                                                    value:
                                                        'tel:${item['phone']}'));
                                          },
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: const Center(
                                            child: Icon(
                                              Icons.phone_enabled_outlined,
                                              size: 16,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Center(
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFEFF6FF),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(20)),
                                            ),
                                            builder: (_) => BlocProvider.value(
                                              value: homeBloc,
                                              child: SizedBox(
                                                width: size.width,
                                                height: size.width,
                                                child: Column(
                                                  children: [
                                                    const SizedBox(height: 20),
                                                    MyText(
                                                      text: AppLocalizations.of(
                                                              context)!
                                                          .chooseMap,
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
                                                    const Divider(),
                                                    InkWell(
                                                      onTap: () async {
                                                        final current = context
                                                            .read<HomeBloc>()
                                                            .currentLatLng;
                                                        if (current != null) {
                                                          final Uri
                                                              googleMapsUri =
                                                              Uri.parse(
                                                                  'https://www.google.com/maps/dir/?api=1'
                                                                  '&origin=${current.latitude},${current.longitude}'
                                                                  '&destination=${item['lat']},${item['lng']}');
                                                          if (await canLaunchUrl(
                                                              googleMapsUri)) {
                                                            await launchUrl(
                                                                googleMapsUri,
                                                                mode: LaunchMode
                                                                    .externalApplication);
                                                          }
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 12),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                AppImages
                                                                    .googleMaps,
                                                                height: 28,
                                                                width: 28),
                                                            const SizedBox(
                                                                width: 12),
                                                            MyText(
                                                              text: AppLocalizations
                                                                      .of(context)!
                                                                  .googleMap,
                                                              textStyle: TextStyle(
                                                                  color: isDark
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFF1F2937)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () async {
                                                        final Uri wazeUri =
                                                            Uri.parse(
                                                                'https://waze.com/ul?ll=${item['lat']},${item['lng']}&navigate=yes');
                                                        if (await canLaunchUrl(
                                                            wazeUri)) {
                                                          await launchUrl(
                                                              wazeUri);
                                                        }
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 12),
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                                AppImages
                                                                    .wazeMap,
                                                                height: 28,
                                                                width: 28),
                                                            const SizedBox(
                                                                width: 12),
                                                            MyText(
                                                              text: AppLocalizations
                                                                      .of(context)!
                                                                  .wazeMap,
                                                              textStyle: TextStyle(
                                                                  color: isDark
                                                                      ? Colors
                                                                          .white
                                                                      : const Color(
                                                                          0xFF1F2937)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: const Center(
                                          child: Icon(
                                            Icons.near_me_outlined,
                                            size: 16,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }),
                ),

                // Card 3: User Details Row
                buildPremiumCard(
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                userData!.onTripRequest!.userImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: userData!.onTripRequest!.userName,
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                MyText(
                                  text: userData!.onTripRequest!.ratings
                                      .toString(),
                                  textStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF4B5563),
                                  ),
                                ),
                                if (userData!.onTripRequest!.completedRideCount
                                        .toString() !=
                                    '0') ...[
                                  const SizedBox(width: 6),
                                  MyText(
                                    text: "|",
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  MyText(
                                    text:
                                        '${userData!.onTripRequest!.completedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (userData != null &&
                          userData!.onTripRequest != null &&
                          ((userData!.onTripRequest!.isTripStart == 0 &&
                                  userData!.onTripRequest!.transportType ==
                                      'taxi') ||
                              ((userData!.onTripRequest!.transportType !=
                                  'taxi'))))
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Chat Button
                            Stack(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEFF6FF),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      context
                                          .read<HomeBloc>()
                                          .add(GetRideChatEvent());
                                      context
                                          .read<HomeBloc>()
                                          .add(ShowChatEvent());
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: const Center(
                                      child: Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                if (context.read<HomeBloc>().chats.isNotEmpty &&
                                    context
                                        .read<HomeBloc>()
                                        .chats
                                        .where((e) =>
                                            e['from_type'] == 1 &&
                                            e['seen'] == 0)
                                        .isNotEmpty)
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Container(
                                      height: 8,
                                      width: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            // Call Button
                            Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF6FF),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  context.read<HomeBloc>().add(OpenAnotherFeatureEvent(
                                      value: (userData!.onTripRequest!
                                                  .bookForOthers ==
                                              false)
                                          ? 'tel:${userData!.onTripRequest!.userMobile}'
                                          : 'tel:${userData!.onTripRequest!.contactNumberOthers}'));
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: const Center(
                                  child: Icon(
                                    Icons.phone_enabled_outlined,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Preferences & Instructions
                if ((userData!.onTripRequest!.transportType == 'taxi' &&
                        userData!.onTripRequest!.pickPocInstruction != null &&
                        userData!.onTripRequest!.pickPocInstruction != '') ||
                    (userData!.onTripRequest!.requestPreferences != null &&
                        userData!.onTripRequest!.requestPreferences.data
                                .length >=
                            1))
                  buildPremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userData!.onTripRequest!.requestPreferences !=
                                null &&
                            userData!.onTripRequest!.requestPreferences.data
                                    .length >=
                                1) ...[
                          Row(
                            children: [
                              MyText(
                                text:
                                    '${AppLocalizations.of(context)!.preferences} : ',
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: List.generate(
                                    userData!.onTripRequest!.requestPreferences
                                        .data.length,
                                    (i) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2, vertical: 1),
                                          width: 22,
                                          height: 22,
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? const Color(0xFF232A45)
                                                : const Color(0xFFF3F4F6),
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: userData!
                                                .onTripRequest!
                                                .requestPreferences
                                                .data[i]
                                                .icon,
                                            fit: BoxFit.contain,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                              Icons.error,
                                              size: 12,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        if (i !=
                                            userData!
                                                    .onTripRequest!
                                                    .requestPreferences
                                                    .data
                                                    .length -
                                                1)
                                          const Text(
                                            ",",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (userData!.onTripRequest!.transportType ==
                                  'taxi' &&
                              userData!.onTripRequest!.pickPocInstruction !=
                                  null &&
                              userData!.onTripRequest!.pickPocInstruction != '')
                            const SizedBox(height: 12),
                        ],
                        if (userData!.onTripRequest!.transportType == 'taxi' &&
                            userData!.onTripRequest!.pickPocInstruction !=
                                null &&
                            userData!.onTripRequest!.pickPocInstruction !=
                                '') ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                text:
                                    '${AppLocalizations.of(context)!.instruction} : ',
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            maxLines: 3,
                            text: userData!.onTripRequest!.pickPocInstruction
                                ?.toString(),
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Card 4: Goods Info (if delivery)
                if (userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.goodsType.isNotEmpty &&
                    userData!.onTripRequest!.goodsQuantity != null &&
                    userData!.onTripRequest!.goodsQuantity!.isNotEmpty)
                  buildPremiumCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color:
                              isDark ? AppColors.secondary : AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyText(
                            text:
                                '${userData!.onTripRequest!.goodsType} (${userData!.onTripRequest!.goodsQuantity})',
                            textStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFD1D5DB)
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Card 5: Fare & Payments info
                buildPremiumCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: userData!.onTripRequest!.isRental
                                ? userData!.onTripRequest!.rentalPackageName
                                : AppLocalizations.of(context)!.rideFare,
                            textStyle: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            text: (userData!.onTripRequest!.isBidRide == "1")
                                ? '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.acceptedRideFare}'
                                : '${userData!.onTripRequest!.currencySymbol} ${userData!.onTripRequest!.requestEtaAmount}',
                            textStyle: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(
                                userData!.onTripRequest!.paymentOpt == '1'
                                    ? Icons.payments_outlined
                                    : userData!.onTripRequest!.paymentOpt == '0'
                                        ? Icons.credit_card_rounded
                                        : Icons.account_balance_wallet_outlined,
                                size: 18,
                                color: const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                text: userData!.onTripRequest!.paymentOpt == '1'
                                    ? AppLocalizations.of(context)!.cash
                                    : userData!.onTripRequest!.paymentOpt == '2'
                                        ? AppLocalizations.of(context)!.wallet
                                        : AppLocalizations.of(context)!.card,
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                          if (userData!.onTripRequest!.transportType ==
                              'delivery') ...[
                            const SizedBox(height: 4),
                            MyText(
                              text: userData!.onTripRequest!.paidAt == 'Sender'
                                  ? AppLocalizations.of(context)!.payBysender
                                  : AppLocalizations.of(context)!.payByreceiver,
                              textStyle: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Additional Charges (if applicable)
                if (userData!.onTripRequest != null &&
                    userData!.onTripRequest!.isTripStart == 1 &&
                    userData!.onTripRequest!.showAdditionalChargeFeature ==
                        1) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      context.read<HomeBloc>().add(AdditionalChargeEvent());
                    },
                    child: Center(
                      child: MyText(
                        text:
                            "${AppLocalizations.of(context)!.additionalCharges} ?",
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
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

class LiveWaitingTimeText extends StatefulWidget {
  final int initialSeconds;
  final bool isDark;

  const LiveWaitingTimeText({
    super.key,
    required this.initialSeconds,
    required this.isDark,
  });

  @override
  State<LiveWaitingTimeText> createState() => _LiveWaitingTimeTextState();
}

class _LiveWaitingTimeTextState extends State<LiveWaitingTimeText> {
  Timer? _ticker;
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.initialSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LiveWaitingTimeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds) {
      _currentSeconds = widget.initialSeconds;
    }
  }

  void _startTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: _currentSeconds);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return MyText(
      text: '$minutes min : $seconds sec',
      textStyle: TextStyle(
        color: widget.isDark ? AppColors.secondary : AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    );
  }
}
