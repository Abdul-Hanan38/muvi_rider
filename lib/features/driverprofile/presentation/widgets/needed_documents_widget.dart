import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../common/common.dart';

class NeededDocumentsWidget extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments arg;
  const NeededDocumentsWidget(
      {super.key, required this.cont, required this.arg});

  // ─── Status helpers ─────────────────────────────────────────────────────────

  static bool _isWaiting(String? s) =>
      s == 'waiting_for_approval' ||
      s == 'reuploaded_and_waiting_for_approval' ||
      s == 'Waiting For Approval' ||
      s == 'Reuploaded and Waiting For Approval';

  static bool _isApproved(String? s) =>
      s == 'uploaded_and_approved' || s == 'Uploaded and Approved';

  static bool _isDeclined(String? s) =>
      s == 'reuploaded_and_declined' || s == 'Reuploaded and Declined';

  // ─── Icon background colours (rotated across documents) ────────────────────
  static const List<Color> _iconBgColors = [
    Color(0xFFEEF0FF), // light indigo
    Color(0xFFE6F4F1), // light teal
    Color(0xFFFFF3E0), // light orange
    Color(0xFFF3E5F5), // light purple
    Color(0xFFE8F5E9), // light green
  ];

  static const List<Color> _iconBgColorsDark = [
    Color(0xFF1E2540),
    Color(0xFF0D2820),
    Color(0xFF2A1A00),
    Color(0xFF2A1040),
    Color(0xFF0D2515),
  ];

  static const List<Color> _iconColors = [
    Color(0xFF3D5AFE), // indigo
    Color(0xFF00897B), // teal
    Color(0xFFE65100), // deep orange
    Color(0xFF7B1FA2), // purple
    Color(0xFF388E3C), // green
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();

          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardBg = isDark ? const Color(0xFF0D1623) : Colors.white;
          final cardBorder = isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0);
          final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final subtitleColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final primaryBlue =
              isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B2EC2);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Document cards ────────────────────────────────────────────
              ListView.separated(
                itemCount: driverBloc.neededDocuments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final doc = driverBloc.neededDocuments[i];
                  final statusString = doc.document != null
                      ? doc.document!['data']['document_status_string']
                          as String?
                      : null;

                  final colorIdx = i % _iconBgColors.length;
                  final iconBg = isDark
                      ? _iconBgColorsDark[colorIdx]
                      : _iconBgColors[colorIdx];
                  final iconColor = _iconColors[colorIdx];

                  return _DocumentCard(
                    doc: doc,
                    isDark: isDark,
                    cardBg: cardBg,
                    cardBorder: cardBorder,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    primaryBlue: primaryBlue,
                    iconBg: iconBg,
                    iconColor: iconColor,
                    statusString: statusString,
                    onTap: () {
                      final upload = doc.isUploaded;
                      driverBloc.add(EnableEditEvent(
                          isEditable: (!upload) ? true : false));
                      driverBloc.add(ChooseDocumentEvent(id: doc.id));
                    },
                    size: size,
                    index: i,
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Submit button ─────────────────────────────────────────────
              if ((driverBloc.showSubmitButton && arg.from != 'docs') ||
                  (driverBloc.fleetId != null && arg.from != 'docs'))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          if (context
                              .read<DriverProfileBloc>()
                              .neededDocuments
                              .any((doc) =>
                                  (doc.isRequired && !doc.isUploaded))) {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .documentMissingText);
                          } else {
                            if (driverBloc.fleetId != null) {
                              Navigator.pop(context);
                              driverBloc.add(DriverUpdateEvent());
                            } else {
                              driverBloc.reUploadDocument = false;
                              driverBloc.add(ModifyDocEvent());
                              driverBloc.add(DriverGetUserDetailsEvent());
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            color: primaryBlue,
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Individual Document Card ──────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final dynamic doc;
  final bool isDark;
  final Color cardBg;
  final Color cardBorder;
  final Color titleColor;
  final Color subtitleColor;
  final Color primaryBlue;
  final Color iconBg;
  final Color iconColor;
  final String? statusString;
  final VoidCallback onTap;
  final Size size;
  final int index;

  const _DocumentCard({
    required this.doc,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.titleColor,
    required this.subtitleColor,
    required this.primaryBlue,
    required this.iconBg,
    required this.iconColor,
    required this.statusString,
    required this.onTap,
    required this.size,
    required this.index,
  });

  // ── Status colour ────────────────────────────────────────────────────────────
  Color get _statusColor {
    if (NeededDocumentsWidget._isApproved(statusString)) {
      return const Color(0xFF22C55E); // green
    } else if (NeededDocumentsWidget._isDeclined(statusString)) {
      return const Color(0xFFEF4444); // red
    } else if (NeededDocumentsWidget._isWaiting(statusString)) {
      return const Color(0xFFF59E0B); // amber
    }
    return const Color(0xFF94A3B8); // grey — not uploaded
  }

  // ── Status text ──────────────────────────────────────────────────────────────
  String _statusText(BuildContext context) {
    if (doc.document == null) {
      return AppLocalizations.of(context)!.notUploaded;
    }
    return statusString ?? AppLocalizations.of(context)!.notUploaded;
  }

  // ── Action button label ───────────────────────────────────────────────────────
  String _buttonLabel(BuildContext context) {
    if (doc.document == null) {
      return AppLocalizations.of(context)!.uploadDocuments;
    }
    if (NeededDocumentsWidget._isWaiting(statusString) ||
        NeededDocumentsWidget._isDeclined(statusString)) {
      return AppLocalizations.of(context)!.reuploadDocument;
    }
    return AppLocalizations.of(context)!.viewDocument;
  }

  // ── Action button icon ────────────────────────────────────────────────────────
  IconData get _buttonIcon {
    if (doc.document == null) {
      return Icons.cloud_upload_outlined;
    }
    if (NeededDocumentsWidget._isWaiting(statusString) ||
        NeededDocumentsWidget._isDeclined(statusString)) {
      return Icons.refresh_rounded;
    }
    return Icons.remove_red_eye_outlined;
  }

  // ── Document type icon ────────────────────────────────────────────────────────
  static const List<IconData> _docIcons = [
    Icons.credit_card_outlined,
    Icons.badge_outlined,
    Icons.article_outlined,
    Icons.description_outlined,
    Icons.folder_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final iconData = _docIcons[index % _docIcons.length];
    final hasDocument = doc.document != null;
    final statusColor = _statusColor;

    // "view document" style button (blue outline) vs upload/reupload (blue fill)
    final isViewMode =
        hasDocument && NeededDocumentsWidget._isApproved(statusString);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder, width: 1.2),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          children: [
            // ── Top row: icon + name + status ────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Coloured icon with green tick overlay
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        iconData,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                    // Status dot badge
                    if (hasDocument)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                          child: Icon(
                            NeededDocumentsWidget._isApproved(statusString)
                                ? Icons.check
                                : NeededDocumentsWidget._isDeclined(
                                        statusString)
                                    ? Icons.close
                                    : Icons.access_time_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                // Name + status label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: doc.name,
                        textStyle: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: statusColor,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text: _statusText(context),
                              textStyle: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Action button ─────────────────────────────────────────────────
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: isViewMode
                      ? (isDark
                          ? const Color(0xFF0D1A2E)
                          : const Color(0xFFF0F4FF))
                      : primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: isViewMode
                      ? Border.all(color: primaryBlue.withValues(alpha: 0.35))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _buttonIcon,
                      color: isViewMode ? primaryBlue : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _buttonLabel(context),
                      style: TextStyle(
                        color: isViewMode ? primaryBlue : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
