import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_payment_stream.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/review_page/page/review_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../core/utils/custom_loader.dart';

class InvoicePage extends StatelessWidget {
  final BuildContext cont;
  final RideRepository repository;
  const InvoicePage({super.key, required this.cont, required this.repository});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define colors according to light/dark themes
    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);

    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final req = userData?.onTripRequest;
          if (req == null) {
            return Scaffold(
              backgroundColor: scaffoldBgColor,
              appBar: AppBar(
                backgroundColor: scaffoldBgColor,
                elevation: 0,
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: MyText(
                  text: AppLocalizations.of(context)!.tripSummary,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                leadingWidth: 56,
              ),
              body: Center(
                  child:
                      Text(AppLocalizations.of(context)!.invoiceNoDataSubText)),
            );
          }

          final bill = req.requestBill;
          final currencySymbol = bill?.currencySymbol ?? req.currencySymbol;
          final double totalAmount = (bill?.totalAmount ??
                  double.tryParse(req.acceptedRideFare.toString()) ??
                  0.0) +
              context.read<HomeBloc>().driverTips;

          final showFareBreakdown = req.isBidRide == '0' &&
              bill != null &&
              req.showOnlyTotalAmount != '1';

          return Scaffold(
            backgroundColor: scaffoldBgColor,
            appBar: AppBar(
              backgroundColor: scaffoldBgColor,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: MyText(
                text: AppLocalizations.of(context)!.tripSummary,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              leadingWidth: 56,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Card 1: User & Request Info (Header Card)
                      _buildPremiumCard(
                        context: context,
                        isDark: isDark,
                        child: Row(
                          children: [
                            // Circular Avatar
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF3F4F6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: (req.userImage.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 32,
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black45,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: req.userImage,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(child: Loader()),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.person,
                                          size: 32,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black45,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: req.userName.toUpperCase(),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Ratings & Trips Completed
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      MyText(
                                        text:
                                            '${req.ratings.toStringAsFixed(1)}  |  ${req.completedRideCount} trips',
                                        textStyle: TextStyle(
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Request ID Pill
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(
                                          text: req.requestNumber));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .invoiceRequestIdCopiedText),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyText(
                                            text: req.requestNumber,
                                            textStyle: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            Icons.copy_rounded,
                                            size: 12,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black45,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Phone Call Button
                            if (req.userMobile.isNotEmpty ||
                                req.contactNumberOthers.isNotEmpty) ...[
                              const SizedBox(width: 8),
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
                                    context.read<HomeBloc>().add(
                                        OpenAnotherFeatureEvent(
                                            value: (req.bookForOthers == false)
                                                ? 'tel:${req.userMobile}'
                                                : 'tel:${req.contactNumberOthers}'));
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Center(
                                    child: Icon(
                                      Icons.phone,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Card 2: Trip Details Card
                      _buildPremiumCard(
                        context: context,
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header
                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                  text:
                                      AppLocalizations.of(context)!.tripDetails,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Details
                            _buildDetailRow(
                                "Duration", '${req.totalTime} mins', isDark),
                            _buildDetailRow("Distance",
                                '${req.totalDistance} ${req.unit}', isDark),
                            _buildDetailRow("Type of Ride",
                                _getRideTypeString(context, req), isDark,
                                showDivider: false),

                            const SizedBox(height: 8),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF232A45)
                                  : const Color(0xFFF1F5F9),
                            ),
                            const SizedBox(height: 16),

                            // Address Timeline
                            ..._buildTimeline(context, req, isDark),
                          ],
                        ),
                      ),

                      // Conditional Card 3 or 4: Fare Breakdown or Cash/Wallet summary
                      if (showFareBreakdown)
                        _buildPremiumCard(
                          context: context,
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E1B4B)
                                          : const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: MyText(
                                        text: currencySymbol,
                                        textStyle: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .fareBreakup,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Items
                              if (bill.basePrice != 0)
                                _buildFareRow(
                                  '${AppLocalizations.of(context)!.basePrice} (${bill.baseDistance} ${bill.unit})',
                                  '$currencySymbol ${bill.basePrice.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.distancePrice != 0)
                                _buildFareRow(
                                  '${AppLocalizations.of(context)!.distancePrice} ($currencySymbol ${bill.pricePerDistance.toStringAsFixed(2)} x ${bill.calculatedDistance} ${bill.unit})',
                                  '$currencySymbol ${bill.distancePrice.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.timePrice != 0)
                                _buildFareRow(
                                  '${AppLocalizations.of(context)!.timePrice} ($currencySymbol ${bill.pricePerTime.toStringAsFixed(2)} x ${bill.totalTime})',
                                  '$currencySymbol ${bill.timePrice.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.waitingCharge != 0)
                                _buildFareRow(
                                  '${AppLocalizations.of(context)!.waitingPrice} ($currencySymbol ${bill.waitingChargePerMin.toStringAsFixed(2)} x ${bill.calculatedWaitingTime} mins)',
                                  '$currencySymbol ${bill.waitingCharge.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.adminCommission != 0)
                                _buildFareRow(
                                  AppLocalizations.of(context)!.convFee,
                                  '$currencySymbol ${bill.adminCommission.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.promoDiscount != 0.0)
                                _buildFareRow(
                                  AppLocalizations.of(context)!.discount,
                                  '- $currencySymbol ${bill.promoDiscount.toStringAsFixed(2)}',
                                  isDark,
                                  textColor: const Color(0xFFEF4444),
                                ),
                              if (bill.additionalChargesAmount != 0 &&
                                  bill.additionalChargesReason != null)
                                _buildFareRow(
                                  bill.additionalChargesReason!,
                                  '$currencySymbol ${bill.additionalChargesAmount.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.airportSurgeFee != 0 &&
                                  req.transportType == 'taxi' &&
                                  req.isBidRide == '0')
                                _buildFareRow(
                                  AppLocalizations.of(context)!.airportSurgeFee,
                                  '$currencySymbol ${bill.airportSurgeFee.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.serviceTax != 0)
                                _buildFareRow(
                                  AppLocalizations.of(context)!.taxes,
                                  '$currencySymbol ${bill.serviceTax.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (bill.preferencePriceTotal != 0)
                                _buildFareRow(
                                  AppLocalizations.of(context)!.preferenceTotal,
                                  '$currencySymbol ${bill.preferencePriceTotal.toStringAsFixed(2)}',
                                  isDark,
                                ),
                              if (context.read<HomeBloc>().driverTips != 0.0)
                                _buildFareRow(
                                  AppLocalizations.of(context)!.tips,
                                  '$currencySymbol ${context.read<HomeBloc>().driverTips.toStringAsFixed(2)}',
                                  isDark,
                                ),

                              const SizedBox(height: 12),

                              // Total Fare Highlight Block
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .totalFare,
                                      textStyle: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    MyText(
                                      text:
                                          '$currencySymbol ${totalAmount.toStringAsFixed(2)}',
                                      textStyle: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _buildPremiumCard(
                          context: context,
                          isDark: isDark,
                          bgColor: isDark
                              ? const Color(0xFF0F1A15)
                              : const Color(0xFFF0FDF4),
                          borderColor: isDark
                              ? const Color(0xFF065F46)
                              : const Color(0xFFDCFCE7),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 48,
                                    width: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981),
                                    ),
                                    child: const Icon(
                                      Icons.payments_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    text: _getPaymentMethodString(context, req),
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white70
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  MyText(
                                    text:
                                        '$currencySymbol ${totalAmount.toStringAsFixed(2)}',
                                    textStyle: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StreamBuilder<RidePaymentStatus>(
                        stream: repository.paymentStatusStream,
                        builder: (context, snapshot) {
                          final status = snapshot.hasData
                              ? snapshot.data!
                              : RidePaymentStatus(
                                  isPaid: false, changedPayment: '');
                          final isPaymentChanged =
                              status.changedPayment.trim().isNotEmpty;
                          final paymentType = isPaymentChanged
                              ? status.changedPayment.toLowerCase().trim()
                              : req.paymentOpt == '1'
                                  ? 'cash'
                                  : req.paymentOpt == '2'
                                      ? 'wallet'
                                      : 'online';

                          final isPaidZero = req.isPaid == 0;
                          final isOnlineOrCard =
                              paymentType == 'online' || paymentType == 'card';

                          final String buttonName = isPaidZero
                              ? (paymentType == 'cash'
                                  ? AppLocalizations.of(context)!
                                      .paymentRecieved
                                  : (isOnlineOrCard && !status.isPaid
                                      ? AppLocalizations.of(context)!
                                          .waitingForPayment
                                      : AppLocalizations.of(context)!.confirm))
                              : AppLocalizations.of(context)!.confirm;

                          final bool isLoader = isOnlineOrCard && isPaidZero
                              ? !status.isPaid
                              : false;

                          return Expanded(
                            child: CustomButton(
                              width: size.width,
                              height: 52,
                              borderRadius: 30,
                              // buttonColor: const Color(0xFF0038FF),
                              leading: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                              buttonName: buttonName,
                              isLoader: isLoader,
                              isLoaderShowWithText: isLoader,
                              textSize: 16,
                              onTap: (isOnlineOrCard &&
                                      isPaidZero &&
                                      !status.isPaid)
                                  ? () {}
                                  : () {
                                      if (isPaidZero) {
                                        context
                                            .read<HomeBloc>()
                                            .add(PaymentRecievedEvent());
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            ReviewPage.routeName,
                                            (route) => false);
                                        context
                                            .read<HomeBloc>()
                                            .add(AddReviewEvent());
                                      }
                                    },
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumCard({
    required BuildContext context,
    required Widget child,
    required bool isDark,
    Color? bgColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? const Color(0xFF161B2E) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ??
              (isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9)),
          width: 1.0,
        ),
        boxShadow: (isDark || bgColor != null)
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: label,
                textStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF4B5563),
                ),
              ),
              MyText(
                text: value,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }

  String _getRideTypeString(BuildContext context, OnTripData req) {
    if (req.isOutstation == 0 &&
        req.isRental == false &&
        req.goodsType == '-') {
      return AppLocalizations.of(context)!.regular;
    } else if (req.isOutstation == 0 &&
        req.isRental == false &&
        req.goodsType != '-') {
      return AppLocalizations.of(context)!.delivery;
    } else if (req.isOutstation == 0 &&
        req.isRental == true &&
        req.goodsType == '-') {
      return AppLocalizations.of(context)!.rental;
    } else if (req.isOutstation == 0 &&
        req.isRental == true &&
        req.goodsType != '-') {
      return AppLocalizations.of(context)!.deliveryRental;
    } else if (req.isOutstation == 1 &&
        req.isRental == false &&
        req.goodsType == '-') {
      return AppLocalizations.of(context)!.outStation;
    } else if (req.isOutstation == 1 &&
        req.isRental == false &&
        req.goodsType != '-') {
      return AppLocalizations.of(context)!.deliveryOutStation;
    }
    return '';
  }

  List<Widget> _buildTimeline(
      BuildContext context, OnTripData req, bool isDark) {
    final List<Map<String, dynamic>> addressItems = [];
    addressItems.add({
      'isPickup': true,
      'title': 'Pickup',
      'address': req.pickAddress,
      'color': const Color(0xFF10B981),
    });

    if (req.requestStops.isNotEmpty) {
      for (var stop in req.requestStops) {
        addressItems.add({
          'isPickup': false,
          'title': 'Stop',
          'address': stop['address'] ?? '',
          'color': const Color(0xFFEF4444),
        });
      }
    }

    addressItems.add({
      'isPickup': false,
      'title': 'Drop',
      'address': context.read<HomeBloc>().dropAddress.isNotEmpty
          ? context.read<HomeBloc>().dropAddress
          : (req.dropAddress ?? ''),
      'color': const Color(0xFFEF4444),
    });

    return List.generate(addressItems.length, (index) {
      final item = addressItems[index];
      final isLast = index == addressItems.length - 1;

      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  const SizedBox(height: 4),
                  if (item['isPickup'])
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
                      color: item['isPickup']
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    text: item['address'],
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 13,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF374151),
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFareRow(String label, String value, bool isDark,
      {Color? textColor, bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyText(
                  text: label,
                  textAlign: TextAlign.start,
                  textStyle: TextStyle(
                    fontSize: 14,
                    color: textColor ??
                        (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MyText(
                text: value,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor ??
                      (isDark ? Colors.white : const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9),
          ),
      ],
    );
  }

  String _getPaymentMethodString(BuildContext context, OnTripData req) {
    final paymentChanged = context.read<HomeBloc>().paymentChanged;
    if (paymentChanged.isEmpty) {
      return req.paymentType;
    }
    return paymentChanged
        .replaceAll('online', AppLocalizations.of(context)!.card)
        .replaceAll('cash', AppLocalizations.of(context)!.cash);
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
