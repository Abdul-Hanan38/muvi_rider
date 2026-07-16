// ignore_for_file: deprecated_member_use

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:restart_tagxi/common/common.dart";
import "package:restart_tagxi/core/utils/custom_button.dart";
import "package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/create_ticket_sheet.dart";
import "../../../../../../core/utils/custom_dialoges.dart";
import "../../../../../../core/utils/custom_loader.dart";
import "../../../../../../core/utils/custom_slider/custom_sliderbutton.dart";
import "../../../../../../core/utils/custom_snack_bar.dart";
import "../../../../../../core/utils/custom_text.dart";
import "../../../../../../l10n/app_localizations.dart";
import "../../../../../home/presentation/pages/home_page/page/home_page.dart";
import "../../../../application/acc_bloc.dart";

import "../widget/cancel_ride_widget.dart";
import "../widget/trip_earnings_widget.dart";
import "../widget/trip_farebreakup_widget.dart";
import "../widget/trip_user_details_widget.dart";
import "../widget/trip_vehicle_info_widget.dart";

class HistoryTripSummaryPage extends StatelessWidget {
  static const String routeName = '/historytripsummary';
  final TripHistoryPageArguments arg;

  const HistoryTripSummaryPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AddHistoryMarkerEvent(
            stops: arg.historyData.requestStops,
            pickLat: arg.historyData.pickLat,
            pickLng: arg.historyData.pickLng,
            dropLat: arg.historyData.dropLat,
            dropLng: arg.historyData.dropLng,
            polyline: arg.historyData.polyLine))
        ..add(TripSummaryHistoryDataEvent(tripHistoryData: arg.historyData)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccInitialState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is HistoryTypeChangeState) {
            String filter;
            switch (state.selectedHistoryType) {
              case 0:
                filter = 'is_completed=1';
                break;
              case 1:
                filter = 'is_later=1';
                break;
              case 2:
                filter = 'is_cancelled=1';
                break;
              default:
                filter = '';
            }
            context.read<AccBloc>().add(HistoryGetEvent(historyFilter: filter));
          } else if (state is RequestCancelState) {
            Navigator.pop(context);
            Navigator.pop(context);
          } else if (state is OutstationReadyToPickupState) {
            Navigator.pushNamed(context, HomePage.routeName,
                arguments: HomePageArguments(isFromHistory: true, from: '1'));
          } else if (state is ShowErrorState) {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext ctx) {
                return CustomSingleButtonDialoge(
                  title: AppLocalizations.of(context)!.cancel,
                  content: AppLocalizations.of(context)!.userCancelledRide,
                  btnName: AppLocalizations.of(context)!.ok,
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                );
              },
            );
          } else if (state is GetTicketListLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is CreateSupportTicketState) {
            if (context.read<AccBloc>().isTicketSheetOpened) return;
            context.read<AccBloc>().isTicketSheetOpened = true;
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              context: context,
              builder: (cont) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: CreateTicketSheet(
                    requestId: state.requestId,
                    cont: context,
                    ticketNamesList: state.ticketNamesList,
                    isFromRequest: state.isFromRequest,
                    index: state.historyIndex,
                    historyPagenumber: state.historyPageNumber,
                  ),
                );
              },
            ).whenComplete(() {
              if (context.mounted) {
                context.read<AccBloc>().isTicketSheetOpened = false;
              }
            });
          } else if (state is InvoiceDownloadingState) {
            CustomLoader.dismiss(context);
          } else if (state is InvoiceDownloadSuccessState) {
            showToast(
                message: AppLocalizations.of(context)!
                    .invoiceDownloadedSuccessfully);
            CustomLoader.dismiss(context);
          } else if (state is InvoiceDownloadFailureState) {
            showToast(
                message: AppLocalizations.of(context)!.invoiceUrlNotAvailable);
            CustomLoader.dismiss(context);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final tripHistoryData = context.read<AccBloc>().historyData;

          if (Theme.of(context).brightness == Brightness.dark) {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().darkMapString);
            }
          } else {
            if (context.read<AccBloc>().googleMapController != null) {
              context
                  .read<AccBloc>()
                  .googleMapController!
                  .setMapStyle(context.read<AccBloc>().lightMapString);
            }
          }
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final pageBg =
              isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
          final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
          final cardBorder =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
          final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
          final textSecondary =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final subtitleColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final isRtl = context.read<AccBloc>().textDirection == 'rtl';

          return Scaffold(
            backgroundColor: pageBg,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: SafeArea(
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.only(
                      top: 8, left: 16, right: 16, bottom: 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PositionedDirectional(
                        start: 0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Icon(
                            isRtl ? Icons.arrow_forward : Icons.arrow_back,
                            color: titleColor,
                            size: 20,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!.rideDetails,
                            textStyle: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: titleColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 2),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .tripSummaryLableText,
                            textStyle:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: subtitleColor,
                                      fontSize: 11,
                                    ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: (tripHistoryData != null)
                ? SafeArea(
                    child: Stack(
                      children: [
                        SizedBox(
                          height: size.height,
                          width: size.width,
                          child: CustomScrollView(
                            slivers: [
                              SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                      childCount: 1, (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.04,
                                    vertical: size.width * 0.04,
                                  ),
                                  width: size.width,
                                  child: Column(
                                    children: [
                                      TripFarebreakupWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.04),
                                      if (tripHistoryData.requestBill !=
                                          null) ...[
                                        TripEarningsWidget(
                                            cont: context, arg: arg),
                                        SizedBox(height: size.width * 0.04),
                                      ],
                                      TripUserDetailsWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.04),
                                      TripVehicleInfoWidget(
                                          cont: context, arg: arg),
                                      SizedBox(height: size.width * 0.04),

                                      // Trip ID Card
                                      Container(
                                        padding:
                                            EdgeInsets.all(size.width * 0.05),
                                        decoration: BoxDecoration(
                                          color: cardBg,
                                          border: Border.all(
                                              width: 1, color: cardBorder),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: isDark
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.02),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
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
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.local_activity_outlined,
                                                  size: 18,
                                                  color: isDark
                                                      ? AppColors.secondary
                                                      : AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .tripId,
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                MyText(
                                                  text: tripHistoryData
                                                      .requestNumber,
                                                  textStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: textPrimary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      if (tripHistoryData.isCompleted == 1) ...[
                                        SizedBox(height: size.width * 0.04),
                                        // Ratings Card
                                        Container(
                                          padding:
                                              EdgeInsets.all(size.width * 0.05),
                                          decoration: BoxDecoration(
                                            color: cardBg,
                                            border: Border.all(
                                                width: 1, color: cardBorder),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: isDark
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.02),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
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
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.star_rounded,
                                                    size: 20,
                                                    color: isDark
                                                        ? AppColors.secondary
                                                        : AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .ratings,
                                                    textStyle: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (index) {
                                                        final isSelected = index <
                                                            tripHistoryData
                                                                .rideUserRating;
                                                        return Icon(
                                                          Icons.star_rounded,
                                                          size: 20,
                                                          color: isSelected
                                                              ? AppColors
                                                                  .primary
                                                              : (isDark
                                                                  ? const Color(
                                                                      0xFF334155)
                                                                  : const Color(
                                                                      0xFFE2E8F0)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      SizedBox(height: size.width * 0.4),
                                    ],
                                  ),
                                );
                              })),
                            ],
                          ),
                        ),
                        if (tripHistoryData.isCancelled != 1)
                          Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: (tripHistoryData.isCompleted == 1)
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: pageBg,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (arg.enableInvoiceDownload ==
                                              '1') ...[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  size.width * 0.05,
                                                  size.width * 0.04,
                                                  size.width * 0.05,
                                                  size.width * 0.02),
                                              child: CustomButton(
                                                  width: size.width,
                                                  buttonName:
                                                      AppLocalizations.of(
                                                              context)!
                                                          .downloadInvoice,
                                                  onTap: () {
                                                    context.read<AccBloc>().add(
                                                          DownloadInvoiceUserEvent(
                                                              journeyId:
                                                                  tripHistoryData
                                                                      .id
                                                                      .toString()),
                                                        );
                                                  }),
                                            ),
                                          ],
                                          if (tripHistoryData
                                                      .supportTicketExist ==
                                                  true &&
                                              arg.isSupportTicketEnabled ==
                                                  '1') ...[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: Container(
                                                width: size.width,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: cardBg,
                                                  border: Border.all(
                                                      color: cardBorder),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        MyText(
                                                          text:
                                                              "${AppLocalizations.of(context)!.ticketCreated} :",
                                                          textStyle: TextStyle(
                                                            color:
                                                                textSecondary,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        MyText(
                                                          text: tripHistoryData
                                                              .supportTicketId,
                                                          textStyle: TextStyle(
                                                            color: textPrimary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    MyText(
                                                      text: tripHistoryData
                                                                  .supportTicketStatus ==
                                                              1
                                                          ? AppLocalizations.of(
                                                                  context)!
                                                              .pending
                                                          : tripHistoryData
                                                                      .supportTicketStatus ==
                                                                  2
                                                              ? AppLocalizations
                                                                      .of(
                                                                          context)!
                                                                  .acknowledged
                                                              : AppLocalizations
                                                                      .of(context)!
                                                                  .closed,
                                                      textStyle: TextStyle(
                                                          color: tripHistoryData
                                                                      .supportTicketStatus ==
                                                                  1
                                                              ? AppColors.blue
                                                              : tripHistoryData
                                                                          .supportTicketStatus ==
                                                                      2
                                                                  ? AppColors
                                                                      .orange
                                                                  : AppColors
                                                                      .red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ] else if (arg
                                                  .isSupportTicketEnabled ==
                                              '1') ...[
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: size.width * 0.05,
                                                vertical: size.width * 0.03,
                                              ),
                                              child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap: () {
                                                    context.read<AccBloc>().add(
                                                            CreateSupportTicketEvent(
                                                          requestId:
                                                              tripHistoryData
                                                                  .requestNumber,
                                                          isFromRequest: true,
                                                          index:
                                                              arg.historyIndex,
                                                          pageNumber:
                                                              arg.pageNumber,
                                                        ));
                                                  },
                                                  child: Container(
                                                    width: size.width,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: cardBg,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xFFEF4444),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons.error_outline,
                                                            size: 18,
                                                            color: Color(
                                                                0xFFEF4444),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          MyText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .reportIssue,
                                                            textStyle:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFFEF4444),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ],
                                      ),
                                    )
                                  : (tripHistoryData.isLater &&
                                          tripHistoryData.isCancelled == 0)
                                      ? Container(
                                          width: size.width,
                                          decoration: BoxDecoration(
                                            color: pageBg,
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 10),
                                                  if (tripHistoryData.isLater ==
                                                          true &&
                                                      tripHistoryData
                                                              .isCancelled ==
                                                          0 &&
                                                      tripHistoryData
                                                              .isOutStation ==
                                                          0)
                                                    CustomButton(
                                                        width: size.width * 0.9,
                                                        height:
                                                            size.width * 0.12,
                                                        buttonName:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .cancel,
                                                        borderRadius: 20,
                                                        onTap: () {
                                                          showModalBottomSheet(
                                                              context: context,
                                                              isScrollControlled:
                                                                  false,
                                                              enableDrag: false,
                                                              isDismissible:
                                                                  true,
                                                              builder: (_) {
                                                                return CancelRideWidget(
                                                                    cont:
                                                                        context,
                                                                    requestId:
                                                                        tripHistoryData
                                                                            .id);
                                                              });
                                                        }),
                                                  SizedBox(
                                                      height:
                                                          size.width * 0.02),
                                                  if (tripHistoryData.isLater ==
                                                          true &&
                                                      tripHistoryData
                                                              .isCancelled ==
                                                          0)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: CustomSliderButton(
                                                        sliderIcon: Icon(
                                                          Icons
                                                              .keyboard_double_arrow_right_rounded,
                                                          color:
                                                              AppColors.white,
                                                          size:
                                                              size.width * 0.07,
                                                        ),
                                                        width: size.width * 0.8,
                                                        buttonName:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .readyToPickup,
                                                        onSlideSuccess:
                                                            () async {
                                                          context
                                                              .read<AccBloc>()
                                                              .add(OutstationReadyToPickupEvent(
                                                                  requestId:
                                                                      tripHistoryData
                                                                          .id));
                                                          return true;
                                                        },
                                                      ),
                                                    )
                                                ],
                                              )),
                                        )
                                      : Container())
                      ],
                    ),
                  )
                : const SizedBox(),
          );
        }),
      ),
    );
  }
}
