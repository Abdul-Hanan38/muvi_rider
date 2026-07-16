import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/widgets/image_picker_dialog.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class EditDocumentWidget extends StatelessWidget {
  final BuildContext cont;
  const EditDocumentWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();
          if (driverBloc.neededDocuments.isEmpty) {
            return const SizedBox();
          }

          final currentDoc = driverBloc.neededDocuments
              .firstWhere((e) => e.id == driverBloc.choosenDocument);

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBg =
              isDark ? const Color(0xFF080F19) : const Color(0xFFF8FAFC);
          final cardBg = isDark ? const Color(0xFF0D1623) : Colors.white;
          final cardBorder = isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0);
          final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final subtitleColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;
          final isRtl = Directionality.of(context) == TextDirection.rtl;

          final isEditable = currentDoc.isEditable || driverBloc.isEditable;

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: SafeArea(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PositionedDirectional(
                        start: 0,
                        child: InkWell(
                          onTap: () {
                            final upload = currentDoc.isUploaded;
                            if (upload) {
                              driverBloc
                                  .add(EnableEditEvent(isEditable: false));
                            } else {
                              driverBloc.add(ChooseDocumentEvent(id: null));
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Icon(
                            isRtl ? Icons.arrow_forward : Icons.arrow_back,
                            color: titleColor,
                            size: 20,
                          ),
                        ),
                      ),
                      MyText(
                        text:
                            '${AppLocalizations.of(context)!.upload} ${currentDoc.name}',
                        textStyle:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: titleColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // ── Scrollable Content ───────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // ── Front Image ──────────────────────────────────────
                        MyText(
                          text: currentDoc.isFrontAndBack == true
                              ? AppLocalizations.of(context)!
                                  .editDocumentFrontText
                                  .replaceAll('111', currentDoc.name.toString())
                              : AppLocalizations.of(context)!
                                  .editDocumentImageText
                                  .replaceAll(
                                      '111', currentDoc.name.toString()),
                          textStyle: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildUploadZone(
                          context: context,
                          size: size,
                          isDark: isDark,
                          cardBorder: cardBorder,
                          primaryBlue: primaryBlue,
                          titleColor: titleColor,
                          subtitleColor: subtitleColor,
                          imagePath: driverBloc.docImage,
                          isEditable: isEditable,
                          onTap: () {
                            if (isEditable) {
                              showModalBottomSheet(
                                isScrollControlled: false,
                                context: context,
                                useSafeArea: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (_) {
                                  return SafeArea(
                                    child: ImagePickerDialog(
                                      size: size.width,
                                      onImageSelected: (ImageSource source) {
                                        driverBloc.add(PickImageEvent(
                                            source: source, isFront: true));
                                      },
                                    ),
                                  );
                                },
                              );
                            }
                          },
                        ),

                        // ── Back Image (if front & back document) ────────────
                        if (currentDoc.isFrontAndBack == true) ...[
                          const SizedBox(height: 20),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .editDocumentBackText
                                .replaceAll('111', currentDoc.name.toString()),
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildUploadZone(
                            context: context,
                            size: size,
                            isDark: isDark,
                            cardBorder: cardBorder,
                            primaryBlue: primaryBlue,
                            titleColor: titleColor,
                            subtitleColor: subtitleColor,
                            imagePath: driverBloc.docImageBack,
                            isEditable: isEditable,
                            onTap: () {
                              if (isEditable) {
                                showModalBottomSheet(
                                  isScrollControlled: false,
                                  context: context,
                                  useSafeArea: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (_) {
                                    return SafeArea(
                                      child: ImagePickerDialog(
                                        size: size.width,
                                        onImageSelected: (ImageSource source) {
                                          driverBloc.add(PickImageEvent(
                                              source: source, isFront: false));
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],

                        const SizedBox(height: 24),

                        // ── Security banner ──────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0E1726)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.verified_user_outlined,
                                  color: primaryBlue,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MyText(
                                  text: AppLocalizations.of(context)!
                                      .documentSecureAndEncryptedText,
                                  textStyle: TextStyle(
                                    color: titleColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Identity Number ──────────────────────────────────
                        if (currentDoc.hasIdNumer) ...[
                          MyText(
                            text: currentDoc.idKey ?? '',
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: driverBloc.documentId,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            filled: true,
                            fillColor: cardBg,
                            borderRadius: 12,
                            hintText: currentDoc.idKey ?? '',
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(
                                Icons.badge_outlined,
                                color: primaryBlue,
                                size: 20,
                              ),
                            ),
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            hintTextStyle: TextStyle(
                              color: subtitleColor,
                              fontSize: 15,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: primaryBlue, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: cardBorder, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: cardBorder, width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 24),
                        ],

                        // ── Expiry Date ──────────────────────────────────────
                        if (currentDoc.hasExpiryDate) ...[
                          MyText(
                            text:
                                AppLocalizations.of(context)!.chooseExpiryDate,
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              driverBloc.add(ChooseDateEvent(context: context));
                            },
                            child: IgnorePointer(
                              child: CustomTextField(
                                controller: driverBloc.documentExpiry,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                filled: true,
                                fillColor: cardBg,
                                borderRadius: 12,
                                hintText:
                                    '${currentDoc.name} ${AppLocalizations.of(context)!.expiryDate}',
                                readOnly: true,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    color: primaryBlue,
                                    size: 20,
                                  ),
                                ),
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintTextStyle: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 15,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: primaryBlue, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: cardBorder, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: cardBorder, width: 1.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),

                // ── Submit Button Footer ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    border: Border(
                      top: BorderSide(color: cardBorder, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            if (driverBloc.docImage != null &&
                                (currentDoc.hasExpiryDate == false ||
                                    driverBloc
                                        .documentExpiry.text.isNotEmpty) &&
                                (currentDoc.hasIdNumer == false ||
                                    driverBloc.documentId.text.isNotEmpty)) {
                              driverBloc.uploadDocs = true;
                              driverBloc.add(UploadDocumentEvent(
                                  id: driverBloc.choosenDocument!,
                                  fleetId: driverBloc.fleetId));
                            } else {
                              context.showSnackBar(
                                  color: AppColors.red,
                                  message: AppLocalizations.of(context)!
                                      .enterRequiredField);
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color:
                                            primaryBlue.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      )
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              AppLocalizations.of(context)!.submit,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: subtitleColor,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .neverShareYourInfoText,
                              textStyle: TextStyle(
                                color: subtitleColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
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

  // ── Upload Zone ─────────────────────────────────────────────────────────────
  Widget _buildUploadZone({
    required BuildContext context,
    required Size size,
    required bool isDark,
    required Color cardBorder,
    required Color primaryBlue,
    required Color titleColor,
    required Color subtitleColor,
    required String? imagePath,
    required bool isEditable,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: cardBorder,
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        child: Container(
          height: size.width * 0.5,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1A2E) : const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(15),
          ),
          child: imagePath == null
              ? _buildEmptyPlaceholder(
                  context, size, isDark, primaryBlue, subtitleColor, isEditable)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Empty upload placeholder ─────────────────────────────────────────────────
  Widget _buildEmptyPlaceholder(
    BuildContext context,
    Size size,
    bool isDark,
    Color primaryBlue,
    Color subtitleColor,
    bool isEditable,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.15,
          height: size.width * 0.15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: size.width * 0.08,
                color: primaryBlue,
              ),
              Positioned(
                bottom: size.width * 0.02,
                right: size.width * 0.02,
                child: Container(
                  padding: EdgeInsets.all(size.width * 0.008),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: size.width * 0.025,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.width * 0.03),
        MyText(
          text: AppLocalizations.of(context)!.tapToUploadImage,
          textStyle: TextStyle(
            color: isEditable ? primaryBlue : subtitleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: size.width * 0.01),
        MyText(
          text: 'JPG, PNG or PDF • Max 5MB',
          textStyle: TextStyle(
            color: subtitleColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
