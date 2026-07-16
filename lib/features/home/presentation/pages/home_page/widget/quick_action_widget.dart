import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/page/diagnostic_page.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/select_preference_widget.dart';

import '../../../../../../common/app_constants.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../account/presentation/pages/admin_chat/page/admin_chat.dart';
import '../../../../application/home_bloc.dart';

class QuickActionsWidget extends StatelessWidget {
  final BuildContext cont;
  const QuickActionsWidget({super.key, required this.cont});

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget leadingIcon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final iconBgColor =
        isDark ? const Color(0xFF1B253F) : const Color(0xFFF0F2FF);
    final iconColor = isDark ? Colors.white : const Color(0xFF001CAD);

    final titleColor = isDark ? Colors.white : const Color(0xFF171A1F);
    final subtitleColor = const Color(0xFF9095A1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: leadingIcon is Icon
                      ? Icon(
                          leadingIcon.icon,
                          color: iconColor,
                          size: 24,
                        )
                      : leadingIcon is Image
                          ? Image(
                              image: leadingIcon.image,
                              width: 24,
                              height: 24,
                              color: iconColor,
                            )
                          : leadingIcon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: title,
                        textStyle: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: subtitle,
                        textStyle: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF9CA3AF),
                      size: 24,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Container(
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: SafeArea(
              child: Column(
                key: const Key('switcher1'),
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: MyText(
                      text: AppLocalizations.of(context)!.instantActivity,
                      textStyle:
                          Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: MyText(
                      text:
                          AppLocalizations.of(context)!.instantActivitySubText,
                      textStyle:
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: const Color(0xFF9095A1),
                                fontSize: 14,
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (userData!.showInstantRideFeatureForMobileApp == '1' &&
                      userData!.active)
                    _buildCard(
                      context: context,
                      title: AppLocalizations.of(context)!.instantRide,
                      subtitle:
                          AppLocalizations.of(context)!.instantRideSubText,
                      leadingIcon: Image.asset(AppImages.vehicleMakeImage),
                      onTap: () {
                        context.read<HomeBloc>().bottomSize =
                            -(size.height * 0.8);
                        context.read<HomeBloc>().animatedWidget = null;
                        context.read<HomeBloc>().add(UpdateEvent());
                        context.read<HomeBloc>().add(ShowGetDropAddressEvent());
                      },
                    ),
                  _buildCard(
                    context: context,
                    title: AppLocalizations.of(context)!.helpCenter,
                    subtitle: AppLocalizations.of(context)!.helpCenterSubText,
                    leadingIcon: Image.asset(AppImages.headset),
                    onTap: () {
                      Navigator.pushNamed(context, AdminChat.routeName);
                    },
                  ),
                  if (Platform.isAndroid)
                    _buildCard(
                      context: context,
                      title: AppLocalizations.of(context)!.showBubbleIcon,
                      subtitle:
                          AppLocalizations.of(context)!.showBubbleIconSubText,
                      leadingIcon: Image.asset(AppImages.recycle),
                      trailing: Switch(
                        value: showBubbleIcon,
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF001CAD),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFBDC1CA),
                        trackOutlineColor:
                            WidgetStateProperty.all(Colors.transparent),
                        onChanged: (v) {
                          context
                              .read<HomeBloc>()
                              .add(EnableBubbleEvent(isEnabled: v));
                        },
                      ),
                    ),
                  if (userData!.enableSubVehicleFeature == "1")
                    _buildCard(
                      context: context,
                      title: AppLocalizations.of(context)!.myServices,
                      subtitle: AppLocalizations.of(context)!.myServicesSubText,
                      leadingIcon: Image.asset(AppImages.vehicleModelImage),
                      onTap: () {
                        context.read<HomeBloc>().add(GetSubVehicleTypesEvent(
                            serviceLocationId: userData!.serviceLocationId!,
                            vehicleType: userData!.vehicleTypes![0]));
                      },
                    ),
                  if (userData!.active && userData!.role == 'driver')
                    _buildCard(
                      context: context,
                      title: AppLocalizations.of(context)!.notGettingRequest,
                      subtitle: AppLocalizations.of(context)!
                          .notGettingRequestSubText,
                      leadingIcon:
                          const Icon(Icons.chat_bubble_outline_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, DiagnosticPage.routeName);
                      },
                    ),
                  if (userData!.role == 'driver')
                    _buildCard(
                      context: context,
                      title: AppLocalizations.of(context)!.preferences,
                      subtitle:
                          AppLocalizations.of(context)!.preferencesSubText,
                      leadingIcon: const Icon(Icons.tune_rounded),
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: false,
                            enableDrag: false,
                            isDismissible: false,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(
                                    20.0), // Adjust the radius to your liking
                              ),
                            ),
                            builder: (_) {
                              return SelectPreferenceWidget(cont: context);
                            });
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
