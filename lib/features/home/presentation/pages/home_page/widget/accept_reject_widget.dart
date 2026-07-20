import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/functions.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_timer.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_slider/custom_sliderbutton.dart';

class AcceptRejectWidget extends StatelessWidget {
  final BuildContext cont;
  const AcceptRejectWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          double dist = 0.0;
          if (cont.read<HomeBloc>().currentLatLng != null &&
              userData!.metaRequest != null) {
            dist = calculateDistance(
              lat1: userData!.metaRequest!.pickLat,
              lon1: userData!.metaRequest!.pickLng,
              lat2: cont.read<HomeBloc>().currentLatLng!.latitude,
              lon2: cont.read<HomeBloc>().currentLatLng!.longitude,
              unit: userData?.distanceUnit ?? 'km',
            );
          }
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
                color: sheetBgColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24))),
            width: size.width,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card 1: Ride Type Info
                if (userData!.metaRequest!.isLater == true)
                  buildPremiumCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text:
                                  AppLocalizations.of(context)!.scheduledRideAt,
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text:
                                  userData!.metaRequest!.convertedTripStartTime,
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: userData!.metaRequest!.transportType !=
                                    'delivery'
                                ? AppLocalizations.of(context)!.regular
                                : AppLocalizations.of(context)!.delivery,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (userData!.metaRequest!.isRental)
                  buildPremiumCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: userData!.metaRequest!.rentalPackageName,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: userData!.metaRequest!.transportType !=
                                    'delivery'
                                ? AppLocalizations.of(context)!.rental
                                : AppLocalizations.of(context)!.deliveryRental,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  buildPremiumCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Image.asset(
                                  AppImages.carFront,
                                  width: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            MyText(
                              text: (userData!.metaRequest!.shareRide == true &&
                                      userData!.metaRequest!.transportType !=
                                          'delivery')
                                  ? AppLocalizations.of(context)!.shareRide
                                  : (userData!.metaRequest!.transportType !=
                                          'delivery')
                                      ? AppLocalizations.of(context)!
                                          .onDemandRide
                                      : AppLocalizations.of(context)!
                                          .deliveryRide,
                              textStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: MyText(
                            text: (userData!.metaRequest!.shareRide == true &&
                                    userData!.metaRequest!.transportType !=
                                        'delivery')
                                ? AppLocalizations.of(context)!.instantPool
                                : AppLocalizations.of(context)!.instantRide,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Card 2: User details & Fare Info
                buildPremiumCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(
                                    userData!.metaRequest!.userImage),
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
                                  text: userData!.metaRequest!.userName ?? '',
                                  textStyle: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                                  ),
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
                                      text: userData!.metaRequest!.userRatings
                                          .toString(),
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFF9CA3AF)
                                            : const Color(0xFF4B5563),
                                      ),
                                    ),
                                    if (userData!
                                            .metaRequest!.userCompletedRideCount
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
                                            '${userData!.metaRequest!.userCompletedRideCount.toString()} ${AppLocalizations.of(context)!.tripsDoneText}',
                                        textStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF4B5563),
                                        ),
                                      ),
                                    ],
                                    if (userData?.onTripRequest?.sharedRide ==
                                            true &&
                                        userData?.onTripRequest?.isRental !=
                                            true &&
                                        userData?.onTripRequest?.isBidRide !=
                                            '1') ...[
                                      const SizedBox(width: 6),
                                      MyText(
                                        text: '|',
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
                                            '${userData?.occupiedSeats} ${AppLocalizations.of(context)!.seatsTaken}',
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
                          if (userData!.metaRequest!.showRequestEtaAmount ==
                              true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!.rideFare,
                                  textStyle: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? const Color(0xFF9CA3AF)
                                        : const Color(0xFF6B7280),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MyText(
                                      text:
                                          '${userData!.metaRequest!.currencySymbol} ${userData!.metaRequest!.requestEtaAmount}',
                                      textStyle: const TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: isDark
                                          ? const Color(0xFF9CA3AF)
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ],
                                ),
                              ],
                            )
                        ],
                      ),
                      Divider(
                        color: isDark
                            ? const Color(0xFF232A45)
                            : const Color(0xFFE5E7EB),
                        height: 24,
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_sharp,
                                size: 18,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                text:
                                    '${dist.toStringAsFixed(2)} ${userData?.distanceUnit.toUpperCase() ?? 'KM'} ${AppLocalizations.of(context)!.away}',
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                userData!.metaRequest!.paymentOpt == '1'
                                    ? Icons.payments_outlined
                                    : userData!.metaRequest!.paymentOpt == '0'
                                        ? Icons.credit_card_rounded
                                        : Icons.account_balance_wallet_outlined,
                                size: 18,
                                color: const Color(0xFF10B981),
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                text: userData!.metaRequest!.paymentOpt == '1'
                                    ? AppLocalizations.of(context)!.cash
                                    : userData!.metaRequest!.paymentOpt == '2'
                                        ? AppLocalizations.of(context)!.wallet
                                        : AppLocalizations.of(context)!.card,
                                textStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFFD1D5DB)
                                      : const Color(0xFF374151),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),

                // Card 3: Timeline & Addresses
                // Card 3: Timeline & Addresses
                buildPremiumCard(
                  child: Builder(builder: (context) {
                    final List<Map<String, dynamic>> addressItems = [];

                    // Safely extract instruction strings[cite: 7]
                    String pickupInstruction = '';
                    String dropoffInstruction = '';
                    if (userData!.metaRequest!.pickPocInstruction != null &&
                        userData!.metaRequest!.pickPocInstruction
                            .toString()
                            .trim()
                            .isNotEmpty) {
                      pickupInstruction =
                          userData!.metaRequest!.pickPocInstruction.toString();
                    }
                    if (userData!.metaRequest!.dropPocInstruction != null &&
                        userData!.metaRequest!.dropPocInstruction
                            .toString()
                            .trim()
                            .isNotEmpty) {
                      dropoffInstruction =
                          userData!.metaRequest!.dropPocInstruction.toString();
                    }

                    // 1. Add Pickup
                    addressItems.add({
                      'title': 'Pickup',
                      'address': userData!.metaRequest!.pickAddress,
                      'isPickup': true,
                      'instruction':
                          pickupInstruction, // 👈 Attached instruction here
                      'color': isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF10B981),
                    });

                    // 2. Add Stops
                    if (userData!.metaRequest!.requestStops.isNotEmpty) {
                      for (var i = 0;
                          i < userData!.metaRequest!.requestStops.length;
                          i++) {
                        addressItems.add({
                          'title': 'Stop ${i + 1}',
                          'address': userData!.metaRequest!.requestStops[i]
                              ['address'],
                          'isPickup': false,
                          'instruction': '',
                          'color': isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        });
                      }
                    }

                    // 3. Add Drop
                    if (userData!.metaRequest!.requestStops.isEmpty &&
                        userData!.metaRequest!.dropAddress != null) {
                      addressItems.add({
                        'title': 'Drop',
                        'address': userData!.metaRequest!.dropAddress,
                        'isPickup': false,
                        'instruction':
                            dropoffInstruction, // 👈 Attached instruction here
                        'color': AppColors.red,
                      });
                    }

                    return Column(
                      children: List.generate(addressItems.length, (index) {
                        final item = addressItems[index];
                        final bool isLast = index == addressItems.length - 1;
                        final bool isPickup = item['isPickup'] ?? false;
                        final String instructionText =
                            item['instruction'] ?? '';

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
                                        color: item['color'],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    MyText(
                                      text: item['address'],
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? const Color(0xFFD1D5DB)
                                            : const Color(0xFF374151),
                                      ),
                                      maxLines: 3,
                                    ),

                                    // 🚀 NEW INLINE INSTRUCTIONS BLOCK:
                                    if (instructionText.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.2)
                                              : item['color'].withOpacity(0.06),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.notes_rounded,
                                              size: 14,
                                              color: item['color'],
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: MyText(
                                                maxLines: 5,
                                                overflow: TextOverflow.visible,
                                                text: instructionText,
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? const Color(0xFF9CA3AF)
                                                      : const Color(0xFF4B5563),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
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
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: 0.5,
                                      child: const Icon(
                                        Icons.near_me,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }),
                ),

                // Card 4: Goods info (if delivery)
                if (userData!.metaRequest!.transportType == 'delivery' &&
                    userData!.metaRequest!.goodsType.isNotEmpty &&
                    userData!.metaRequest!.goodsQuantity != null &&
                    userData!.metaRequest!.goodsQuantity!.isNotEmpty)
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
                                '${userData!.metaRequest!.goodsType} (${userData!.metaRequest!.goodsQuantity})',
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

                // Card 5: Preferences & instructions (Production-Ready Universal Method)
                // _buildPreferencesAndInstructionsCard(context, isDark),

                // Countdown Auto-cancel Warning Banner
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2D1F24)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF7F1D1D)
                          : const Color(0xFFFCA5A5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        size: 20,
                        color: AppColors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyText(
                          text: AppLocalizations.of(context)!
                              .rideWillCancelAutomatically
                              .toString()
                              .replaceAll(
                                  '1111', userData!.acceptDuration.toString()),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.red,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomPaint(
                        painter: CustomTimer(
                          width: 3.0,
                          color: AppColors.white,
                          backgroundColor: AppColors.red,
                          values: (context.read<HomeBloc>().timer) > 0
                              ? 1 -
                                  ((userData!.acceptDuration -
                                          context.read<HomeBloc>().timer) /
                                      userData!.acceptDuration)
                              : 1,
                        ),
                        child: Container(
                          height: 36,
                          width: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: MyText(
                              text: context.read<HomeBloc>().timer.toString(),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Slide & Reject Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: CustomSliderButton(
                        isLoader: context.read<HomeBloc>().isAcceptLoading,
                        buttonName: AppLocalizations.of(context)!.slideToAccept,
                        onSlideSuccess: () async {
                          context.read<HomeBloc>().add(
                                AcceptRejectEvent(
                                  requestId: userData!.metaRequest!.id,
                                  status: 1,
                                ),
                              );
                          return true;
                        },
                        height: 54.0,
                        textSize: 16,
                        width: size.width - 32 - 16 - 54,
                        textColor: Colors.white,
                        sliderIcon: const Icon(
                            Icons.keyboard_double_arrow_right_rounded,
                            size: 24),
                        handleColor: Colors.white,
                        handleBorder: Border.all(color: Colors.transparent),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        if (!context.read<HomeBloc>().isRejectLoading) {
                          context.read<HomeBloc>().add(
                                AcceptRejectEvent(
                                  requestId: userData!.metaRequest!.id,
                                  status: 0,
                                ),
                              );
                        }
                      },
                      borderRadius: BorderRadius.circular(27),
                      child: Container(
                        height: 54.0,
                        width: 54.0,
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E293B) : Colors.white,
                          shape: BoxShape.circle,
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
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: context.read<HomeBloc>().isRejectLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.red,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.close_rounded,
                                  color: AppColors.red,
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Final Production-Ready Universal Card Method for Taxi & Delivery
  Widget _buildPreferencesAndInstructionsCard(
      BuildContext context, bool isDark) {
    String pickupInstruction = '';
    String dropoffInstruction = '';

    // Extract Pickup Direction Notes safely from MetaData model[cite: 6]
    if (userData!.metaRequest!.pickPocInstruction != null &&
        userData!.metaRequest!.pickPocInstruction
            .toString()
            .trim()
            .isNotEmpty) {
      pickupInstruction = userData!.metaRequest!.pickPocInstruction.toString();
    }

    // Extract Dropoff Direction Notes safely from MetaData model[cite: 6]
    if (userData!.metaRequest!.dropPocInstruction != null &&
        userData!.metaRequest!.dropPocInstruction
            .toString()
            .trim()
            .isNotEmpty) {
      dropoffInstruction = userData!.metaRequest!.dropPocInstruction.toString();
    }

    final bool hasPreferences =
        userData!.metaRequest!.isPreferenceList != null &&
            userData!.metaRequest!.isPreferenceList.data.length >= 1;

    final bool hasInstructions =
        pickupInstruction.isNotEmpty || dropoffInstruction.isNotEmpty;

    // Safely hides the container if the specific customer has not inputted any custom notes or preferences
    if (!hasPreferences && !hasInstructions) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF232A45) : const Color(0xFFF3F4F6),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferences Section
          if (hasPreferences) ...[
            Row(
              children: [
                MyText(
                  text: '${AppLocalizations.of(context)!.preferences} : ',
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
                      userData!.metaRequest!.isPreferenceList.data.length,
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
                                  .metaRequest!.isPreferenceList.data[i].icon,
                              fit: BoxFit.contain,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                size: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          if (i !=
                              userData!.metaRequest!.isPreferenceList.data
                                      .length -
                                  1)
                            const Text(
                              ",",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasInstructions) const SizedBox(height: 12),
          ],

          // Pickup Instructions Section
          if (pickupInstruction.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                MyText(
                  text: 'Pickup Note : ',
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
              maxLines: 10,
              overflow: TextOverflow.visible,
              text: pickupInstruction,
              textStyle: TextStyle(
                fontSize: 13,
                color:
                    isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
              ),
            ),
            if (dropoffInstruction.isNotEmpty) const SizedBox(height: 12),
          ],

          // Dropoff Instructions Section
          if (dropoffInstruction.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: AppColors.red,
                ),
                const SizedBox(width: 6),
                MyText(
                  text: 'Dropoff Note : ',
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
              maxLines: 10,
              overflow: TextOverflow.visible,
              text: dropoffInstruction,
              textStyle: TextStyle(
                fontSize: 13,
                color:
                    isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
              ),
            ),
          ],
        ],
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
