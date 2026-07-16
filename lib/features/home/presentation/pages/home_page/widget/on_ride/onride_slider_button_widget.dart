import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/common.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_loader.dart';
import '../../../../../../../core/utils/custom_slider/custom_sliderbutton.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class OnrideCustomSliderButtonWidget extends StatelessWidget {
  final Size size;

  const OnrideCustomSliderButtonWidget({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          color: sheetBgColor,
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            child: Column(
              children: [
                if (userData!.onTripRequest!.isPaid == 0 &&
                    userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.paidAt == 'Sender' &&
                    userData!.onTripRequest!.paymentType != 'cash' &&
                    userData!.onTripRequest!.paymentType != 'wallet' &&
                    (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt!.isNotEmpty))
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.waitingForPayment,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).primaryColorDark,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 5),
                        SizedBox(
                          height: size.width * 0.05,
                          width: size.width * 0.05,
                          child: Loader(
                            color: Theme.of(context).primaryColorDark,
                          ),
                        )
                      ],
                    ),
                  ),
                if (userData!.onTripRequest!.isPaid == 0 &&
                    !userData!.onTripRequest!.isRental &&
                    userData!.onTripRequest!.transportType == 'delivery' &&
                    userData!.onTripRequest!.paidAt == 'Sender' &&
                    userData!.onTripRequest!.paymentType == 'cash' &&
                    (userData!.onTripRequest!.arrivedAt != null &&
                        userData!.onTripRequest!.arrivedAt!.isNotEmpty))
                  CustomButton(
                    buttonName: AppLocalizations.of(context)!.paymentRecieved,
                    textSize: 18,
                    onTap: () {
                      if (userData!.onTripRequest!.paymentOpt == '1' &&
                          userData!.onTripRequest!.isPaid == 0) {
                        context.read<HomeBloc>().add(PaymentRecievedEvent());
                      }
                    },
                  ),
                if ((((((userData!.onTripRequest!.isPaid == 1 ||
                                        userData!.onTripRequest!.paymentType ==
                                            'wallet') &&
                                    userData!.onTripRequest!.paidAt ==
                                        'Sender') ||
                                userData!.onTripRequest!.paidAt ==
                                    'Receiver') &&
                            userData!.onTripRequest!.transportType ==
                                'delivery') ||
                        (userData!.onTripRequest!.isRental &&
                            userData!.onTripRequest!.transportType ==
                                'delivery')) ||
                    userData!.onTripRequest!.arrivedAt == null ||
                    userData!.onTripRequest!.transportType == 'taxi')
                  CustomSliderButton(
                    isLoader: context.read<HomeBloc>().isLoading,
                    sliderIcon: const Icon(
                      Icons.keyboard_double_arrow_right_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    buttonName: (userData!.onTripRequest!.arrivedAt == null)
                        ? AppLocalizations.of(context)!.arrived
                        : (userData!.onTripRequest!.isTripStart == 0)
                            ? (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.startRide
                                : AppLocalizations.of(context)!.pickGoods
                            : (userData!.onTripRequest!.transportType == 'taxi')
                                ? AppLocalizations.of(context)!.endRide
                                : AppLocalizations.of(context)!.dispatchGoods,
                    height: 54.0,
                    textSize: 16,
                    width: size.width - 32,
                    buttonColor:
                        isDark ? AppColors.buttonColor : AppColors.buttonColor,
                    textColor: Colors.white,
                    handleColor: Colors.white,
                    handleIconColor: AppColors.buttonColor,
                    handleBorder: Border.all(color: Colors.transparent),
                    onSlideSuccess: () async {
                      if (userData != null && userData!.onTripRequest != null) {
                        final trip = userData!.onTripRequest!;
                        if (trip.requestStops.isNotEmpty &&
                            trip.isTripStart == 1 &&
                            trip.requestStops
                                    .where((e) => e['completed_at'] == null)
                                    .length >
                                1) {
                          context.read<HomeBloc>().add(ShowChooseStopEvent());
                        } else if (trip.arrivedAt == null) {
                          context
                              .read<HomeBloc>()
                              .add(RideArrivedEvent(requestId: trip.id));
                        } else if (trip.transportType == 'taxi') {
                          printWrapped('Transport type is taxi ');
                          if (trip.isTripStart == 0) {
                            printWrapped(' isTripStart is 0 ');
                            if (trip.showOtpFeature == true) {
                              printWrapped(' showOtpFeature is true ');
                              context.read<HomeBloc>().add(ShowOtpEvent());
                            } else {
                              printWrapped(' showOtpFeature is false ');
                              context.read<HomeBloc>().add(RideStartEvent(
                                  requestId: trip.id,
                                  otp: '',
                                  pickLat: trip.pickLat,
                                  pickLng: trip.pickLng));
                            }
                          } else {
                            _showEndRideDialog(context, size);
                          }
                        } else if (trip.transportType == 'delivery') {
                          printWrapped(' transportType is delivery ');
                          if (trip.isTripStart == 0) {
                            printWrapped(' delivery isTripStart is 0 ');
                            if (trip.showOtpFeature == true) {
                              printWrapped(' delivery showOtpFeature is true ');
                              context.read<HomeBloc>().add(ShowOtpEvent());
                            } else if (trip.enableShipmentLoad == '1') {
                              printWrapped(
                                  ' delivery enableShipmentLoad is 1 ');
                              context
                                  .read<HomeBloc>()
                                  .add(ShowImagePickEvent());
                            } else {
                              printWrapped(
                                  ' delivery enableShipmentLoad is 0 ');
                              context.read<HomeBloc>().add(RideStartEvent(
                                  requestId: trip.id,
                                  otp: '',
                                  pickLat: trip.pickLat,
                                  pickLng: trip.pickLng));
                            }
                          } else {
                            printWrapped(' delivery isTripStart is 1 ');
                            if (trip.showOtpFeature == true) {
                              printWrapped(' delivery showOtpFeature is true ');
                              context.read<HomeBloc>().add(ShowOtpEvent());
                            } else if (trip.enableShipmentUnload == '1') {
                              printWrapped(
                                  ' delivery enableShipmentUnload is 1 ');
                              context
                                  .read<HomeBloc>()
                                  .add(ShowImagePickEvent());
                            } else if (trip.enableDigitalSignature == '1') {
                              printWrapped(
                                  ' delivery enableDigitalSignature is 1 ');
                              context
                                  .read<HomeBloc>()
                                  .add(ShowSignatureEvent());
                            } else {
                              printWrapped(
                                  ' delivery enableDigitalSignature is 0 ');
                              _showEndRideDialog(context, size);
                            }
                          }
                        }
                        return true;
                      }
                      return null;
                    },
                  ),
                if (userData!.onTripRequest!.isTripStart == 0 &&
                    userData!.onTripRequest!.isPaid == 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: size.width - 32,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.red,
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        context.read<HomeBloc>().add(GetCancelReasonEvent());
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Center(
                        child: MyText(
                          text: AppLocalizations.of(context)!.cancelRide,
                          textStyle: const TextStyle(
                            color: AppColors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEndRideDialog(BuildContext context, Size size) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (builder) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final dialogBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
          final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
          final descColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Dialog(
            backgroundColor: dialogBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Alarm Warning Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF2C1B20)
                          : const Color(0xFFFEF2F2),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  MyText(
                    text: AppLocalizations.of(context)!.endRide,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Description Confirmation Text
                  MyText(
                    text: AppLocalizations.of(context)!.rideEndConfirmationText,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: descColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),

                  // Actions Row
                  Row(
                    children: [
                      // "No" Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            printWrapped('text 00000000000 --------- ');
                            Navigator.pop(context);
                            context.read<HomeBloc>().add(UpdateEvent());
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: MyText(
                                text: AppLocalizations.of(context)!.no,
                                textStyle: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // "End Ride" Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            printWrapped('text 1111111111111 --------- ');
                            Navigator.pop(context);
                            if (userData!.onTripRequest!.isRental == false &&
                                userData!.onTripRequest!.isOutstation != 1 &&
                                userData!.onTripRequest!.dropAddress != null) {
                              printWrapped('text 222222222222 --------- ');
                              context.read<HomeBloc>().add(RideEndEvent(
                                  isAfterGeoCodeEnd: false,
                                  isAfterRoutesDistanceCall: false));
                            } else {
                              printWrapped('text 333333333333 --------- ');
                              context.read<HomeBloc>().add(GeocodingLatLngEvent(
                                  lat: context
                                      .read<HomeBloc>()
                                      .currentLatLng!
                                      .latitude,
                                  lng: context
                                      .read<HomeBloc>()
                                      .currentLatLng!
                                      .longitude));
                            }
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: AppColors.buttonColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.buttonColor.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: MyText(
                                text: AppLocalizations.of(context)!.endRide,
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
