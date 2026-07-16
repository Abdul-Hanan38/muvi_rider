import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/app_colors.dart';

class DocumentViewWidget extends StatelessWidget {
  final BuildContext cont;
  const DocumentViewWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final bloc = context.read<DriverProfileBloc>();
          if (bloc.neededDocuments.isEmpty) {
            return const SizedBox();
          }

          final currentDoc = bloc.neededDocuments
              .firstWhere((e) => e.id == bloc.choosenDocument);

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
                            bloc.add(ChooseDocumentEvent(id: null));
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
                        text: currentDoc.name,
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
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        MyText(
                          text: AppLocalizations.of(context)!
                              .editDocumentImageText
                              .replaceAll('111', currentDoc.name.toString()),
                          textStyle: TextStyle(
                            color: titleColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: size.width * 0.5,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cardBorder, width: 1.5),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                            image: DecorationImage(
                              image: NetworkImage(
                                currentDoc.document!['data']['document']
                                    .toString(),
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (currentDoc.isFrontAndBack == true &&
                            currentDoc.document!['data']['back_document'] !=
                                null) ...[
                          const SizedBox(height: 20),
                          MyText(
                            text: '${currentDoc.name} Back Image',
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: size.width * 0.5,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cardBorder, width: 1.5),
                              boxShadow: isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                              image: DecorationImage(
                                image: NetworkImage(
                                  currentDoc.document!['data']['back_document']
                                      .toString(),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Secure storage banner
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
                        // ID Number
                        if (currentDoc.hasIdNumer) ...[
                          MyText(
                            text: AppLocalizations.of(context)!.yourId,
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0D1623)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentDoc.document!['data']
                                            ['identify_number']
                                        .toString(),
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        // Expiry Date
                        if (currentDoc.hasExpiryDate) ...[
                          MyText(
                            text: AppLocalizations.of(context)!.expiryDate,
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0D1623)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cardBorder, width: 1.5),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    currentDoc.document!['data']['expiry_date']
                                        .toString(),
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
                // Edit button footer
                if (currentDoc.isEditable)
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
                              bloc.add(EnableEditEvent(isEditable: true));
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
                                          color: primaryBlue.withValues(
                                              alpha: 0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        )
                                      ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                AppLocalizations.of(context)!.edit,
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
}
