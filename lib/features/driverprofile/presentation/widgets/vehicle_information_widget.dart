import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/driverprofile/application/driver_profile_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import 'get_company_info.dart';
import 'get_vehicle_info.dart';

class VehicleInformationWidget extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments args;
  const VehicleInformationWidget(
      {super.key, required this.cont, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();

          return Form(
            key: driverBloc.driverProfileformKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Register For Options
                if (userData!.enableModulesForApplications == 'both' &&
                    args.from != 'owner') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: MyText(
                      text: AppLocalizations.of(context)!.registerFor,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: List.generate(
                          driverBloc.vehicleRegisterFor.length, (i) {
                        final typeName = driverBloc.vehicleRegisterFor[i];
                        final isSelected = driverBloc.registerFor == typeName;

                        IconData itemIcon = Icons.widgets_outlined;
                        if (typeName == 'Taxi') {
                          itemIcon = Icons.local_taxi_outlined;
                        } else if (typeName == 'Delivery') {
                          itemIcon = Icons.inventory_2_outlined;
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              driverBloc
                                  .add(GetServiceLocationEvent(type: typeName));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right:
                                    i < driverBloc.vehicleRegisterFor.length - 1
                                        ? 12
                                        : 0,
                              ),
                              height: 80,
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withOpacity(0.06)
                                          : cardBgColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : borderColor,
                                        width: isSelected ? 1.5 : 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          itemIcon,
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).hintColor,
                                          size: 24,
                                        ),
                                        const SizedBox(height: 6),
                                        MyText(
                                          text: typeName,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .hintColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Service Location Picker
                if (args.from != 'owner') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: MyText(
                      text: AppLocalizations.of(context)!.serviceLocation,
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: InkWell(
                      onTap: () {
                        if (driverBloc.registerFor != null) {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24)),
                            ),
                            builder: (builder) {
                              return SafeArea(
                                child: Container(
                                  width: size.width,
                                  height: size.height * 0.6,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(24)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 12),
                                        width: 48,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.2)
                                              : const Color(0xFFCBD5E1),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: MyText(
                                          text: AppLocalizations.of(context)!
                                              .chooseServiceLoc,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                        ),
                                      ),
                                      const Divider(height: 1),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: EdgeInsets.only(
                                            bottom:
                                                MediaQuery.paddingOf(context)
                                                        .bottom +
                                                    20,
                                          ),
                                          itemCount: driverBloc
                                              .serviceLocations.length,
                                          itemBuilder: (context, i) {
                                            final loc =
                                                driverBloc.serviceLocations[i];
                                            return ListTile(
                                              title: MyText(
                                                text: loc.name,
                                                textStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColorDark),
                                              ),
                                              onTap: () {
                                                driverBloc
                                                    .add(GetVehicleTypeEvent(
                                                  id: loc.id,
                                                  type: driverBloc.registerFor!,
                                                  from: args.from,
                                                ));
                                                Navigator.pop(context);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Theme.of(context).hintColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MyText(
                                text: driverBloc.choosenServiceLocation != null
                                    ? driverBloc.serviceLocations
                                        .firstWhere((e) =>
                                            e.id ==
                                            driverBloc.choosenServiceLocation)
                                        .name
                                    : "e.g., New York, NY",
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: driverBloc
                                                  .choosenServiceLocation !=
                                              null
                                          ? Theme.of(context).primaryColorDark
                                          : Theme.of(context).hintColor,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: Theme.of(context).hintColor,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Dynamic inputs (Vehicle or Company info)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: (userData!.role == 'driver' || args.from == 'owner')
                      ? GetVehicleInfo(cont: context, args: args)
                      : GetCompanyInfo(cont: context, args: args),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
