import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class AddFleetDriverWidget extends StatelessWidget {
  final BuildContext cont;
  const AddFleetDriverWidget({super.key, required this.cont});

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
    final iconBgColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFEFF6FF);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    final inputBorderColor =
        isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0);
    final hintColor =
        isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          return SafeArea(
            child: Scaffold(
              backgroundColor: scaffoldBgColor,
              body: SizedBox(
                height: size.height,
                width: size.width,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Custom Header
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Icon(
                                Icons.arrow_back,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                                size: 20,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.addDriver,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!
                                    .addDriverDetailsText,
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

                    // Input Card Section
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.05),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                          child: Column(
                            children: [
                              _buildInputRow(
                                context,
                                icon: Icons.person_outline,
                                label: AppLocalizations.of(context)!.driverName,
                                hint: AppLocalizations.of(context)!
                                    .enterDriverName,
                                controller: accBloc.driverNameController,
                                isDark: isDark,
                                textColor: textColor,
                                iconBgColor: iconBgColor,
                                primaryColor: primaryColor,
                                inputBorderColor: inputBorderColor,
                                hintColor: hintColor,
                              ),
                              _buildDivider(isDark),
                              _buildInputRow(
                                context,
                                icon: Icons.phone_outlined,
                                label:
                                    AppLocalizations.of(context)!.driverMobile,
                                hint: AppLocalizations.of(context)!
                                    .enterDriverMobile,
                                controller: accBloc.driverMobileController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                isDark: isDark,
                                textColor: textColor,
                                iconBgColor: iconBgColor,
                                primaryColor: primaryColor,
                                inputBorderColor: inputBorderColor,
                                hintColor: hintColor,
                              ),
                              _buildDivider(isDark),
                              _buildInputRow(
                                context,
                                icon: Icons.mail_outline,
                                label:
                                    AppLocalizations.of(context)!.driverEmail,
                                hint: AppLocalizations.of(context)!
                                    .enterDriverEmail,
                                controller: accBloc.driverEmailController,
                                isDark: isDark,
                                textColor: textColor,
                                iconBgColor: iconBgColor,
                                primaryColor: primaryColor,
                                inputBorderColor: inputBorderColor,
                                hintColor: hintColor,
                              ),
                              _buildDivider(isDark),
                              _buildInputRow(
                                context,
                                icon: Icons.location_on_outlined,
                                label:
                                    AppLocalizations.of(context)!.driverAddress,
                                hint: AppLocalizations.of(context)!
                                    .enterDriverAddress,
                                controller: accBloc.driverAddressController,
                                isDark: isDark,
                                textColor: textColor,
                                iconBgColor: iconBgColor,
                                primaryColor: primaryColor,
                                inputBorderColor: inputBorderColor,
                                hintColor: hintColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Driver Button
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.05),
                      child: InkWell(
                        onTap: () {
                          if (accBloc.driverAddressController.text.isNotEmpty &&
                              accBloc.driverEmailController.text.isNotEmpty &&
                              accBloc.driverMobileController.text.isNotEmpty &&
                              accBloc.driverNameController.text.isNotEmpty) {
                            accBloc.add(AddDriverEvent());
                            Navigator.pop(context);
                          } else {
                            showToast(
                                message: AppLocalizations.of(context)!
                                    .enterRequiredField);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
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
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF001CAD)
                                          .withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.addDriver,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    required bool isDark,
    required Color textColor,
    required Color iconBgColor,
    required Color primaryColor,
    required Color inputBorderColor,
    required Color hintColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: inputBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: inputBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: hint,
                  hintTextStyle: TextStyle(
                    color: hintColor,
                    fontSize: 14,
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                  fillColor: isDark ? const Color(0xFF131E35) : Colors.white,
                  filled: true,
                  controller: controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF1F5F9),
      thickness: 1,
      height: 1,
    );
  }
}
