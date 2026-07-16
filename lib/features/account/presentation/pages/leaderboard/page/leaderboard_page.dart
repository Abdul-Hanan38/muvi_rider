import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../auth/presentation/pages/login_page.dart';

class LeaderboardPage extends StatelessWidget {
  static const String routeName = '/leaderboardPage';
  final LeaderBoardArguments? args;
  const LeaderboardPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return BlocProvider(
      create: (context) => AccBloc()..add(GetLeaderBoardEvent(type: 0)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is LeaderBoardLoadingStartState) {
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
          if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }
          if (state is LeaderBoardLoadingStopState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            final leaderBoardData = accBloc.leaderBoardData;
            final bool hasData =
                leaderBoardData != null && leaderBoardData.isNotEmpty;

            return Scaffold(
              backgroundColor: backgroundColor,
              body: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Centered Header
                    Center(
                      child: MyText(
                        text: AppLocalizations.of(context)!.leaderboard,
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Toggle Tabs (Earnings vs Trips)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161B2E)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            // Tab 1: Earnings
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (accBloc.choosenLeaderboardData != 0) {
                                    context
                                        .read<AccBloc>()
                                        .add(GetLeaderBoardEvent(type: 0));
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (accBloc.choosenLeaderboardData == 0)
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        size: 18,
                                        color:
                                            (accBloc.choosenLeaderboardData ==
                                                    0)
                                                ? Colors.white
                                                : (isDark
                                                    ? const Color(0xFF9CA3AF)
                                                    : const Color(0xFF6B7280)),
                                      ),
                                      const SizedBox(width: 8),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .earnings,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: (accBloc
                                                      .choosenLeaderboardData ==
                                                  0)
                                              ? Colors.white
                                              : (isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Tab 2: Trips
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (accBloc.choosenLeaderboardData != 1) {
                                    context
                                        .read<AccBloc>()
                                        .add(GetLeaderBoardEvent(type: 1));
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (accBloc.choosenLeaderboardData == 1)
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.redeem,
                                        size: 18,
                                        color:
                                            (accBloc.choosenLeaderboardData ==
                                                    1)
                                                ? Colors.white
                                                : (isDark
                                                    ? const Color(0xFF9CA3AF)
                                                    : const Color(0xFF6B7280)),
                                      ),
                                      const SizedBox(width: 8),
                                      MyText(
                                        text:
                                            AppLocalizations.of(context)!.trips,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: (accBloc
                                                      .choosenLeaderboardData ==
                                                  1)
                                              ? Colors.white
                                              : (isDark
                                                  ? const Color(0xFF9CA3AF)
                                                  : const Color(0xFF6B7280)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scrollable Page Content
                    Expanded(
                      child: hasData
                          ? SingleChildScrollView(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    // 1. Podium Card
                                    _buildPodiumCard(context, accBloc,
                                        leaderBoardData, isDark, cardColor),
                                    const SizedBox(height: 16),
                                    // 2. Tip Box
                                    _buildTipBox(context, isDark),
                                    const SizedBox(height: 16),
                                    // 3. Ranks 4+ List
                                    if (leaderBoardData.length > 3) ...[
                                      _buildRankingsList(context, accBloc,
                                          leaderBoardData, isDark, cardColor),
                                      const SizedBox(height: 24),
                                    ],
                                  ],
                                ),
                              ),
                            )
                          : _buildEmptyState(context, isDark),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Header Row inside the Podium Card
  Widget _buildCardHeader(BuildContext context, AccBloc accBloc, bool isDark) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1E294B) : const Color(0xFFEFF6FF),
          ),
          child: Icon(
            Icons.emoji_events_outlined,
            color: isDark ? AppColors.secondary : AppColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: (accBloc.choosenLeaderboardData == 0)
                    ? AppLocalizations.of(context)!.topEarnersText
                    : AppLocalizations.of(context)!.topTripsText,
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Builder for each podium column (Ranks 1, 2, 3)
  Widget _buildPodiumColumn(
    BuildContext context, {
    required int rank,
    required dynamic driver,
    required bool isDark,
  }) {
    final hasDriver = driver != null;
    final String name = hasDriver ? driver.driverName : "—";
    final String value = hasDriver
        ? (context.read<AccBloc>().choosenLeaderboardData == 0
            ? "${userData!.currencySymbol} ${driver.commission}"
            : "${driver.trips} ${AppLocalizations.of(context)!.trips}")
        : (context.read<AccBloc>().choosenLeaderboardData == 0
            ? "${userData!.currencySymbol} 0.00"
            : "0 ${AppLocalizations.of(context)!.trips}");

    Color crownColor;
    Color badgeColor;
    double barHeight;
    Color barBg;
    Color textValColor;

    if (rank == 1) {
      crownColor = const Color(0xFFFBBF24); // gold
      badgeColor = const Color(0xFFF59E0B);
      barHeight = 135.0;
      barBg = isDark
          ? const Color(0xFF1E294B).withOpacity(0.4)
          : const Color(0xFFEFF6FF);
      textValColor = isDark ? AppColors.secondary : AppColors.primary;
    } else if (rank == 2) {
      crownColor = const Color(0xFF9CA3AF); // silver
      badgeColor = const Color(0xFF6B7280);
      barHeight = 100.0;
      barBg = isDark
          ? const Color(0xFF2E3548).withOpacity(0.4)
          : const Color(0xFFF3F4F6);
      textValColor = isDark ? Colors.white : const Color(0xFF1F2937);
    } else {
      crownColor = const Color(0xFFD97706); // bronze
      badgeColor = const Color(0xFFB45309);
      barHeight = 85.0;
      barBg = isDark
          ? const Color(0xFF332922).withOpacity(0.4)
          : const Color(0xFFFEF3C7);
      textValColor = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown Icon
          Image.asset(
            AppImages.crown,
            width: 28,
            height: 28,
            color: crownColor,
          ),
          const SizedBox(height: 4),
          // Circular Avatar stack
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: crownColor,
                    width: 2,
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: hasDriver
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: driver.profile,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (_, __, ___) => Image.asset(
                                AppImages.defaultProfile,
                                fit: BoxFit.cover),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1F1F1F),
                          ),
                          child: const Icon(
                            Icons.question_mark_outlined,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              // Position badge overlay
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badgeColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Vertical Column bar
          Container(
            height: barHeight,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: barBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyText(
                  text: name,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                MyText(
                  text: value,
                  textStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: textValColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder for the main Podium Card
  Widget _buildPodiumCard(
    BuildContext context,
    AccBloc accBloc,
    List leaderBoardData,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF232A45) : const Color(0xFFF3F4F6),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          _buildCardHeader(context, accBloc, isDark),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPodiumColumn(context,
                  rank: 2,
                  driver:
                      (leaderBoardData.length >= 2) ? leaderBoardData[1] : null,
                  isDark: isDark),
              _buildPodiumColumn(context,
                  rank: 1,
                  driver:
                      leaderBoardData.isNotEmpty ? leaderBoardData[0] : null,
                  isDark: isDark),
              _buildPodiumColumn(context,
                  rank: 3,
                  driver:
                      (leaderBoardData.length >= 3) ? leaderBoardData[2] : null,
                  isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  // Builder for Tip Box
  Widget _buildTipBox(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16223F) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: AppLocalizations.of(context)!.keepItUpText,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                MyText(
                  text:
                      AppLocalizations.of(context)!.leaderboardCompleteMoreText,
                  textStyle: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builder for Ranks 4+ List inside a Card
  Widget _buildRankingsList(
    BuildContext context,
    AccBloc accBloc,
    List leaderBoardData,
    bool isDark,
    Color cardBg,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF232A45) : const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: leaderBoardData.length - 3,
        separatorBuilder: (context, index) => Divider(
          color: isDark ? const Color(0xFF232A45) : const Color(0xFFF3F4F6),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final i = index + 3;
          final item = leaderBoardData[i];
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank number
                SizedBox(
                  width: 24,
                  child: MyText(
                    text: '${i + 1}',
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                // Avatar image
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: item.profile,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (_, __, ___) => Image.asset(
                          AppImages.defaultProfile,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Driver Name
                Expanded(
                  child: MyText(
                    text: item.driverName,
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                // Value (Trips or Commission)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText(
                      text: (accBloc.choosenLeaderboardData == 0)
                          ? '${userData!.currencySymbol} ${item.commission}'
                          : '${item.trips} ${AppLocalizations.of(context)!.trips}',
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      text:
                          '${item.totalRides} ${AppLocalizations.of(context)!.rides}',
                      textStyle: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Builder for Leaderboard Empty State
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.leaderBoardEmpty,
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        MyText(
          text: AppLocalizations.of(context)!.noDataLeaderBoard,
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        MyText(
          text: AppLocalizations.of(context)!.addRankingText,
          textStyle: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
