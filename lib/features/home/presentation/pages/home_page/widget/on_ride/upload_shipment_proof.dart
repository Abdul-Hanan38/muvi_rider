import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../common/app_colors.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class UploadShipmentProofWidget extends StatelessWidget {
  const UploadShipmentProofWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final homeBloc = context.read<HomeBloc>();

        final bool showLoad = (userData!.onTripRequest == null ||
                userData!.onTripRequest!.isTripStart == 0) &&
            homeBloc.showLoadImage != null;
        final bool showUnload = homeBloc.showUnloadImage != null;
        final bool hasImage = showLoad || showUnload;
        final String? imagePath =
            showLoad ? homeBloc.showLoadImage : homeBloc.showUnloadImage;

        return Scaffold(
          backgroundColor: scaffoldBgColor,
          appBar: AppBar(
            backgroundColor: scaffoldBgColor,
            elevation: 0,
            centerTitle: true,
            title: MyText(
              text: AppLocalizations.of(context)!.shipmentVerification,
              textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // Section Title & Description
                          Center(
                            child: Column(
                              children: [
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .uploadShipmentProof,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .onrideUploadShipmentProofText,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Main Verification Card
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
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Upload Box
                                InkWell(
                                  onTap: () {
                                    homeBloc.add(ImageCaptureEvent());
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: DottedBorder(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.5),
                                    strokeWidth: 1.5,
                                    dashPattern: const [6, 4],
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(16),
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Circular Upload Cloud Icon
                                                Container(
                                                  height: 48,
                                                  width: 48,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF1E293B)
                                                        : const Color(
                                                            0xFFEFF6FF),
                                                  ),
                                                  child: const Icon(
                                                    Icons.cloud_upload_outlined,
                                                    color: AppColors.primary,
                                                    size: 24,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .dropImageHere,
                                                  textStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1F2937),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .onrideUploadProofBrowseText,
                                                  textStyle: const TextStyle(
                                                    fontSize: 13,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                // Pill Info
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? const Color(
                                                            0xFF1E293B)
                                                        : const Color(
                                                            0xFFF1F5F9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .supportedImage
                                                        .toString()
                                                        .replaceAll(
                                                            '1111', 'JPG, PNG')
                                                        .trim(),
                                                    textStyle: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
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

                                // Security Banner Badge
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1A2238)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF232A45)
                                          : const Color(0xFFDBEAFE),
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 32,
                                        width: 32,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                        child: const Icon(
                                          Icons.verified_user_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .onrideDataSafeText,
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1E3A8A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            MyText(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .onrideDocumentEncryptedText,
                                              textStyle: TextStyle(
                                                fontSize: 11,
                                                color: isDark
                                                    ? Colors.white60
                                                    : AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tips Section
                          MyText(
                            text: AppLocalizations.of(context)!
                                .tipsForGoodPhotosText,
                            textStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 3,
                            width: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Tips Rows
                          _buildTipRow(
                            icon: Icons.wb_sunny_outlined,
                            title: AppLocalizations.of(context)!
                                .tipsForGoodPhotosTitleTextOne,
                            desc: AppLocalizations.of(context)!
                                .tipsForGoodPhotosSubTextOne,
                            isDark: isDark,
                          ),
                          _buildTipRow(
                            icon: Icons.description_outlined,
                            title: AppLocalizations.of(context)!
                                .tipsForGoodPhotosTitleTextTwo,
                            desc: AppLocalizations.of(context)!
                                .tipsForGoodPhotosSubTextTwo,
                            isDark: isDark,
                          ),
                          _buildTipRow(
                            icon: Icons.camera_alt_outlined,
                            title: AppLocalizations.of(context)!
                                .tipsForGoodPhotosTitleTextThree,
                            desc: AppLocalizations.of(context)!
                                .tipsForGoodPhotosSubTextThree,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: CustomButton(
                    width: size.width,
                    height: 52,
                    borderRadius: 30,
                    buttonColor: const Color(0xFF0038FF),
                    buttonName: AppLocalizations.of(context)!.continueText,
                    onTap: () {
                      if (userData!.onTripRequest == null ||
                          userData!.onTripRequest!.isTripStart == 0) {
                        if (homeBloc.loadImage != null) {
                          Navigator.pop(context);
                          if (userData!.onTripRequest == null) {
                            homeBloc.add(CreateInstantRideEvent());
                          } else {
                            homeBloc.add(UploadProofEvent(
                                image: homeBloc.loadImage!,
                                isBefore: false,
                                id: userData!.onTripRequest!.id));
                          }
                        }
                      } else {
                        if (homeBloc.unloadImage != null) {
                          Navigator.pop(context);
                          homeBloc.add(UploadProofEvent(
                              image: homeBloc.unloadImage!,
                              isBefore: false,
                              id: userData!.onTripRequest!.id));
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF0F2C20) : const Color(0xFFE8F5E9),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF10B981),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: title,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  text: desc,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
