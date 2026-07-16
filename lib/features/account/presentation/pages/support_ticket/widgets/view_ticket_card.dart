import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/view_ticket_model.dart';
import 'package:intl/intl.dart' as intl;
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/attachment_preview_list.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';

class ViewTicketCard extends StatelessWidget {
  final Size size;
  final SupportTicket ticketData;

  const ViewTicketCard({
    super.key,
    required this.size,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor =
        isDark ? const Color(0xFF131E35) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final primaryText =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.047),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      width: size.width * 0.9,
      child: (ticketData.user != null)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          ticketData.user!.profilePicture.isNotEmpty
                              ? NetworkImage(ticketData.user!.profilePicture)
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: ticketData.user!.name,
                            textStyle: TextStyle(
                              color: primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          MyText(
                            text: intl.DateFormat('d Nov, h:mm a')
                                .format(ticketData.user!.createdAt)
                                .toString(),
                            textStyle: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context, ticketData.status, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Key-value rows aligned in a tabular style
                _buildInfoRow(
                  context,
                  icon: Icons.confirmation_number,
                  iconColor: AppColors.primary,
                  label: AppLocalizations.of(context)!.ticketId,
                  value: ticketData.ticketId,
                  isDark: isDark,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.local_offer,
                  iconColor: const Color(0xFFF97316),
                  label: AppLocalizations.of(context)!.title,
                  value: ticketData.ticketTitle.title,
                  isDark: isDark,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.description,
                  iconColor: const Color(0xFF8B5CF6),
                  label: AppLocalizations.of(context)!.description,
                  value: ticketData.description,
                  isMultiline: true,
                  isDark: isDark,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.headset_mic,
                  iconColor: const Color(0xFF10B981),
                  label: AppLocalizations.of(context)!.supportType,
                  value: ticketData.supportType,
                  isDark: isDark,
                ),
                _buildInfoRow(
                  context,
                  icon: Icons.person,
                  iconColor: AppColors.primary,
                  label: AppLocalizations.of(context)!.assignTo,
                  value: ticketData.adminName ??
                      AppLocalizations.of(context)!.notAssigned,
                  valueColor: ticketData.adminName == null
                      ? const Color(0xFFEF4444)
                      : null,
                  isDark: isDark,
                ),

                if (context
                    .read<AccBloc>()
                    .viewAttachments
                    .map((e) => e.image)
                    .toList()
                    .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.attachments,
                        textStyle: TextStyle(
                          color: secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: AttachmentPreviewList(
                      imageUrls: context
                          .read<AccBloc>()
                          .viewAttachments
                          .map((e) => e.image)
                          .toList(),
                    ),
                  ),
                ],
              ],
            )
          : const SizedBox(),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    bool isMultiline = false,
    required bool isDark,
  }) {
    final primaryText =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: size.width * 0.28,
            child: MyText(
              text: label,
              textStyle: TextStyle(
                color: secondaryText,
                fontSize: 14,
              ),
            ),
          ),
          MyText(
            text: " :  ",
            textStyle: TextStyle(
              color: secondaryText,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: MyText(
              text: value,
              textStyle: TextStyle(
                color: valueColor ?? primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: isMultiline ? 6 : 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, int status, bool isDark) {
    String statusText = '';
    Color badgeColor = AppColors.primary;
    Color badgeBgColor = const Color(0xFFEFF6FF);
    IconData statusIcon = Icons.access_time;

    if (status == 1) {
      statusText = AppLocalizations.of(context)!.pending;
      badgeColor = AppColors.primary;
      badgeBgColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
      statusIcon = Icons.access_time;
    } else if (status == 2) {
      statusText = AppLocalizations.of(context)!.acknowledged;
      badgeColor = const Color(0xFFD97706);
      badgeBgColor = isDark ? const Color(0xFF2D2310) : const Color(0xFFFEF3C7);
      statusIcon = Icons.hourglass_empty;
    } else {
      statusText = AppLocalizations.of(context)!.closed;
      badgeColor = const Color(0xFFEF4444);
      badgeBgColor = isDark ? const Color(0xFF2D1616) : const Color(0xFFFEE2E2);
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: badgeColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          MyText(
            text: statusText,
            textStyle: TextStyle(
              fontSize: 12,
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
