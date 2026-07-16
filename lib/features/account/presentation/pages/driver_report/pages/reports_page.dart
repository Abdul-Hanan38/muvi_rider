import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/invoice_page/widget/fare_breakdown_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../core/model/user_detail_model.dart';

class ReportsPage extends StatelessWidget {
  static const String routeName = '/reportsPage';
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBg = isDark ? const Color(0xFF0D1527) : Colors.white;
    final cardBg = isDark ? const Color(0xFF131E35) : const Color(0xFFF8FAFC);
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final textMutedColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;
    final accentBlue =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);

    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is ReportLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is ReportSubmitState) {
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            return SafeArea(
              child: Scaffold(
                backgroundColor: scaffoldBg,
                appBar: CustomAppBar(
                  title: AppLocalizations.of(context)!.reportsText,
                  automaticallyImplyLeading: true,
                  titleFontSize: 18,
                  showBorder: false,
                  backgroundColor: scaffoldBg,
                  textColor: textDarkColor,
                  leadingColor: textDarkColor,
                ),
                body: Container(
                  width: size.width,
                  height: size.height,
                  color: scaffoldBg,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .generateReport,
                                      textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textDarkColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .reportsLableText,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        color: textMutedColor,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: accentBlue,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : primaryColor,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // From Label
                          MyText(
                            text: AppLocalizations.of(context)!.from,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // From Field Selector
                          InkWell(
                            onTap: () {
                              context.read<AccBloc>().add(ChooseDateEvent(
                                  context: context, isFromDate: true));
                            },
                            child: Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B).withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : AppColors.borderColors,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ValueListenableBuilder<
                                        TextEditingValue>(
                                      valueListenable:
                                          context.read<AccBloc>().fromDateText,
                                      builder: (context, value, child) {
                                        final text = value.text.isNotEmpty
                                            ? value.text
                                            : 'dd-mm-yyyy';
                                        final isPlaceholder =
                                            value.text.isEmpty;
                                        return MyText(
                                          text: text,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: isPlaceholder
                                                ? textMutedColor
                                                    .withOpacity(0.6)
                                                : textDarkColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: textMutedColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // To Label
                          MyText(
                            text: AppLocalizations.of(context)!.to,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // To Field Selector
                          InkWell(
                            onTap: () {
                              context.read<AccBloc>().add(ChooseDateEvent(
                                  context: context, isFromDate: false));
                            },
                            child: Container(
                              height: 56,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B).withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : AppColors.borderColors,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ValueListenableBuilder<
                                        TextEditingValue>(
                                      valueListenable:
                                          context.read<AccBloc>().toDateText,
                                      builder: (context, value, child) {
                                        final text = value.text.isNotEmpty
                                            ? value.text
                                            : 'dd-mm-yyyy';
                                        final isPlaceholder =
                                            value.text.isEmpty;
                                        return MyText(
                                          text: text,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: isPlaceholder
                                                ? textMutedColor
                                                    .withOpacity(0.6)
                                                : textDarkColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: textMutedColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  width: double.infinity,
                                  height: 52,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : primaryColor.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  borderRadius: 12,
                                  buttonColor: Colors.transparent,
                                  textColor: isDark
                                      ? const Color(0xFF38BDF8)
                                      : primaryColor,
                                  buttonName:
                                      AppLocalizations.of(context)!.clear,
                                  textSize: 16,
                                  leading: Icon(
                                    Icons.sync_rounded,
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : primaryColor,
                                    size: 18,
                                  ),
                                  onTap: () {
                                    context
                                        .read<AccBloc>()
                                        .add(ReportClearEvent());
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  width: double.infinity,
                                  height: 52,
                                  borderRadius: 12,
                                  buttonColor: primaryColor,
                                  textColor: Colors.white,
                                  buttonName:
                                      AppLocalizations.of(context)!.filter,
                                  textSize: 16,
                                  leading: const Icon(
                                    Icons.filter_alt_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onTap: () {
                                    if (context
                                            .read<AccBloc>()
                                            .fromDateText
                                            .text
                                            .isNotEmpty &&
                                        context
                                            .read<AccBloc>()
                                            .toDateText
                                            .text
                                            .isNotEmpty) {
                                      context.read<AccBloc>().add(
                                            ReportSubmitEvent(
                                              fromDate: context
                                                  .read<AccBloc>()
                                                  .fromDateText
                                                  .text,
                                              toDate: context
                                                  .read<AccBloc>()
                                                  .toDateText
                                                  .text,
                                            ),
                                          );
                                    } else {
                                      showToast(
                                          message: AppLocalizations.of(context)!
                                              .enterRequiredField);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Report Results
                          if (context.read<AccBloc>().reportsData != null) ...[
                            const SizedBox(height: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: MyText(
                                    text:
                                        '${context.read<AccBloc>().reportsData!.fromDate} - ${context.read<AccBloc>().reportsData!.toDate}',
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textMutedColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: MyText(
                                    text:
                                        '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalEarnings}',
                                    textStyle: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textDarkColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : AppColors.borderColors,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyText(
                                              text:
                                                  '${AppLocalizations.of(context)!.cash} ${AppLocalizations.of(context)!.count}',
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: textMutedColor,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                            ),
                                            const SizedBox(height: 6),
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalCashTripCount
                                                  .toString(),
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 36,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : AppColors.borderColors,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyText(
                                              text:
                                                  '${AppLocalizations.of(context)!.wallet} ${AppLocalizations.of(context)!.count}',
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: textMutedColor,
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 6),
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalWalletTripCount
                                                  .toString(),
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 36,
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : AppColors.borderColors,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyText(
                                              text:
                                                  '${AppLocalizations.of(context)!.trips} ${AppLocalizations.of(context)!.count}',
                                              textStyle: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: textMutedColor,
                                              ),
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 6),
                                            MyText(
                                              text: context
                                                  .read<AccBloc>()
                                                  .reportsData!
                                                  .totalTripsCount
                                                  .toString(),
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textDarkColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                FareBreakdownWidget(
                                    cont: context,
                                    name: (userData?.distanceUnit == 'km')
                                        ? AppLocalizations.of(context)!
                                            .totalTripsKms
                                        : AppLocalizations.of(context)!
                                            .totalTripsMis,
                                    price:
                                        '${context.read<AccBloc>().reportsData!.totalTripKms}'),
                                FareBreakdownWidget(
                                    cont: context,
                                    name:
                                        "${AppLocalizations.of(context)!.wallet} ${AppLocalizations.of(context)!.payment}",
                                    price:
                                        '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalWalletTripAmount}'),
                                FareBreakdownWidget(
                                    cont: context,
                                    name:
                                        "${AppLocalizations.of(context)!.cash} ${AppLocalizations.of(context)!.payment}",
                                    price:
                                        '${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalCashTripAmount}'),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .totalEarnings,
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                        maxLines: 2,
                                      ),
                                      MyText(
                                        text:
                                            "${context.read<AccBloc>().reportsData!.currencySymbol} ${context.read<AccBloc>().reportsData!.totalEarnings}",
                                        textStyle: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
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
