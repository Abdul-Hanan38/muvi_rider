import 'package:flutter/material.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_list_model.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/page/view_ticket_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';

class TicketCard extends StatelessWidget {
  final Size size;
  final TicketData ticketData;
  final bool isFromViewPage;
  const TicketCard(
      {super.key,
      required this.size,
      required this.ticketData,
      required this.isFromViewPage});

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
    final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ViewTicketPage.routeName,
          arguments: ViewTicketPageArguments(
              isViewTicketPage: true,
              ticketId: ticketData.ticketId,
              id: ticketData.id),
        );
      },
      child: Column(
        children: [
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Ticket ID + Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? primaryBlue.withOpacity(0.15)
                            : primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.ticketId,
                            textStyle: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          MyText(
                            text: ticketData.ticketId,
                            textStyle: TextStyle(
                              color: primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(context, ticketData.status, isDark),
                  ],
                ),
                const SizedBox(height: 16),
                // Row 2: Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? primaryBlue.withOpacity(0.15)
                            : primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.title,
                            textStyle: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          MyText(
                            text: ticketData.ticketTitle != null
                                ? ticketData.ticketTitle.title
                                : ticketData.title,
                            textStyle: TextStyle(
                              color: primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Row 3: Support Type
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? primaryBlue.withOpacity(0.15)
                            : primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.layers_outlined,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.supportType,
                            textStyle: TextStyle(
                              color: secondaryText,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          MyText(
                            text: ticketData.supportType,
                            textStyle: TextStyle(
                              color: primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isFromViewPage && ticketData.assignTo != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? primaryBlue.withOpacity(0.15)
                              : primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.assignTo,
                              textStyle: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            MyText(
                              text: "${ticketData.assignTo}",
                              textStyle: TextStyle(
                                color: primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
