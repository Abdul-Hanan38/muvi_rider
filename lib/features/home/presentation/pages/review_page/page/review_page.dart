import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/home_bloc.dart';
import '../../home_page/page/home_page.dart';

import 'package:flutter/cupertino.dart';

class ReviewPage extends StatefulWidget {
  static const String routeName = '/reviewPage';
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  @override
  void initState() {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.add(ReviewPageInitEvent());
    homeBloc.reviewController.addListener(_onTextChanged);
    super.initState();
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    final homeBloc = context.read<HomeBloc>();
    homeBloc.reviewController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeBloc = context.read<HomeBloc>();

    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9);

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) async {
        if (state is AddReviewSuccessState) {
          Navigator.pushNamedAndRemoveUntil(
              context, HomePage.routeName, (route) => false);
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: scaffoldBgColor,
            appBar: AppBar(
              backgroundColor: scaffoldBgColor,
              elevation: 0,
              centerTitle: true,
              title: MyText(
                text: AppLocalizations.of(context)!.ratings,
                textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      // Card 1: Last Ride Info Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cardBorderColor,
                            width: 1.0,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Star Badge Icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.primary.withOpacity(0.15)
                                    : const Color(0xFFEFF6FF),
                              ),
                              child: Icon(
                                Icons.star_rounded,
                                color: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // How was your last ride Title
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .howWasYourLastRide
                                  .toString()
                                  .replaceAll('1111',
                                      userData!.onTripRequest!.userName),
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Request ID Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primary.withOpacity(0.15)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: MyText(
                                text: userData!.onTripRequest!.requestNumber,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Driver Profile Row
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? const Color(0xFF312E81)
                                        : const Color(0xFFE8DBFF),
                                  ),
                                  child: (userData!
                                          .onTripRequest!.userImage.isEmpty)
                                      ? Icon(
                                          Icons.person,
                                          size: 32,
                                          color: isDark
                                              ? const Color(0xFFC084FC)
                                              : const Color(0xFF7C3AED),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(26),
                                          child: CachedNetworkImage(
                                            imageUrl: userData!
                                                .onTripRequest!.userImage,
                                            height: 52,
                                            width: 52,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: Loader(),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.person,
                                              size: 32,
                                              color: isDark
                                                  ? const Color(0xFFC084FC)
                                                  : const Color(0xFF7C3AED),
                                            ),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),

                                // Name + Verified Role
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: MyText(
                                              text: userData!
                                                  .onTripRequest!.userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : const Color(0xFF0F172A),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.verified_rounded,
                                            size: 16,
                                            color: Color(0xFF10B981),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .verified
                                            .replaceAll(
                                                '111',
                                                AppLocalizations.of(context)!
                                                    .user),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Give Ratings title section
                      MyText(
                        text: AppLocalizations.of(context)!.giveRatings,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: AppLocalizations.of(context)!.reviewTapStarToRate,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating Star Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) {
                            final selectedIndex = homeBloc.selectedRatingsIndex;
                            final isSelected = index + 1 <= selectedIndex &&
                                selectedIndex != 0;

                            return InkWell(
                              onTap: () {
                                homeBloc.add(
                                  BookingRatingsSelectEvent(
                                    selectedIndex: index + 1,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  isSelected
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: isSelected
                                      ? const Color(0xFFFFB000)
                                      : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFCBD5E1)),
                                  size: 42,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card 2: Feedback text input field Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cardBorderColor,
                            width: 1.0,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Leave Feedback Title Header Row
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_rounded,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .leaveFeedbackText,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // TextField Container
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF0F1322)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF2D3748)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextField(
                                    controller: homeBloc.reviewController,
                                    maxLines: 4,
                                    maxLength: 500,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .leaveFeedback,
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF475569)
                                            : const Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      counterText: '',
                                    ),
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${homeBloc.reviewController.text.length}/500",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? const Color(0xFF475569)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button (Pill Capsule)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          homeBloc.driverTips = 0.0;
                          if (homeBloc.selectedRatingsIndex > 0) {
                            homeBloc.add(UploadReviewEvent());
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .giveRatingsError);
                          }
                        },
                        child: Container(
                          width: size.width,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary
                                    .withOpacity(isDark ? 0.35 : 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.submit,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
