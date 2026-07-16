import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/page/home_page.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class DiagnosticPage extends StatelessWidget {
  static const String routeName = '/diagnostics';
  const DiagnosticPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => HomeBloc()..add(CheckInternet()),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) async {
          if (state is DiagnosticPageCheckState) {
            printWrapped("Page changed");
          }
          if (state is CheckLocationState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: state.isLocationEnabled
                      ? CustomDoubleButtonDialoge(
                          title: AppLocalizations.of(context)!.currentLocation,
                          content: AppLocalizations.of(context)!
                              .alertCurrentLocation,
                          yesBtnName: AppLocalizations.of(context)!.yes,
                          noBtnName: AppLocalizations.of(context)!.no,
                          yesBtnColor: AppColors.primary,
                          yesBtnFunc: () {
                            Navigator.of(context).pop();
                          },
                          noBtnFunc: () {
                            context.read<HomeBloc>().isLocationsEnabled = false;
                            context.read<HomeBloc>().add(UpdateEvent());
                            Navigator.of(context).pop();
                          },
                        )
                      : CustomSingleButtonDialoge(
                          title: AppLocalizations.of(context)!.currentLocation,
                          content: AppLocalizations.of(context)!
                              .locationPermissionText,
                          btnName: AppLocalizations.of(context)!.ok,
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                );
              },
            );
          }
          if (state is CheckNotificationState && state.isNotificationEnabled) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: CustomDoubleButtonDialoge(
                    title: AppLocalizations.of(context)!.alertNotificationText,
                    content: AppLocalizations.of(context)!
                        .alertNotificationSubText
                        .replaceAll("*", "notification"),
                    yesBtnName: AppLocalizations.of(context)!.yes,
                    noBtnName: AppLocalizations.of(context)!.no,
                    yesBtnColor: AppColors.primary,
                    yesBtnFunc: () {
                      Navigator.of(context).pop();
                      if (userData!.role == 'driver' &&
                          userData!.approve == false) {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            DriverProfilePage.routeName,
                            arguments: VehicleUpdateArguments(
                              from: 'rejected',
                            ),
                            (route) => false);
                      }
                    },
                    noBtnFunc: () {
                      context.read<HomeBloc>().isNotificationsEnabled = false;
                      context.read<HomeBloc>().add(UpdateEvent());
                      Navigator.of(context).pop();
                      if (userData!.role == 'driver' &&
                          userData!.approve == false) {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            DriverProfilePage.routeName,
                            arguments: VehicleUpdateArguments(
                              from: 'rejected',
                            ),
                            (route) => false);
                      }
                    },
                  ),
                );
              },
            );
          }
          if (state is CheckSoundState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: CustomDoubleButtonDialoge(
                    title: AppLocalizations.of(context)!.alertSoundText,
                    content: AppLocalizations.of(context)!
                        .alertNotificationSubText
                        .replaceAll("*", "sound"),
                    yesBtnName: AppLocalizations.of(context)!.yes,
                    noBtnName: AppLocalizations.of(context)!.no,
                    yesBtnColor: AppColors.primary,
                    yesBtnFunc: () {
                      context.read<HomeBloc>().add(DiagnosticCompleteEvent());
                      Navigator.of(context).pop();
                    },
                    noBtnFunc: () {
                      context.read<HomeBloc>().isSoundsChecked = false;
                      context.read<HomeBloc>().add(UpdateEvent());
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            );
          }
          if (state is DiagnosticCompleteState) {
            return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext _) {
                return BlocProvider.value(
                    value: BlocProvider.of<HomeBloc>(context),
                    child: AlertDialog(
                      actionsAlignment: MainAxisAlignment.center,
                      content: SizedBox(
                        height: size.height * 0.35,
                        child: Column(
                          children: [
                            const Image(
                              image: AssetImage(AppImages.diagnosticFinalAlert),
                            ),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .diagnosticFinalAlertText,
                              maxLines: 4,
                            )
                          ],
                        ),
                      ),
                      actions: [
                        CustomButton(
                          buttonName: AppLocalizations.of(context)!.done,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.read<HomeBloc>().add(
                                  DiagnosticCheckEvent(
                                      isDiagnosticsCheckPage: false),
                                );
                            Navigator.pushNamedAndRemoveUntil(
                                context, HomePage.routeName, (route) => false,
                                arguments: HomePageArguments(
                                    isFromHistory: true, from: '0'));
                          },
                        )
                      ],
                    ));
              },
            );
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final isCheckPage = context.read<HomeBloc>().isDiagnosticsCheckPage;
            return Directionality(
              textDirection: context.read<HomeBloc>().textDirection == 'ltr'
                  ? TextDirection.ltr
                  : TextDirection.rtl,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: MyText(
                    text: AppLocalizations.of(context)!.diagnotics,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: isCheckPage
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 8.0),
                                child: Center(
                                  child: MyText(
                                    text: AppLocalizations.of(context)!
                                        .diagnoticsSubText,
                                    textAlign: TextAlign.center,
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      diagnosticListWidgets(
                                          size,
                                          context,
                                          Icons.language_rounded,
                                          AppLocalizations.of(context)!
                                              .internetConnectivity,
                                          AppLocalizations.of(context)!
                                              .internetSubText,
                                          context
                                              .read<HomeBloc>()
                                              .isInternetConnected,
                                          true),
                                      diagnosticListWidgets(
                                          size,
                                          context,
                                          Icons.location_on_rounded,
                                          AppLocalizations.of(context)!
                                              .currentLocation,
                                          AppLocalizations.of(context)!
                                              .locationSubText,
                                          context
                                              .read<HomeBloc>()
                                              .isLocationsEnabled,
                                          true),
                                      diagnosticListWidgets(
                                          size,
                                          context,
                                          Icons.notifications_rounded,
                                          AppLocalizations.of(context)!
                                              .notificationStatus,
                                          AppLocalizations.of(context)!
                                              .notificationSubText,
                                          context
                                              .read<HomeBloc>()
                                              .isNotificationsEnabled,
                                          true),
                                      diagnosticListWidgets(
                                          size,
                                          context,
                                          Icons.volume_up_rounded,
                                          AppLocalizations.of(context)!
                                              .soundStatus,
                                          AppLocalizations.of(context)!
                                              .soundSubText,
                                          context
                                              .read<HomeBloc>()
                                              .isSoundsChecked,
                                          false),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  (context
                                                  .read<HomeBloc>()
                                                  .isLocationsEnabled ==
                                              null ||
                                          (context
                                                      .read<HomeBloc>()
                                                      .isLocationsEnabled !=
                                                  null &&
                                              context
                                                      .read<HomeBloc>()
                                                      .isLocationsEnabled ==
                                                  false))
                                      ? context
                                          .read<HomeBloc>()
                                          .add(CheckLocation())
                                      : (context
                                                      .read<HomeBloc>()
                                                      .isNotificationsEnabled ==
                                                  null ||
                                              (context
                                                          .read<HomeBloc>()
                                                          .isNotificationsEnabled !=
                                                      null &&
                                                  context
                                                          .read<HomeBloc>()
                                                          .isNotificationsEnabled ==
                                                      false))
                                          ? context
                                              .read<HomeBloc>()
                                              .add(CheckNotification())
                                          : context
                                              .read<HomeBloc>()
                                              .add(CheckSound());
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.graphic_eq_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      MyText(
                                        text: (context
                                                        .read<HomeBloc>()
                                                        .isLocationsEnabled ==
                                                    null ||
                                                (context
                                                            .read<HomeBloc>()
                                                            .isLocationsEnabled !=
                                                        null &&
                                                    context
                                                            .read<HomeBloc>()
                                                            .isLocationsEnabled ==
                                                        false))
                                            ? AppLocalizations.of(context)!
                                                .checkLocation
                                            : (context
                                                            .read<HomeBloc>()
                                                            .isNotificationsEnabled ==
                                                        null ||
                                                    (context
                                                                .read<
                                                                    HomeBloc>()
                                                                .isNotificationsEnabled !=
                                                            null &&
                                                        context
                                                                .read<
                                                                    HomeBloc>()
                                                                .isNotificationsEnabled ==
                                                            false))
                                                ? AppLocalizations.of(context)!
                                                    .checkNotification
                                                : AppLocalizations.of(context)!
                                                    .testSound,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Card(
                                  color: isDark
                                      ? const Color(0xFF131C2E)
                                      : Colors.white,
                                  elevation: isDark ? 0 : 4,
                                  shadowColor: Colors.black.withOpacity(0.04),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Image.asset(
                                            // AppImages.diagnosticInit,
                                            AppImages.diagnosticsNoDataImage,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isDark
                                                ? const Color(0x1F2563EB)
                                                : const Color(0xFFEFF6FF),
                                            border: Border.all(
                                              color: AppColors.primary,
                                              width: 1.5,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.headset_mic_rounded,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        MyText(
                                          textAlign: TextAlign.center,
                                          text: AppLocalizations.of(context)!
                                              .dignosticsAssistText
                                              .replaceAll("**", "\n"),
                                          textStyle: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        MyText(
                                          textAlign: TextAlign.center,
                                          text: AppLocalizations.of(context)!
                                              .dignosticsSolutionText
                                              .replaceAll("**", "\n"),
                                          maxLines: 4,
                                          textStyle: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  context.read<HomeBloc>().add(
                                        DiagnosticCheckEvent(
                                            isDiagnosticsCheckPage: true),
                                      );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText(
                                        text:
                                            AppLocalizations.of(context)!.check,
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
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

  Widget diagnosticListWidgets(Size size, BuildContext context, IconData icons,
      String mainText, String subText, bool? status, bool showVerticalLine) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = status == true;
    final isFailed = status == false;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Timeline column
          Column(
            children: [
              const SizedBox(height: 24),
              // The Dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.primary
                        : isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFD1D5DB),
                    width: 4,
                  ),
                ),
              ),
              // Vertical Line
              if (showVerticalLine)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // The Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131C2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  width: 1,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  // Icon inside circle
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.primary
                          : isDark
                              ? const Color(0x1F2563EB)
                              : const Color(0xFFEFF6FF),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      icons,
                      color: isCompleted ? Colors.white : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title and desc
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: mainText,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          text: subText,
                          maxLines: 2,
                          textStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Status badge outline
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? (isDark
                                    ? const Color(0x1F10B981)
                                    : const Color(0xFFECFDF5))
                                : isFailed
                                    ? (isDark
                                        ? const Color(0x1FEF4444)
                                        : const Color(0xFFFEF2F2))
                                    : (isDark
                                        ? const Color(0x1F6366F1)
                                        : const Color(0xFFEEF2FF)),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : isFailed
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF6366F1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle_outline_rounded
                                    : isFailed
                                        ? Icons.cancel_outlined
                                        : Icons.access_time_rounded,
                                size: 14,
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : isFailed
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF6366F1),
                              ),
                              const SizedBox(width: 4),
                              MyText(
                                text: isCompleted
                                    ? AppLocalizations.of(context)!.checkedText
                                    : isFailed
                                        ? AppLocalizations.of(context)!.failed
                                        : AppLocalizations.of(context)!.pending,
                                textStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isCompleted
                                      ? const Color(0xFF10B981)
                                      : isFailed
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Far right check or pending badge
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.access_time_rounded,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : isDark
                            ? const Color(0xFF6366F1).withOpacity(0.5)
                            : const Color(0xFFC7D2FE),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
