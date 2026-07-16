import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../common/app_images.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/notification_card_widget.dart';
import '../widget/notification_page_shimmer.dart';

class NotificationPage extends StatelessWidget {
  static const String routeName = '/notification';

  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(NotificationGetEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is NotificationDeletedSuccess) {
            Navigator.of(context).pop();
            context.read<AccBloc>().add(NotificationGetEvent());
          } else if (state is NotificationClearedSuccess) {
            context.read<AccBloc>().add(NotificationGetEvent());
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final backgroundColor =
              isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
          final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
          final textLightColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.notifications,
              automaticallyImplyLeading: true,
              titleFontSize: 18,
              showBorder: false,
              backgroundColor: backgroundColor,
              textColor: textDarkColor,
              leadingColor: textDarkColor,
            ),
            body: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (context.read<AccBloc>().isLoading &&
                              context
                                  .read<AccBloc>()
                                  .notificationDatas
                                  .isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: size.height * 0.03,
                              ),
                              child: NotificationShimmer(size: size),
                            );
                          } else if (context
                                  .read<AccBloc>()
                                  .notificationDatas
                                  .isEmpty &&
                              !context.read<AccBloc>().isLoading) {
                            return Padding(
                              padding: EdgeInsets.only(top: size.height * 0.08),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  vertical: size.width * 0.08,
                                  horizontal: size.width * 0.04,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131E35)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1F2D4A)
                                        : const Color(0xFFF1F3F6),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      AppImages.notificationNoDataImage,
                                      width: size.width * 0.45,
                                      height: size.width * 0.45,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: size.width * 0.04),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                                  .noNotificationAvail ==
                                              AppLocalizations.of(context)!
                                                  .noNotificationAvailableText
                                          ? AppLocalizations.of(context)!
                                              .youAllcaughtUpText
                                          : AppLocalizations.of(context)!
                                              .noNotificationAvail,
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textDarkColor,
                                      ),
                                    ),
                                    SizedBox(height: size.width * 0.02),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .noMoreNotificationsShowText,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: textLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          if (index == 0) {
                            final clearAllColor = isDark
                                ? const Color(0xFFEF413B)
                                : AppColors.primary;
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: size.height * 0.02, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext _) {
                                          return BlocProvider.value(
                                              value: BlocProvider.of<AccBloc>(
                                                  context),
                                              child: CustomDoubleButtonDialoge(
                                                title: AppLocalizations.of(
                                                        context)!
                                                    .clearNotifications,
                                                content: AppLocalizations.of(
                                                        context)!
                                                    .clearNotificationsText,
                                                yesBtnName: AppLocalizations.of(
                                                        context)!
                                                    .confirm,
                                                noBtnName: AppLocalizations.of(
                                                        context)!
                                                    .cancel,
                                                yesBtnFunc: () {
                                                  context.read<AccBloc>().add(
                                                      ClearAllNotificationsEvent());
                                                  Navigator.pop(context);
                                                },
                                                noBtnFunc: () {
                                                  Navigator.pop(context);
                                                },
                                              ));
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          color: clearAllColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .clearAll,
                                          style: TextStyle(
                                            color: clearAllColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (index <
                              context.read<AccBloc>().notificationDatas.length +
                                  1) {
                            final datum = context
                                .read<AccBloc>()
                                .notificationDatas[index - 1];
                            return NotificationCardWidget(
                                cont: context, notificationData: datum);
                          } else {
                            return null;
                          }
                        },
                        childCount:
                            context.read<AccBloc>().notificationDatas.length +
                                1,
                      ),
                    ),
                  ),
                  if (context.read<AccBloc>().notificationPaginations != null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination !=
                          null &&
                      context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .currentPage <
                          context
                              .read<AccBloc>()
                              .notificationPaginations!
                              .pagination
                              .totalPages)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: size.width * 0.04),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                final accBloc = context.read<AccBloc>();
                                if (!accBloc.loadMoreNotification &&
                                    accBloc.notificationPaginations!.pagination
                                            .currentPage <
                                        accBloc.notificationPaginations!
                                            .pagination.totalPages) {
                                  accBloc.add(
                                    NotificationGetEvent(
                                      pageNumber: accBloc
                                              .notificationPaginations!
                                              .pagination
                                              .currentPage +
                                          1,
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .loadMore,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (context
                                        .read<AccBloc>()
                                        .loadMoreNotification)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.white,
                                        size: 20,
                                      )
                                  ],
                                ),
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
        }),
      ),
    );
  }
}
