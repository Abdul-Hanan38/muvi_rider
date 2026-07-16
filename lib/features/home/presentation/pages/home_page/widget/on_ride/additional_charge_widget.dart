import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../common/app_colors.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_snack_bar.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../core/utils/custom_textfield.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class AdditionalChargeWidget extends StatelessWidget {
  const AdditionalChargeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F1322) : Colors.white;

    final textFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0),
        width: 1.0,
      ),
    );
    final textFieldFocusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.5,
      ),
    );

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: Container(
              decoration: BoxDecoration(
                color: scaffoldBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: size.height * 0.40,
              width: size.width,
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header Row
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.additionalCharges,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF1F5F9),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E293B),
                              size: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  // Content fields
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: context
                                .read<HomeBloc>()
                                .additionalChargeDetailText,
                            keyboardType: TextInputType.text,
                            hintText:
                                AppLocalizations.of(context)!.chargeDetails,
                            borderRadius: 16,
                            focusedBorder: textFieldFocusBorder,
                            enabledBorder: textFieldBorder,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 8.0),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.primary.withOpacity(0.15)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.assignment_outlined,
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                            prefixConstraints: const BoxConstraints(
                                minWidth: 56, minHeight: 36),
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: context
                                .read<HomeBloc>()
                                .additionalChargeAmountText,
                            keyboardType: TextInputType.number,
                            hintText: AppLocalizations.of(context)!.enterAmount,
                            borderRadius: 16,
                            focusedBorder: textFieldFocusBorder,
                            enabledBorder: textFieldBorder,
                            fillColor: Colors.transparent,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 8.0),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    userData != null
                                        ? userData!.currencySymbol.toString()
                                        : '₹',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            prefixConstraints: const BoxConstraints(
                                minWidth: 56, minHeight: 36),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            borderRadius: 30,
                            height: 52,
                            width: size.width,
                            buttonColor: AppColors.primary,
                            textColor: Colors.white,
                            buttonName: AppLocalizations.of(context)!.confirm,
                            textSize: 16,
                            onTap: () {
                              if (userData!.onTripRequest != null &&
                                  context
                                      .read<HomeBloc>()
                                      .additionalChargeAmountText
                                      .text
                                      .isNotEmpty &&
                                  context
                                      .read<HomeBloc>()
                                      .additionalChargeDetailText
                                      .text
                                      .isNotEmpty) {
                                context.read<HomeBloc>().add(
                                    AdditionalChargeOnTapEvent(
                                        amount: context
                                            .read<HomeBloc>()
                                            .additionalChargeAmountText
                                            .text,
                                        chargeDetails: context
                                            .read<HomeBloc>()
                                            .additionalChargeDetailText
                                            .text,
                                        requestId:
                                            userData!.onTripRequest!.id));
                                Navigator.pop(context);
                              } else {
                                showToast(
                                    message: AppLocalizations.of(context)!
                                        .fillTheDetails);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
