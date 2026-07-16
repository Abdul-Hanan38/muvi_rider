import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/driver_profile_bloc.dart';

class GetCompanyInfo extends StatelessWidget {
  final BuildContext cont;
  final VehicleUpdateArguments args;
  const GetCompanyInfo({super.key, required this.cont, required this.args});

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
    String? Function(String?)? validator,
    void Function(String)? onChange,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

          return Column(
            children: [
              // Company Name Input
              _buildField(
                label: AppLocalizations.of(context)!.provideCompanyName,
                hint: AppLocalizations.of(context)!.enterCompanyName,
                icon: Icons.business_outlined,
                controller: driverBloc.companyName,
                enabled: driverBloc.choosenServiceLocation != null,
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

              // Company Address Input
              _buildField(
                label: AppLocalizations.of(context)!.provideCompanyAddress,
                hint: AppLocalizations.of(context)!.enterCompanyAddress,
                icon: Icons.location_on_outlined,
                controller: driverBloc.companyAddress,
                enabled: driverBloc.companyName.text.isNotEmpty,
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

              // City Input
              _buildField(
                label: AppLocalizations.of(context)!.provideCity,
                hint: AppLocalizations.of(context)!.enterCity,
                icon: Icons.location_city_outlined,
                controller: driverBloc.companyCity,
                enabled: driverBloc.companyAddress.text.isNotEmpty,
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

              // Postal Code Input
              _buildField(
                label: AppLocalizations.of(context)!.providePostalCode,
                hint: AppLocalizations.of(context)!.enterPostalCode,
                icon: Icons.local_post_office_outlined,
                controller: driverBloc.companyPostalCode,
                enabled: driverBloc.companyCity.text.isNotEmpty,
                keyboardType: TextInputType.number,
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
                  if (string != null && string.length > 8) {
                    return AppLocalizations.of(context)!.validPostalCode;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16),

              // Tax Number Input
              _buildField(
                label: AppLocalizations.of(context)!.provideTaxNumber,
                hint: AppLocalizations.of(context)!.enterTaxNumer,
                icon: Icons.description_outlined,
                controller: driverBloc.companyTaxNumber,
                enabled: driverBloc.companyPostalCode.text.isNotEmpty,
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

              CustomButton(
                buttonName: AppLocalizations.of(context)!.continueText,
                borderRadius: 12,
                height: 52,
                onTap: () {
                  if (driverBloc.driverProfileformKey.currentState!
                      .validate()) {
                    driverBloc.add(UpdateVehicleEvent(from: args.from));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
