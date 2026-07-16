import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../../application/acc_bloc.dart';

class FleetVehicleDetailsWidget extends StatelessWidget {
  final BuildContext cont;
  const FleetVehicleDetailsWidget({super.key, required this.cont});

  IconData _getVehicleIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('auto') || lower.contains('rickshaw')) {
      return Icons.electric_rickshaw_rounded;
    } else if (lower.contains('bike') ||
        lower.contains('cycle') ||
        lower.contains('moto') ||
        lower.contains('scooter')) {
      return Icons.motorcycle_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          final vehicleList = accBloc.vehicleData;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: ListView.builder(
              itemCount: vehicleList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final vehicle = vehicleList[index];
                final hasDriver = vehicle.driverDetail != null;

                // Status Message and warning colors
                String statusMessage = '';
                Color warningColor = const Color(0xFFEF4444); // default red

                if (vehicle.isDeclined) {
                  statusMessage =
                      AppLocalizations.of(context)!.uploadedDoccumentDeclined;
                  warningColor = const Color(0xFFEF4444);
                } else if (vehicle.approve == 0 &&
                    vehicle.uploadDocument == true) {
                  statusMessage =
                      AppLocalizations.of(context)!.waitingForApproval;
                  warningColor = const Color(0xFFF59E0B); // Amber
                } else if (vehicle.uploadDocument == false &&
                    vehicle.approve == 0) {
                  statusMessage =
                      AppLocalizations.of(context)!.documentNotUploaded;
                  warningColor = const Color(0xFFEF4444);
                } else if (vehicle.approve == 1 &&
                    vehicle.driverDetail == null) {
                  statusMessage =
                      AppLocalizations.of(context)!.noDriversAssigned;
                  warningColor = const Color(0xFFF59E0B); // Amber
                }

                // Action button text
                String actionBtnText = '';
                if (vehicle.approve == 1 && vehicle.driverDetail == null) {
                  actionBtnText = AppLocalizations.of(context)!.assignDriver;
                } else if (vehicle.approve == 0 &&
                    vehicle.uploadDocument == true) {
                  actionBtnText = AppLocalizations.of(context)!.viewDocument;
                } else if (vehicle.approve == 0 &&
                    vehicle.uploadDocument == false) {
                  actionBtnText = AppLocalizations.of(context)!.uploadDocument;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
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
                                color: primaryColor.withOpacity(0.1),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _getVehicleIcon(vehicle.name),
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              vehicle.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          width: 1,
                          height: 70,
                          color: borderColor,
                        ),
                      ),

                      // Center Column: Model & Phone/Status Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Model Row
                            Row(
                              children: [
                                Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.directions_car_outlined,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    vehicle.model,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Phone Row or Status Warning
                            if (hasDriver) ...[
                              Row(
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.phone_outlined,
                                      color: primaryColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      vehicle.driverDetail!['mobile'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              // Warning / status message
                              Row(
                                children: [
                                  Container(
                                    height: 32,
                                    width: 32,
                                    decoration: BoxDecoration(
                                      color: warningColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.warning_amber_rounded,
                                      color: warningColor,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      statusMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: warningColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Button action under status if not assigned/uploaded
                              if (actionBtnText.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    if (vehicle.approve == 1) {
                                      context.read<AccBloc>().add(
                                            GetDriverEvent(
                                              from: 1,
                                              fleetId: vehicle.id,
                                            ),
                                          );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DriverProfilePage(
                                            args: VehicleUpdateArguments(
                                              from: 'docs',
                                              fleetId: vehicle.id,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          vehicle.approve == 1
                                              ? Icons.person_add_alt_1_outlined
                                              : Icons.cloud_upload_outlined,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          actionBtnText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),

                      // Right Column: Pencil Edit/Assign Button
                      if (vehicle.approve == 1) ...[
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            context.read<AccBloc>().add(
                                  GetDriverEvent(
                                    from: 1,
                                    fleetId: vehicle.id,
                                  ),
                                );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.edit_outlined,
                              color: primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
