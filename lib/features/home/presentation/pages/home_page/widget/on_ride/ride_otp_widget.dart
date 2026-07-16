import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../../../common/app_colors.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class RideOtpWidget extends StatelessWidget {
  final BuildContext cont;
  const RideOtpWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final homeBloc = cont.read<HomeBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        centerTitle: true,
        title: MyText(
          text: (userData!.onTripRequest != null &&
                  userData!.onTripRequest!.transportType == 'delivery')
              ? AppLocalizations.of(context)!.shipmentVerification
              : AppLocalizations.of(context)!.rideVerification,
          textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              if (homeBloc.showImagePick) {
                homeBloc.add(ShowImagePickEvent());
              } else {
                homeBloc.add(ShowOtpEvent());
              }
              Navigator.pop(context, userData);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF232A45)
                      : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: BlocProvider.value(
        value: homeBloc,
        child: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is RideStartSuccessState) {
              Navigator.pop(context, userData);
            }
            if (state is ShowSignatureState) {
              Navigator.pop(context, userData);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final showOtp = !homeBloc.showImagePick &&
                  userData?.onTripRequest != null &&
                  userData!.onTripRequest!.showOtpFeature;

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            children: [
                              if (homeBloc.showImagePick) ...[
                                // Image Upload View inside Card
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: cardBorderColor,
                                      width: 1.0,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: _productImagePickerView(
                                      size, context, isDark),
                                ),
                              ] else if (showOtp) ...[
                                // Mockup OTP View
                                const SizedBox(height: 24),
                                _shieldPadlockIllustration(isDark),
                                const SizedBox(height: 36),

                                MyText(
                                  text: AppLocalizations.of(context)!.enterOtp,
                                  textStyle: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0),
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .enterRideOtpDesc,
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 4,
                                  ),
                                ),
                                const SizedBox(height: 36),

                                _pinCodeView(context, size),
                                const SizedBox(height: 48),

                                // Security Disclaimer Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.shield_outlined,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .onrideSecureAndVerifiedText,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ] else ...[
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],

                              // Progress Step Indicator dots (delivery rides only)
                              if (userData!.onTripRequest != null &&
                                  userData!.onTripRequest!.isTripStart == 0 &&
                                  userData!.onTripRequest!.transportType ==
                                      'delivery' &&
                                  userData!.onTripRequest!.enableShipmentLoad ==
                                      '1' &&
                                  homeBloc.showOtp) ...[
                                _deliveryRideView(context, size),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Continue/Confirm Button at the bottom
                    _bottomActionView(context, size),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _shieldPadlockIllustration(bool isDark) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 5,
            child: Container(
              width: 90,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0038FF)
                        .withOpacity(isDark ? 0.35 : 0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ],
              ),
            ),
          ),
          // Left dot pattern (3x3 grid)
          Positioned(
            left: 50,
            child: _dotPatternGrid(isDark),
          ),
          // Right dot pattern (3x3 grid)
          Positioned(
            right: 50,
            child: _dotPatternGrid(isDark),
          ),
          // Shield shape with gradient and border
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(isDark ? 0.25 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: CustomPaint(
              painter: ShieldPainter(
                color:
                    isDark ? const Color(0xFF131A33) : const Color(0xFFEEF2FF),
                borderColor: AppColors.primary.withOpacity(isDark ? 0.8 : 0.4),
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dotPatternGrid(bool isDark) {
    final dotColor = isDark ? Colors.white24 : Colors.black12;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
          3,
          (r) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    3,
                    (c) => Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dotColor,
                            ),
                          ),
                        )),
              )),
    );
  }

  Widget _productImagePickerView(
    Size size,
    BuildContext context,
    bool isDark,
  ) {
    final homeBloc = context.read<HomeBloc>();
    final bool showLoad = (userData!.onTripRequest == null ||
            userData!.onTripRequest!.isTripStart == 0) &&
        homeBloc.showLoadImage != null;
    final bool showUnload = homeBloc.showUnloadImage != null;
    final bool hasImage = showLoad || showUnload;
    final String? imagePath =
        showLoad ? homeBloc.showLoadImage : homeBloc.showUnloadImage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              MyText(
                text: AppLocalizations.of(context)!.uploadShipmentProof,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              MyText(
                text: AppLocalizations.of(context)!.onrideUploadProofText,
                textStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            homeBloc.add(ImageCaptureEvent());
          },
          borderRadius: BorderRadius.circular(16),
          child: DottedBorder(
            color: const Color(0xFF6366F1).withOpacity(0.5),
            strokeWidth: 1.5,
            dashPattern: const [6, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage && imagePath != null
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          text: AppLocalizations.of(context)!.dropImageHere,
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        MyText(
                          text: AppLocalizations.of(context)!
                              .onrideUploadProofBrowseText,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: MyText(
                            text: AppLocalizations.of(context)!
                                .supportedImage
                                .toString()
                                .replaceAll('1111', 'JPG, PNG')
                                .trim(),
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2238) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF232A45) : const Color(0xFFDBEAFE),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                height: 28,
                width: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.onrideDataSafeText,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    MyText(
                      text: AppLocalizations.of(context)!
                          .onrideDocumentEncryptedText,
                      textStyle: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomActionView(BuildContext context, Size size) {
    final homeBloc = context.read<HomeBloc>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: homeBloc.isLoading
            ? null
            : () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (currentFocus.hasFocus) {
                  currentFocus.unfocus();
                }
                final request = userData!.onTripRequest;

                if (request == null) {
                  homeBloc.add(CreateInstantRideEvent());
                  return;
                }

                if (request.transportType == 'taxi') {
                  if (request.isTripStart == 0) {
                    if (homeBloc.rideOtp.text.isNotEmpty) {
                      homeBloc.add(RideStartEvent(
                          requestId: request.id,
                          otp: homeBloc.rideOtp.text,
                          pickLat: request.pickLat,
                          pickLng: request.pickLng));
                      homeBloc.rideOtp.clear();
                    } else {
                      showToast(
                          message: AppLocalizations.of(context)!.enterOTPText);
                    }
                  } else if (request.isTripStart == 1) {
                    homeBloc.add(RideEndEvent(
                        isAfterGeoCodeEnd: false,
                        isAfterRoutesDistanceCall: false));
                  }
                } else if (request.transportType == 'delivery') {
                  if (request.isTripStart == 0) {
                    if (homeBloc.showImagePick) {
                      if (request.enableShipmentLoad == '1') {
                        if (homeBloc.loadImage != null) {
                          homeBloc.add(UploadProofEvent(
                              image: homeBloc.loadImage!,
                              isBefore: true,
                              id: request.id));
                        } else {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .uploadShipmentProof);
                        }
                      }
                    } else if (request.showOtpFeature) {
                      if (homeBloc.rideOtp.text.isNotEmpty) {
                        if (request.enableShipmentLoad == '1') {
                          homeBloc.add(ShowImagePickEvent());
                        } else {
                          homeBloc.add(RideStartEvent(
                              requestId: request.id,
                              otp: homeBloc.rideOtp.text,
                              pickLat: request.pickLat,
                              pickLng: request.pickLng));
                          homeBloc.rideOtp.clear();
                        }
                      } else {
                        showToast(
                            message:
                                AppLocalizations.of(context)!.enterOTPText);
                      }
                    } else {
                      // showOtpFeature is false
                      if (request.enableShipmentLoad == '1') {
                        homeBloc.add(ShowImagePickEvent());
                      } else {
                        homeBloc.add(RideStartEvent(
                            requestId: request.id,
                            otp: homeBloc.rideOtp.text,
                            pickLat: request.pickLat,
                            pickLng: request.pickLng));
                        homeBloc.rideOtp.clear();
                      }
                    }
                  } else if (request.isTripStart == 1) {
                    if (homeBloc.showImagePick) {
                      if (request.enableShipmentUnload == '1') {
                        if (homeBloc.unloadImage != null) {
                          Navigator.pop(context);
                          homeBloc.add(UploadProofEvent(
                              image: homeBloc.unloadImage!,
                              isBefore: false,
                              id: request.id));
                        } else {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .uploadShipmentProof);
                        }
                      }
                    } else if (request.showOtpFeature) {
                      if (homeBloc.rideOtp.text.isNotEmpty) {
                        final remainingStops = request.requestStops
                            .where((e) => e['completed_at'] == null)
                            .length;
                        if (remainingStops > 1) {
                          homeBloc.add(StopVerifyOtpEvent(
                              otp: homeBloc.rideOtp.text,
                              stopId: homeBloc.choosenCompleteStop!));
                          homeBloc.rideOtp.clear();
                        } else if (remainingStops == 1 ||
                            request.requestStops.isEmpty) {
                          homeBloc.add(StopVerifyOtpEvent(
                              otp: homeBloc.rideOtp.text,
                              stopId: '',
                              requestId: request.id));
                          homeBloc.rideOtp.clear();
                        } else {
                          if (request.enableShipmentUnload == '1') {
                            homeBloc.add(ShowImagePickEvent());
                          }
                        }
                      } else {
                        showToast(
                            message:
                                AppLocalizations.of(context)!.enterOTPText);
                      }
                    } else {
                      // showOtpFeature is false
                      if (request.enableShipmentUnload == '1') {
                        if (homeBloc.unloadImage != null) {
                          Navigator.pop(context);
                          homeBloc.add(UploadProofEvent(
                              image: homeBloc.unloadImage!,
                              isBefore: false,
                              id: request.id));
                        } else {
                          homeBloc.add(ShowImagePickEvent());
                        }
                      }
                    }
                  }
                }
              },
        child: Container(
          width: size.width,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withOpacity(isDark ? 0.35 : 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: homeBloc.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.continueText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Positioned(
                        right: 24,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _pinCodeView(BuildContext context, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinBoxBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final activeBorderColor = AppColors.primary;
    final inactiveBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE2E8F0);
    final textStyleColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return SizedBox(
      width: size.width * 0.8,
      child: PinCodeTextField(
        appContext: (context),
        length: 4,
        autoFocus: true,
        controller: context.read<HomeBloc>().rideOtp,
        textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textStyleColor,
        ),
        obscureText: false,
        blinkWhenObscuring: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(16),
          fieldHeight: 64,
          fieldWidth: 60,
          activeFillColor: pinBoxBgColor,
          inactiveFillColor: pinBoxBgColor,
          selectedFillColor: pinBoxBgColor,
          activeColor: activeBorderColor,
          inactiveColor: inactiveBorderColor,
          selectedColor: activeBorderColor,
          selectedBorderWidth: 2,
          inactiveBorderWidth: 1.0,
          activeBorderWidth: 1.5,
        ),
        cursorColor: activeBorderColor,
        enableActiveFill: true,
        enablePinAutofill: false,
        autoDisposeControllers: false,
        keyboardType: TextInputType.number,
        boxShadows: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
        onChanged: (_) => context.read<HomeBloc>().add(UpdateEvent()),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }

  Widget _deliveryRideView(BuildContext context, Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeBloc = context.read<HomeBloc>();
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 8,
              width: homeBloc.showImagePick ? 8 : 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: homeBloc.showImagePick
                    ? (isDark ? Colors.white24 : Colors.black12)
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 8,
              width: homeBloc.showImagePick ? 24 : 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: homeBloc.showImagePick
                    ? AppColors.primary
                    : (isDark ? Colors.white24 : Colors.black12),
              ),
            )
          ],
        )
      ],
    );
  }
}

class ShieldPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  ShieldPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    // Curve to top right
    path.quadraticBezierTo(
        size.width * 0.85, size.height * 0.05, size.width, size.height * 0.2);
    // Curve down to bottom center tip
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.75, size.width / 2, size.height);
    // Curve up to top left
    path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.75, 0, size.height * 0.2);
    // Curve to top center
    path.quadraticBezierTo(
        size.width * 0.15, size.height * 0.05, size.width / 2, 0);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
