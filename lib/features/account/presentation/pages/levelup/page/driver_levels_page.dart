import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/levelup/widget/level_grid_shimmer.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:restart_tagxi/features/account/domain/models/driver_level_models.dart';

import '../../../../../auth/presentation/pages/login_page.dart';

class DriverLevelsPage extends StatelessWidget {
  static const String routeName = '/driverLevelsPage';

  const DriverLevelsPage({super.key});

  String _getRideRange(int index, List<DriverLevelsData> list) {
    if (index >= list.length) return '';
    final current = list[index];
    if (index == list.length - 1) {
      return "${current.minRideCount}+ rides";
    }
    final next = list[index + 1];
    return "${current.minRideCount} - ${next.minRideCount - 1} rides";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(DriverLevelnitEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
          if (state is DriverLevelPopupState) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (builder) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final cardBgColor =
                      isDark ? const Color(0xFF131C2E) : Colors.white;
                  final cardBorderColor = isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9);
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    insetPadding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cardBorderColor, width: 1),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MyText(
                                text: state.driverLevelList.data.createdAt,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(
                                AppImages.successLevelPopup,
                                height: 160,
                                width: 160,
                                fit: BoxFit.contain,
                              ),
                              Image.network(
                                state.driverLevelList.data.levelIcon,
                                height: 86,
                                width: 86,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                  height: 86,
                                  width: 86,
                                  child: Icon(Icons.star_rounded,
                                      size: 48, color: Color(0xFFD97706)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MyText(
                            text:
                                "${state.driverLevelList.data.levelName} ${state.driverLevelList.data.level}",
                            textStyle: const TextStyle(
                                fontSize: 22,
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.star_rounded,
                                  color:
                                      const Color(0xFFD97706).withOpacity(0.5),
                                  size: 14,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFE2E8F0),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .levelupSuccessText
                                .replaceAll(
                                    "1", "${state.driverLevelList.data.level}")
                                .replaceAll(
                                    "25", state.driverLevelList.data.totalRides)
                                .replaceAll("500",
                                    state.driverLevelList.data.totalEarnings),
                            textStyle: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            borderRadius: 30,
                            width: double.infinity,
                            height: 48,
                            textSize: 16,
                            buttonName: AppLocalizations.of(context)!.ok,
                            buttonColor: AppColors.primary,
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      ),
                    ),
                  );
                });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final backgroundColor =
                isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
            final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
            final textDarkColor =
                isDark ? Colors.white : const Color(0xFF1F2937);

            final bloc = context.watch<AccBloc>();
            final list = bloc.driverLevelsList;

            DriverLevelsData? currentLevel;
            DriverLevelsData? nextLevel;

            // Find current and next levels
            for (var lvl in list) {
              if (lvl.levelCompleted == '1') {
                currentLevel = lvl;
              }
            }

            if (currentLevel != null) {
              final currentIndex = list.indexOf(currentLevel);
              if (currentIndex != -1 && currentIndex + 1 < list.length) {
                nextLevel = list[currentIndex + 1];
              }
            } else if (list.isNotEmpty) {
              nextLevel = list.first;
            }

            final activeLevel =
                currentLevel ?? (list.isNotEmpty ? list.first : null);

            // Fetch progress info if level details is populated
            String? totalRidesStr;
            for (var lvl in list) {
              if (lvl.levelDetails != null) {
                totalRidesStr = lvl.levelDetails!.data.totalRides;
                break;
              }
            }
            final int currentRides = int.tryParse(totalRidesStr ?? '0') ?? 0;
            final int nextLevelMinRide =
                nextLevel?.minRideCount ?? activeLevel?.minRideCount ?? 1;
            final double progress = nextLevelMinRide > 0
                ? (currentRides / nextLevelMinRide).clamp(0.0, 1.0)
                : 0.0;
            int ridesNeeded = nextLevelMinRide - currentRides;
            if (ridesNeeded < 0) ridesNeeded = 0;

            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.levelupText,
                automaticallyImplyLeading: true,
                backgroundColor: backgroundColor,
                textColor: textDarkColor,
                leadingColor: textDarkColor,
                showBorder: false,
              ),
              body: SizedBox(
                height: size.height,
                child: (bloc.isLoading &&
                        bloc.firstLoadLevel &&
                        !bloc.loadMoreLevel)
                    ? const LevelsGridShimmer()
                    : list.isNotEmpty
                        ? SingleChildScrollView(
                            controller: bloc.levelsScrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),

                                // Current Level Card
                                if (activeLevel != null)
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 1,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                      boxShadow: [
                                        if (!isDark)
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // Level Icon Badge
                                        Image.network(
                                          activeLevel.levelIcon,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.stars_rounded,
                                            color: Colors.amber,
                                            size: 72,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .currentLevelText,
                                                textStyle: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                  color: isDark
                                                      ? const Color(0xFF64748B)
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: MyText(
                                                      text:
                                                          "${activeLevel.levelName} ${activeLevel.level}",
                                                      textStyle: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: textDarkColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Icon(
                                                    Icons.verified_rounded,
                                                    size: 18,
                                                    color: isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .levelUpPageRewardsText,
                                                textStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                // Progress Card
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .yourProgressText,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      width: 1,
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text: nextLevel != null
                                                  ? AppLocalizations.of(
                                                          context)!
                                                      .completeMoreRideToReachText
                                                      .replaceAll(
                                                          '111',
                                                          ridesNeeded
                                                              .toString()
                                                              .replaceAll(
                                                                  '222',
                                                                  nextLevel
                                                                      .levelName
                                                                      .toString())
                                                              .replaceAll(
                                                                  '333',
                                                                  nextLevel
                                                                      .level
                                                                      .toString()))
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .reachedMaxLevelText,
                                              textStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textDarkColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 8,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: const Color(0xFFF59E0B),
                                              backgroundColor: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFE2E8F0),
                                            ),
                                            const SizedBox(height: 8),
                                            MyText(
                                              text: nextLevel != null
                                                  ? "$currentRides / $nextLevelMinRide rides"
                                                  : AppLocalizations.of(
                                                          context)!
                                                      .ridesCompletedCountText
                                                      .replaceAll(
                                                          '111',
                                                          currentRides
                                                              .toString()),
                                              textStyle: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFF94A3B8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (nextLevel != null) ...[
                                        const SizedBox(width: 16),
                                        Image.network(
                                          nextLevel.levelIcon,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.stars_rounded,
                                            color: Colors.amber,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Level Benefits
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .levelBenefitsText,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...List.generate(3, (index) {
                                  String benefitTitle = "";
                                  String benefitDesc = "";
                                  Color circleBg;
                                  Color iconColor;
                                  IconData iconData;

                                  if (index == 0) {
                                    benefitTitle = AppLocalizations.of(context)!
                                        .prioritySupportText;
                                    benefitDesc = AppLocalizations.of(context)!
                                        .getFasterSupportHelpText;
                                    circleBg = isDark
                                        ? const Color(0xFF10B981)
                                            .withOpacity(0.2)
                                        : const Color(0xFFE2F7EB);
                                    iconColor = const Color(0xFF10B981);
                                    iconData = Icons.card_giftcard_rounded;
                                  } else if (index == 1) {
                                    benefitTitle = AppLocalizations.of(context)!
                                        .bonusEarningsText;
                                    benefitDesc = AppLocalizations.of(context)!
                                        .earnExtraEligibleRideText;
                                    circleBg = isDark
                                        ? const Color(0xFF3F51B5)
                                            .withOpacity(0.2)
                                        : const Color(0xFFEDF2FE);
                                    iconColor = const Color(0xFF3F51B5);
                                    iconData = Icons.percent_rounded;
                                  } else {
                                    benefitTitle = AppLocalizations.of(context)!
                                        .exclusiveRewardsText;
                                    benefitDesc = AppLocalizations.of(context)!
                                        .accessSpecialrewardsAndOffersText;
                                    circleBg = isDark
                                        ? const Color(0xFFF59E0B)
                                            .withOpacity(0.2)
                                        : const Color(0xFFFFF3E0);
                                    iconColor = const Color(0xFFF59E0B);
                                    iconData = Icons.star_rounded;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        width: 1,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: circleBg,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(iconData,
                                              color: iconColor, size: 20),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                text: benefitTitle,
                                                textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: textDarkColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              MyText(
                                                text: benefitDesc,
                                                textStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? const Color(0xFF94A3B8)
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: 24),

                                // All Levels Timeline
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .allLevelsText,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Positioned(
                                              left: 40,
                                              top: 25,
                                              child: Row(
                                                children: List.generate(
                                                    list.length - 1, (index) {
                                                  final isLineCompleted =
                                                      list[index + 1]
                                                              .levelCompleted ==
                                                          '1';
                                                  return Container(
                                                    width: 80,
                                                    height: 2,
                                                    color: isLineCompleted
                                                        ? (isDark
                                                            ? AppColors
                                                                .secondary
                                                            : AppColors.primary)
                                                        : (isDark
                                                            ? const Color(
                                                                0xFF1E293B)
                                                            : const Color(
                                                                0xFFE2E8F0)),
                                                  );
                                                }),
                                              ),
                                            ),
                                            Row(
                                              children: List.generate(
                                                  list.length, (index) {
                                                final item = list[index];
                                                final isCompleted =
                                                    item.levelCompleted == '1';
                                                final isCurrent =
                                                    currentLevel == item;

                                                return InkWell(
                                                  onTap: isCompleted
                                                      ? () {
                                                          context
                                                              .read<AccBloc>()
                                                              .add(DriverLevelPopupEvent(
                                                                  driverLevelList:
                                                                      item.levelDetails!));
                                                        }
                                                      : null,
                                                  child: SizedBox(
                                                    width: 80,
                                                    height: 50,
                                                    child: Center(
                                                      child: Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: isCurrent
                                                              ? Border.all(
                                                                  color: isDark
                                                                      ? AppColors
                                                                          .secondary
                                                                      : AppColors
                                                                          .primary,
                                                                  width: 2,
                                                                )
                                                              : null,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: CircleAvatar(
                                                          backgroundColor: isCompleted
                                                              ? (isDark
                                                                  ? const Color(
                                                                      0xFF1E293B)
                                                                  : const Color(
                                                                      0xFFF1F5F9))
                                                              : (isDark
                                                                  ? const Color(
                                                                      0xFF070D19)
                                                                  : const Color(
                                                                      0xFFE2E8F0)),
                                                          child: ClipOval(
                                                            child:
                                                                Image.network(
                                                              item.levelIcon,
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit
                                                                  .contain,
                                                              errorBuilder:
                                                                  (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Icon(
                                                                Icons
                                                                    .star_rounded,
                                                                color: isCompleted
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .grey,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: List.generate(list.length,
                                              (index) {
                                            final item = list[index];
                                            final isCompleted =
                                                item.levelCompleted == '1';
                                            final isCurrent =
                                                currentLevel == item;

                                            return SizedBox(
                                              width: 80,
                                              child: Column(
                                                children: [
                                                  MyText(
                                                    text: item.levelName,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    textStyle: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: isCurrent
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                      color: isCurrent
                                                          ? (isDark
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF0F172A))
                                                          : (isCompleted
                                                              ? (isDark
                                                                  ? const Color(
                                                                      0xFF94A3B8)
                                                                  : const Color(
                                                                      0xFF475569))
                                                              : (isDark
                                                                  ? const Color(
                                                                      0xFF64748B)
                                                                  : const Color(
                                                                      0xFF94A3B8))),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  MyText(
                                                    text: _getRideRange(
                                                        index, list),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    textStyle: TextStyle(
                                                      fontSize: 9,
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF64748B)
                                                          : const Color(
                                                              0xFF94A3B8),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (bloc.loadMoreLevel &&
                                    !bloc.isLoading &&
                                    !bloc.firstLoadLevel)
                                  const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: size.width * 0.20,
                                  width: size.width * 0.20,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(9.0),
                                        child: Image(
                                          height: size.width * 0.20,
                                          width: size.width * 0.20,
                                          image: const AssetImage(
                                              AppImages.levelLocked),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: size.width * 0.054,
                                              top: size.height * 0.031),
                                          child: Image(
                                              height: size.width * 0.10,
                                              image: const AssetImage(
                                                  AppImages.lock)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .noLevelsFoundText,
                                  textStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF64748B)
                                        : const Color(0xFF64748B),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            );
          },
        ),
      ),
    );
  }
}
