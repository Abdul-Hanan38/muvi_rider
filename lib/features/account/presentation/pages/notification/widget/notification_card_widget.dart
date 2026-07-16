import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/notifications_model.dart';

class NotificationCardWidget extends StatelessWidget {
  final BuildContext cont;
  final NotificationData notificationData;

  const NotificationCardWidget({
    super.key,
    required this.cont,
    required this.notificationData,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBgColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF1F2D4A) : const Color(0xFFF1F3F6);
    final textDarkColor = isDark ? Colors.white : const Color(0xFF19191F);
    final textLightColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final bellCircleBg =
        isDark ? const Color(0xFF1F2E54) : const Color(0xFFF0F2FF);
    final bellIconColor = isDark ? AppColors.secondary : AppColors.primary;

    // Format display date safely
    String displayDate = '';
    final dateParts = notificationData.convertedCreatedAt.split(' ');
    if (dateParts.isNotEmpty) {
      displayDate = dateParts[0];
      if (dateParts.length > 1) {
        displayDate += ' ${dateParts[1]}';
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unread Indicator & Bell Icon Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bellCircleBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.bellRing,
                        width: 20,
                        height: 20,
                        color: bellIconColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Text Content Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: notificationData.title,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textDarkColor),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      text: notificationData.body,
                      textStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                fontSize: 13,
                                color: textLightColor,
                              ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Date + Delete Action Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    text: displayDate,
                    textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 11,
                          color: textLightColor,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  const SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext _) {
                          return BlocProvider.value(
                            value: context.read<AccBloc>(),
                            child: CustomSingleButtonDialoge(
                              title: AppLocalizations.of(context)!
                                  .deleteNotification,
                              content: AppLocalizations.of(context)!
                                  .deleteNotificationContent,
                              btnName: AppLocalizations.of(context)!.confirm,
                              onTap: () {
                                context.read<AccBloc>().add(
                                    DeleteNotificationEvent(
                                        id: notificationData.id));
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFEF413B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),

          /// IMAGE SECTION
          if (notificationData.image != null &&
              notificationData.image!.isNotEmpty) ...[
            SizedBox(height: size.height * 0.015),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                notificationData.image!,
                width: double.infinity,
                height: size.width * 0.6,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
