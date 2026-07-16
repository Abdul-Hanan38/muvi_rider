import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../common/app_colors.dart';

class CancelReasonWidget extends StatefulWidget {
  final BuildContext cont;
  const CancelReasonWidget({super.key, required this.cont});

  @override
  State<CancelReasonWidget> createState() => _CancelReasonWidgetState();
}

class _CancelReasonWidgetState extends State<CancelReasonWidget> {
  @override
  void initState() {
    super.initState();
    final homeBloc = widget.cont.read<HomeBloc>();
    homeBloc.cancelReasonText.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    final homeBloc = widget.cont.read<HomeBloc>();
    homeBloc.cancelReasonText.removeListener(_onTextChanged);
    super.dispose();
  }

  IconData _getReasonIcon(String reason) {
    final lowercase = reason.toLowerCase();
    if (lowercase.contains('long') ||
        lowercase.contains('time') ||
        lowercase.contains('late')) {
      return Icons.access_time_outlined;
    }
    if (lowercase.contains('do not') ||
        lowercase.contains('want') ||
        lowercase.contains('private')) {
      return Icons.visibility_off_outlined;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final homeBloc = widget.cont.read<HomeBloc>();

    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9);

    return BlocProvider.value(
      value: homeBloc,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final isDelivery = userData?.onTripRequest != null &&
              userData!.onTripRequest!.transportType == 'delivery';

          return SizedBox(
            width: size.width,
            height: size.height,
            child: Scaffold(
              backgroundColor: scaffoldBgColor,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: scaffoldBgColor,
                elevation: 0,
                centerTitle: true,
                title: MyText(
                  text: AppLocalizations.of(context)!.onrideCancelReasonText,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    homeBloc.add(HideCancelReasonEvent());
                  },
                ),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),

                              // Info Alert Banner Row
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1A2238)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF232A45)
                                        : const Color(0xFFDBEAFE),
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 28,
                                      width: 28,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .selectReasonForCancel,
                                        textStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Cancel Reasons Cards List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: homeBloc.cancelReasons.length,
                                itemBuilder: (context, i) {
                                  final reasonItem = homeBloc.cancelReasons[i];
                                  final isSelected =
                                      homeBloc.choosenCancelReason == i;

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 12.0),
                                    child: InkWell(
                                      onTap: () {
                                        homeBloc.add(ChooseCancelReasonEvent(
                                            choosen: i));
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cardBgColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : cardBorderColor,
                                            width: isSelected ? 1.5 : 1.0,
                                          ),
                                          boxShadow: isDark
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.02),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 14),
                                        child: Row(
                                          children: [
                                            // Circular Icon Container
                                            Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDark
                                                    ? const Color(0xFF1E293B)
                                                    : const Color(0xFFEFF6FF),
                                              ),
                                              child: Icon(
                                                _getReasonIcon(
                                                    reasonItem.reason),
                                                color: AppColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: MyText(
                                                text: reasonItem.reason,
                                                textStyle: TextStyle(
                                                  color: isDark
                                                      ? Colors.white
                                                      : const Color(0xFF1E293B),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Checkbox box
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : (isDark
                                                          ? Colors.white30
                                                          : Colors.black26),
                                                  width: 1.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),

                              // Other Reason (Optional) label
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .onrideOtherReasonOptionalText,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Text Area Container with counter
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: cardBorderColor,
                                    width: 1.0,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    TextField(
                                      controller: homeBloc.cancelReasonText,
                                      maxLines: 4,
                                      maxLength: 250,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!
                                            .onrideOtherReasonOptionalSubText,
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        counterText: '',
                                      ),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                        fontSize: 14,
                                      ),
                                      onChanged: (text) {
                                        if (homeBloc.choosenCancelReason !=
                                            null) {
                                          homeBloc.add(ChooseCancelReasonEvent(
                                              choosen: null));
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "${homeBloc.cancelReasonText.text.length}/250",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Cancel Ride Capsule Action Button pinned at the bottom (outside ScrollView)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: CustomButton(
                        width: size.width,
                        height: 52,
                        borderRadius: 30,
                        leading: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        buttonName: isDelivery
                            ? AppLocalizations.of(context)!
                                .onrideCancelDeliveryText
                            : AppLocalizations.of(context)!
                                .onrideCancelRideText,
                        textSize: 18,
                        onTap: () {
                          if (homeBloc.cancelReasonText.text.isNotEmpty ||
                              homeBloc.choosenCancelReason != null) {
                            homeBloc.add(CancelRequestEvent());
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .selectCancelReasonError);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
