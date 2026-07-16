import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/driver_profile_bloc.dart';

class GetVehicleInfo extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments args;
  const GetVehicleInfo({super.key, required this.cont, required this.args});

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isDark,
    required Color textColor,
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color cardColor,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChange,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          enabled: enabled,
          onChange: onChange,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          hintText: hint,
          hintTextStyle: TextStyle(
            color: hintColor,
            fontSize: 14,
          ),
          style: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : const Color(0xFFF1F5F9),
                width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
            ),
          ),
          suffixIcon: suffixIcon,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? selectedValue,
    required VoidCallback onTap,
    required bool isDark,
    required Color textColor,
    required Color primaryColor,
    required Color borderColor,
    required Color hintColor,
    required Color cardColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedValue ?? hint,
                    style: TextStyle(
                      color: selectedValue != null ? textColor : hintColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: selectedValue != null ? textColor : hintColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final primaryColor = AppColors.primary;
    final hintColor =
        isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

    return BlocProvider.value(
      value: cont.read<DriverProfileBloc>(),
      child: BlocBuilder<DriverProfileBloc, DriverProfileState>(
        builder: (context, state) {
          final driverBloc = context.read<DriverProfileBloc>();

          final selectedTypeName = driverBloc.choosenVehicleType != null
              ? driverBloc.vehicleType
                  .firstWhere((e) => e.id == driverBloc.choosenVehicleType)
                  .name
              : null;

          return Column(
            children: [
              // Vehicle Type Dropdown
              _buildDropdownField(
                label: AppLocalizations.of(context)!.vehicleType,
                hint: AppLocalizations.of(context)!.selectType,
                icon: Icons.directions_car_outlined,
                selectedValue: selectedTypeName,
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onTap: () {
                  if (driverBloc.choosenServiceLocation != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: scaffoldBgColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (builder) {
                        return SafeArea(
                          child: Container(
                            width: size.width,
                            height: size.height * 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                // Pill handle
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 16),
                                  width: 48,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.2)
                                        : const Color(0xFFCBD5E1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)!
                                      .chooseVehicleType,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.paddingOf(context).bottom +
                                              20,
                                    ),
                                    itemCount: driverBloc.vehicleType.length,
                                    itemBuilder: (context, i) {
                                      final type = driverBloc.vehicleType[i];
                                      final isSelected =
                                          driverBloc.choosenVehicleType ==
                                              type.id;

                                      return InkWell(
                                        onTap: () {
                                          driverBloc.add(UpdateVehicleTypeEvent(
                                              id: type.id));
                                          Navigator.pop(context);
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: cardColor,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSelected
                                                  ? primaryColor
                                                  : borderColor,
                                              width: isSelected ? 1.5 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  type.name,
                                                  style: TextStyle(
                                                    color: textColor,
                                                    fontSize: 16,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: primaryColor,
                                                  size: 20,
                                                ),
                                            ],
                                          ),
                                        ),
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
              ),
              const SizedBox(height: 16),

              // Vehicle Make Input
              _buildField(
                label: AppLocalizations.of(context)!.provideVehicleMake,
                hint: 'e.g., Toyota',
                icon: Icons.directions_car_outlined,
                controller: driverBloc.customMake,
                enabled: driverBloc.choosenVehicleType != null,
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onChange: (v) {
                  driverBloc.add(DriverUpdateEvent());
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Model Input
              _buildField(
                label: AppLocalizations.of(context)!.provideVehicleModel,
                hint: 'e.g., Camry',
                icon: Icons.settings_outlined,
                controller: driverBloc.customModel,
                enabled: driverBloc.customMake.text.isNotEmpty,
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onChange: (v) {
                  driverBloc.add(DriverUpdateEvent());
                },
              ),
              const SizedBox(height: 16),

              // Model Year Input
              _buildField(
                label: AppLocalizations.of(context)!.provideModelYear,
                hint: 'e.g., 2020',
                icon: Icons.calendar_today_outlined,
                controller: driverBloc.vehicleYear,
                enabled: driverBloc.customModel.text.isNotEmpty,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4)
                ],
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onChange: (v) {
                  driverBloc.add(DriverUpdateEvent());
                },
                validator: (string) {
                  if (string != null && string.length <= 3) {
                    return AppLocalizations.of(context)!.validDateValue;
                  } else if (string != null &&
                      string.length == 4 &&
                      int.parse(string) > DateTime.now().year) {
                    return AppLocalizations.of(context)!.validDateValue;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Number Input
              _buildField(
                label: AppLocalizations.of(context)!.provideVehicleNumber,
                hint: 'e.g., XYZ-1234',
                icon: Icons.local_offer_outlined,
                controller: driverBloc.vehicleNumber,
                enabled: driverBloc.vehicleYear.text.isNotEmpty,
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onChange: (v) {
                  driverBloc.add(DriverUpdateEvent());
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Color Input
              _buildField(
                label: AppLocalizations.of(context)!.provideVehicleColor,
                hint: 'e.g., Black',
                icon: Icons.palette_outlined,
                controller: driverBloc.vehicleColor,
                enabled: driverBloc.vehicleNumber.text.isNotEmpty,
                isDark: isDark,
                textColor: textColor,
                primaryColor: primaryColor,
                borderColor: borderColor,
                hintColor: hintColor,
                cardColor: cardColor,
                onChange: (v) {
                  driverBloc.add(DriverUpdateEvent());
                },
              ),
              const SizedBox(height: 24),

              // Save Vehicle Button (always visible at bottom)
              CustomButton(
                  buttonName: AppLocalizations.of(context)!.continueText,
                  borderRadius: 12,
                  height: 52,
                  onTap: () {
                    if (driverBloc.driverProfileformKey.currentState!
                        .validate()) {
                      driverBloc.add(UpdateVehicleEvent(from: args.from));
                    }
                  })
            ],
          );
        },
      ),
    );
  }
}
