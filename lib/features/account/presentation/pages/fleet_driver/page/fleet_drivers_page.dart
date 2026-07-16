import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/utils/custom_dialoges.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../widget/add_fleet_driver.dart';

class FleetDriversPage extends StatelessWidget {
  static const String routeName = '/driversPage';

  const FleetDriversPage({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
        return (parts[0][0] + parts[1][0]).toUpperCase();
      }
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  Color _getAvatarThemeColor(int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider(
      create: (context) => AccBloc()..add(GetDriverEvent(from: 0)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is DriversLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is DriversLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is ShowErrorState) {
            context.showSnackBar(color: AppColors.red, message: state.message);
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final accBloc = context.read<AccBloc>();
            final drivers = accBloc.driverData;

            return SafeArea(
              child: Scaffold(
                backgroundColor: scaffoldBgColor,
                body: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          // Custom Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.05),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () => Navigator.pop(context),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1F2937),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.drivers,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .manageYourDrivers,
                                      style: TextStyle(
                                        color: subtitleColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Drivers List
                          Expanded(
                            child: drivers.isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.noDriversAvail,
                                        width: 300,
                                      ),
                                      const SizedBox(height: 16),
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .noDriversAdded,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: subtitleColor,
                                            ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    itemCount: drivers.length,
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.05,
                                      right: size.width * 0.05,
                                      bottom: 80,
                                    ),
                                    itemBuilder: (context, index) {
                                      final driver = drivers[index];
                                      final themeColor =
                                          _getAvatarThemeColor(index);
                                      final avatarBg =
                                          themeColor.withOpacity(0.1);
                                      final initials =
                                          _getInitials(driver.name);

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: borderColor),
                                          boxShadow: isDark
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.02),
                                                    blurRadius: 15,
                                                    offset: const Offset(0, 6),
                                                  )
                                                ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Left Column: Avatar & Name
                                            SizedBox(
                                              width: size.width * 0.22,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    height: 56,
                                                    width: 56,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: avatarBg,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      initials,
                                                      style: TextStyle(
                                                        color: themeColor,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    driver.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Divider
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              child: Container(
                                                width: 1,
                                                height: 70,
                                                color: borderColor,
                                              ),
                                            ),

                                            // Center Column: Phone & Vehicle/Status Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Phone Row
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 32,
                                                        width: 32,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: avatarBg,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons.phone_outlined,
                                                          color: themeColor,
                                                          size: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          driver.mobile,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: textColor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),

                                                  // Vehicle / Document Row
                                                  Row(
                                                    children: [
                                                      if (!driver.approve) ...[
                                                        // Warning / Document status
                                                        Container(
                                                          height: 32,
                                                          width: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: const Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            color: Colors.red,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            driver.documentUploaded
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .waitingForApproval
                                                                : AppLocalizations.of(
                                                                        context)!
                                                                    .documentNotUploaded,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        // Vehicle Plate details
                                                        Container(
                                                          height: 32,
                                                          width: 32,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: avatarBg,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons
                                                                .directions_car_outlined,
                                                            color: themeColor,
                                                            size: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            driver.carNumber ??
                                                                AppLocalizations.of(
                                                                        context)!
                                                                    .fleetNotAssigned,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              color: driver
                                                                          .carNumber ==
                                                                      null
                                                                  ? Colors.red
                                                                  : textColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Right side: Delete Trash Button
                                            InkWell(
                                              onTap: () {
                                                accBloc.choosenDriverForDelete =
                                                    driver.id;
                                                showDialog(
                                                  context: context,
                                                  builder: (builder) {
                                                    return CustomSingleButtonDialoge(
                                                      title:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .deleteDriver,
                                                      content:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .deleteDriverSure,
                                                      btnName:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .deleteDriver,
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        accBloc.add(
                                                          DeleteDriverEvent(
                                                            driverId: accBloc
                                                                .choosenDriverForDelete!,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),

                      // Floating Action Plus Button (FAB)
                      Positioned(
                        bottom: 16,
                        right: (accBloc.textDirection == 'ltr') ? 16 : null,
                        left: (accBloc.textDirection == 'rtl') ? 16 : null,
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              useSafeArea: true,
                              builder: (builder) {
                                return AddFleetDriverWidget(cont: context);
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isDark
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.secondary,
                                        AppColors.primary
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFF001CAD),
                                        Color(0xFF00168C)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
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
