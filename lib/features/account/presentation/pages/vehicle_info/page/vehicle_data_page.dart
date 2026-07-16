// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_colors.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/vehicle_info/widget/vehicle_owner_shimmer.dart';
import 'package:restart_tagxi/features/driverprofile/presentation/pages/driver_profile_pages.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../widget/assigned_drivers_widget.dart';
import '../widget/fleet_vehicle_details.dart';

class VehicleDataPage extends StatefulWidget {
  static const String routeName = '/vehicleInformation';
  final VehicleDataArguments? args;

  const VehicleDataPage({super.key, this.args});

  @override
  State<VehicleDataPage> createState() => _VehicleDataPageState();
}

class _VehicleDataPageState extends State<VehicleDataPage> {
  Widget _buildVehicleDetailItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String label,
    required String? value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x1F2563EB)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: label,
                      textStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      text: (value != null && value.isNotEmpty) ? value : '--',
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return BlocProvider(
        create: (context) => AccBloc()..add(GetVehiclesEvent()),
        child: BlocListener<AccBloc, AccState>(listener: (context, state) {
          if (state is VehiclesLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is VehiclesLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is ShowAssignDriverState) {
            if (context.read<AccBloc>().driverData.isNotEmpty) {
              showModalBottomSheet(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  context: context,
                  builder: (_) {
                    return AssignedDriversWidget(cont: context);
                  });
            } else {
              showModalBottomSheet(
                  backgroundColor: AppColors.white,
                  context: context,
                  builder: (builder) {
                    return Container(
                        height: size.height * 0.3,
                        width: size.width,
                        padding: EdgeInsets.all(size.width * 0.05),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white,
                        ),
                        child: Center(
                          child: MyText(
                            text:
                                AppLocalizations.of(context)!.noDriverAvailable,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.red),
                            maxLines: 5,
                          ),
                        ));
                  });
            }
          }
        }, child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
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
              title: Column(
                children: [
                  MyText(
                    text: AppLocalizations.of(context)!.vehicleInfo,
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text:
                        AppLocalizations.of(context)!.vehicleDetailsPageSubText,
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.width * 0.05,
                          ),
                          (userData!.role == 'driver')
                              ? (userData!.vehicleTypeName != '')
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF131C2E)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
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
                                                        color: Colors.black
                                                            .withOpacity(0.02),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                            ),
                                            child: Column(
                                              children: [
                                                _buildVehicleDetailItem(
                                                  context: context,
                                                  isDark: isDark,
                                                  icon: Icons
                                                      .electric_moped_rounded,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .vehicleType,
                                                  value:
                                                      userData!.vehicleTypeName,
                                                ),
                                                _buildVehicleDetailItem(
                                                  context: context,
                                                  isDark: isDark,
                                                  icon: Icons.business_rounded,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .vehicleMake,
                                                  value: userData!.carMake,
                                                ),
                                                _buildVehicleDetailItem(
                                                  context: context,
                                                  isDark: isDark,
                                                  icon:
                                                      Icons.motorcycle_rounded,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .vehicleModel,
                                                  value: userData!.carModel,
                                                ),
                                                _buildVehicleDetailItem(
                                                  context: context,
                                                  isDark: isDark,
                                                  icon: Icons.numbers_rounded,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .vehicleNumber,
                                                  value: userData!.carNumber,
                                                ),
                                                _buildVehicleDetailItem(
                                                  context: context,
                                                  isDark: isDark,
                                                  icon: Icons.palette_rounded,
                                                  label: AppLocalizations.of(
                                                          context)!
                                                      .vehicleColor,
                                                  value: userData!.carColor,
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (userData!.ownerId == null ||
                                              userData!.ownerId == '')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 24),
                                              child: InkWell(
                                                onTap: () async {
                                                  await Navigator.pushNamed(
                                                    context,
                                                    DriverProfilePage.routeName,
                                                    arguments:
                                                        VehicleUpdateArguments(
                                                            from: 'vehicle'),
                                                  ).then((_) {
                                                    if (!context.mounted)
                                                      return;
                                                    context
                                                        .read<AccBloc>()
                                                        .add(UpdateEvent());
                                                  });
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Container(
                                                  width: size.width,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.edit_rounded,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      MyText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .edit,
                                                        textStyle:
                                                            const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        Image.asset(AppImages.historyNoData),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .vehicleNotAssigned,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    )
                              : (context.read<AccBloc>().vehicleData.isEmpty)
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImages.noVehicleInfo,
                                          width: 300,
                                        ),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .noVehicleCreated,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    )
                                  : FleetVehicleDetailsWidget(cont: context)
                        ],
                      ),
                    ),
                  ),
                  if (userData!.role == 'owner')
                    Column(
                      children: [
                        SizedBox(height: size.width * 0.05),
                        if (context.read<AccBloc>().isLoading)
                          VehicleOwnerShimmerWidget.circular(
                              width: size.width, height: size.height),
                        if (!context.read<AccBloc>().isLoading)
                          SizedBox(
                            width: size.width * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    var nav = await Navigator.pushNamed(
                                        context, DriverProfilePage.routeName,
                                        arguments: VehicleUpdateArguments(
                                            from: 'owner'));
                                    if (nav != null && nav == true) {
                                      if (!context.mounted) return;
                                      context
                                          .read<AccBloc>()
                                          .add(GetVehiclesEvent());
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.128,
                                    height: size.width * 0.128,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: size.width * 0.075,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: size.width * 0.05)
                ],
              ),
            ),
          );
        })));
  }
}
