import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:restart_tagxi/common/app_constants.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_button.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../auth/application/auth_bloc.dart';
import '../../../../application/acc_bloc.dart';

class ReferralPage extends StatefulWidget {
  final ReferralArguments args;

  static const String routeName = '/ReferralPage';

  const ReferralPage({super.key, required this.args});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  String _formatStatus(String status) {
    if (status.isEmpty) return '';
    final normalized = status.toLowerCase();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  List<TextSpan> _getHighlightedSpans(String text, bool isDark) {
    // Matches 'earn ₹60', 'earn $60', 'earn 60', '₹60', '$60', etc.
    final regex = RegExp(r'(earn\s*[₹$\d\w]+|[₹$\d\w]+)', caseSensitive: false);
    final matches = regex.allMatches(text);
    if (matches.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        )
      ];
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: TextStyle(
          color: isDark ? const Color(0xFFFFC529) : const Color(0xFF001CAD),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ));
      lastIndex = match.end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ));
    }
    return spans;
  }

  List<Map<String, String>> _parseReferralSteps(String htmlContent) {
    final steps = <Map<String, String>>[];
    // Find all <li> elements
    final liRegex =
        RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true, caseSensitive: false);
    final matches = liRegex.allMatches(htmlContent);

    for (final match in matches) {
      final rawContent = match.group(1) ?? "";

      // Extract title from <strong> or <b>
      final titleRegex = RegExp(
          r'<strong[^>]*>(.*?)</strong>|<b[^>]*>(.*?)</b>',
          dotAll: true,
          caseSensitive: false);
      final titleMatch = titleRegex.firstMatch(rawContent);

      String title = "";
      String desc = "";

      if (titleMatch != null) {
        title = (titleMatch.group(1) ?? titleMatch.group(2) ?? "").trim();
        desc = rawContent.replaceAll(titleRegex, "").trim();
      } else {
        // If no strong/b tag, check if there's a break tag
        final parts =
            rawContent.split(RegExp(r'<br\s*/?>', caseSensitive: false));
        if (parts.isNotEmpty) {
          title = parts.first.trim();
          desc = parts.sublist(1).join(" ").trim();
        } else {
          title = rawContent.trim();
        }
      }

      // Clean HTML tags from title and desc
      title = _stripHtml(title);
      desc = _stripHtml(desc);

      if (title.isNotEmpty) {
        steps.add({
          "title": title,
          "description": desc,
        });
      }
    }

    // Fallback for paragraph elements if list is empty
    if (steps.isEmpty) {
      final pRegex =
          RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true, caseSensitive: false);
      final pMatches = pRegex.allMatches(htmlContent);
      for (final match in pMatches) {
        final rawContent = match.group(1) ?? "";
        final titleRegex = RegExp(
            r'<strong[^>]*>(.*?)</strong>|<b[^>]*>(.*?)</b>',
            dotAll: true,
            caseSensitive: false);
        final titleMatch = titleRegex.firstMatch(rawContent);
        String title = "";
        String desc = "";
        if (titleMatch != null) {
          title = (titleMatch.group(1) ?? titleMatch.group(2) ?? "").trim();
          desc = rawContent.replaceAll(titleRegex, "").trim();
        } else {
          title = rawContent.trim();
        }
        title = _stripHtml(title);
        desc = _stripHtml(desc);
        if (title.isNotEmpty) {
          title = title.replaceFirst(RegExp(r'^\d+[\.\s\-:]+'), '');
          steps.add({
            "title": title,
            "description": desc,
          });
        }
      }
    }

    return steps;
  }

  String _stripHtml(String htmlString) {
    String clean =
        htmlString.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    clean = clean.replaceAll(RegExp(r'<[^>]*>'), '');
    clean = clean
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return clean.trim();
  }

  Widget _buildStepItem({
    required int index,
    required String title,
    required String description,
    required bool isLast,
    required bool isDark,
  }) {
    Color iconBg;
    Color iconColor;
    IconData iconData;
    double rotation = 0.0;

    if (index == 0) {
      iconBg = isDark
          ? const Color(0xFF001CAD).withOpacity(0.3)
          : const Color(0xFFE8F1FF);
      iconColor = const Color(0xFF001CAD);
      iconData = Icons.send_rounded;
      rotation = -0.5;
    } else if (index == 1) {
      iconBg = isDark
          ? const Color(0xFF10B981).withOpacity(0.3)
          : const Color(0xFFE2F7EB);
      iconColor = const Color(0xFF10B981);
      iconData = Icons.file_download_outlined;
    } else {
      iconBg = isDark
          ? const Color(0xFFF59E0B).withOpacity(0.3)
          : const Color(0xFFFFF3E0);
      iconColor = const Color(0xFFF59E0B);
      iconData = Icons.card_giftcard_rounded;
    }

    final displayTitle =
        title.startsWith(RegExp(r'^\d+')) ? title : "${index + 1}. $title";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: rotation != 0.0
                      ? Transform.rotate(
                          angle: rotation,
                          child: Icon(iconData, color: iconColor, size: 20),
                        )
                      : Icon(iconData, color: iconColor, size: 20),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: CustomPaint(
                    size: const Size(1.5, double.infinity),
                    painter: DashedLinePainter(
                      color: isDark
                          ? const Color(0xFF2A3F64)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: displayTitle,
                    textStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  MyText(
                    text: description,
                    maxLines: 4,
                    textStyle: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);

    return BlocProvider(
      create: (context) {
        final bloc = AccBloc();
        bloc.add(AccGetDirectionEvent());
        bloc.add(ReferralResponseEvent());
        return bloc;
      },
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final bloc = context.watch<AccBloc>();
            return Directionality(
              textDirection: bloc.textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: backgroundColor,
                appBar: CustomAppBar(
                  title: widget.args.title,
                  automaticallyImplyLeading: true,
                  backgroundColor: backgroundColor,
                  textColor: textDarkColor,
                  leadingColor: textDarkColor,
                  titleFontSize: 18,
                  showBorder: false,
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              // Gradient Banner Card
                              Container(
                                height: 125,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: isDark
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF38146D),
                                            Color(0xFF0F1B4E)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFEBF3FF),
                                            Color(0xFFF6FAFF)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  boxShadow: [
                                    if (!isDark)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding:
                                            EdgeInsets.all(size.width * 0.045),
                                        child: RichText(
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            children: _getHighlightedSpans(
                                              widget.args.userData
                                                  .referralComissionString,
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                        child: Image.asset(
                                          AppImages.referralGenius,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Referral Code Card
                              Container(
                                padding: EdgeInsets.all(size.width * 0.045),
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
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF070D19)
                                                  : const Color(0xFFEDF2FE),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: DottedBorder(
                                              color: isDark
                                                  ? const Color(0xFF2A3F64)
                                                  : const Color(0xFF8BA5F3),
                                              strokeWidth: 1.2,
                                              dashPattern: const [6, 3],
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(8),
                                              child: Center(
                                                child: MyText(
                                                  text: widget.args.userData
                                                      .refferalCode,
                                                  textStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.2,
                                                    color: isDark
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .yourReferralCode,
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF64748B)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: widget
                                                .args.userData.refferalCode));
                                        context.showSnackBar(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          message: AppLocalizations.of(context)!
                                              .referralCopied,
                                        );
                                      },
                                      child: Container(
                                        height: 48,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.secondary
                                              : AppColors.primary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.copy_rounded,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                            const SizedBox(width: 6),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .copy,
                                              textStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Tab Selector Pills
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF131E35)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          context.read<AccBloc>().add(
                                              ReferralTabChangeEvent(
                                                  showReferralHistory: false));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !bloc.showReferralHistory
                                                ? (isDark
                                                    ? const Color(0xFF070D19)
                                                    : Colors.white)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              if (!bloc.showReferralHistory &&
                                                  !isDark)
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.group_rounded,
                                                size: 16,
                                                color: !bloc.showReferralHistory
                                                    ? (isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary)
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF64748B)
                                                        : const Color(
                                                            0xFF64748B)),
                                              ),
                                              const SizedBox(width: 6),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .referAndEarn,
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: !bloc
                                                          .showReferralHistory
                                                      ? (isDark
                                                          ? AppColors.secondary
                                                          : AppColors.primary)
                                                      : (isDark
                                                          ? const Color(
                                                              0xFF64748B)
                                                          : const Color(
                                                              0xFF64748B)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          context.read<AccBloc>().add(
                                              ReferralTabChangeEvent(
                                                  showReferralHistory: true));
                                          context
                                              .read<AccBloc>()
                                              .add(ReferalHistoryEvent());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: bloc.showReferralHistory
                                                ? (isDark
                                                    ? const Color(0xFF070D19)
                                                    : Colors.white)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              if (bloc.showReferralHistory &&
                                                  !isDark)
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                size: 16,
                                                color: bloc.showReferralHistory
                                                    ? (isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary)
                                                    : (isDark
                                                        ? const Color(
                                                            0xFF64748B)
                                                        : const Color(
                                                            0xFF64748B)),
                                              ),
                                              const SizedBox(width: 6),
                                              MyText(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .referralHistory,
                                                textStyle: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: bloc
                                                          .showReferralHistory
                                                      ? (isDark
                                                          ? AppColors.secondary
                                                          : AppColors.primary)
                                                      : (isDark
                                                          ? const Color(
                                                              0xFF64748B)
                                                          : const Color(
                                                              0xFF64748B)),
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
                              const SizedBox(height: 20),

                              // Dynamic Tab Body Content
                              Builder(
                                builder: (context) {
                                  if (bloc.showReferralHistory) {
                                    if (state is ReferalHistoryLoadingState) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 40),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }

                                    if (state is ReferalHistorySuccessState) {
                                      final historyList = bloc.referralHistory;

                                      if (historyList.isNotEmpty) {
                                        return ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: historyList.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            final item = historyList[index];
                                            return Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: cardColor,
                                                border: Border.all(
                                                  width: 1,
                                                  color: isDark
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFFE2E8F0),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  if (!isDark)
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.01),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      MyText(
                                                        text: item.name,
                                                        textStyle: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDark
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF1E293B),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      MyText(
                                                        text: item.createdAt
                                                            .split(' ')
                                                            .first,
                                                        textStyle: TextStyle(
                                                          fontSize: 12,
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF64748B)
                                                              : const Color(
                                                                  0xFF64748B),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            AppImages.referGift,
                                                            height: 18,
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          MyText(
                                                            text:
                                                                '${item.currencySymbol}${item.earning}',
                                                            textStyle:
                                                                TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: isDark
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFF1E293B),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isDark
                                                              ? const Color(
                                                                  0xFF1E293B)
                                                              : const Color(
                                                                  0xFFF1F5F9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: MyText(
                                                          text: _formatStatus(item
                                                              .referralStatus),
                                                          textStyle: TextStyle(
                                                            fontSize: 11,
                                                            color: isDark
                                                                ? const Color(
                                                                    0xFFCBD5E1)
                                                                : const Color(
                                                                    0xFF475569),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.referal,
                                            height: 160,
                                          ),
                                          const SizedBox(height: 16),
                                          Center(
                                            child: MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .noReferralHistoryFound,
                                              textStyle: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (state is ReferralResponseLoadingState) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }

                                  final referralResponse =
                                      bloc.referralResponse;
                                  if (referralResponse == null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 40),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImages.referal,
                                            height: 160,
                                          ),
                                          const SizedBox(height: 16),
                                          Center(
                                            child: MyText(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .referralContentUnavailableText,
                                              textStyle: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? const Color(0xFF64748B)
                                                    : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final referralHtml = referralResponse
                                      .data.referralContent.data.description;
                                  final steps =
                                      _parseReferralSteps(referralHtml);

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .howItWorks,
                                        textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (steps.isNotEmpty)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: steps.length,
                                          itemBuilder: (context, index) {
                                            final step = steps[index];
                                            return _buildStepItem(
                                              index: index,
                                              title: step["title"] ?? "",
                                              description:
                                                  step["description"] ?? "",
                                              isLast: index == steps.length - 1,
                                              isDark: isDark,
                                            );
                                          },
                                        )
                                      else
                                        Html(
                                          data: referralHtml,
                                          style: {
                                            "body": Style(
                                              fontSize: FontSize(14),
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B),
                                            ),
                                            "strong": Style(
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1E293B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                            "ol": Style(
                                              listStyleType:
                                                  ListStyleType.decimal,
                                              margin: Margins.only(left: 16),
                                            ),
                                            "li": Style(
                                              margin: Margins.only(bottom: 8),
                                            ),
                                          },
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          size.width * 0.05,
                          12,
                          size.width * 0.05,
                          16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomButton(
                              buttonColor: AppColors.buttonColor,
                              buttonName: AppLocalizations.of(context)!.invite,
                              width: size.width,
                              height: 52,
                              borderRadius: 12,
                              textSize: 16,
                              leading: const Icon(
                                Icons.share_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              onTap: () async {
                                String androidUrl =
                                    widget.args.userData.androidApp;
                                String iosUrl = widget.args.userData.iosApp;

                                if (!context.mounted) return;
                                await Share.share(
                                    "${AppLocalizations.of(context)!.referalShareOne.replaceAll('222', widget.args.userData.refferalCode).replaceAll('111', AppConstants.title)}\n$androidUrl \n$iosUrl");
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isDark)
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC529),
                                    size: 14,
                                  ),
                                const SizedBox(width: 4),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .moreFriendsMoreRewards,
                                  textStyle: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.secondary
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                if (isDark)
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC529),
                                    size: 14,
                                  ),
                              ],
                            ),
                          ],
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

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double y = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dashHeight), paint);
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
