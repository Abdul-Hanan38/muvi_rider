// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class WalletTransferMoneyWidget extends StatefulWidget {
  final BuildContext cont;
  const WalletTransferMoneyWidget({super.key, required this.cont});

  @override
  State<WalletTransferMoneyWidget> createState() =>
      _WalletTransferMoneyWidgetState();
}

class _WalletTransferMoneyWidgetState extends State<WalletTransferMoneyWidget> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.watch<AccBloc>();
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final sheetBg = isDark ? const Color(0xFF0D1623) : Colors.white;
          final fieldBg =
              isDark ? const Color(0xFF162032) : const Color(0xFFF8FAFC);
          final fieldBorder = isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0);
          final labelColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final hintColor =
              isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
          final iconBg =
              isDark ? const Color(0xFF1E3A5F) : const Color(0xFFEFF6FF);
          final iconColor =
              isDark ? const Color(0xFF60A5FA) : const Color(0xFF0B2EC2);
          final primaryBlue =
              isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B2EC2);

          // Build label and icon for the currently selected item
          final selectedLabel = _getLabelForValue(
            accBloc.dropdownValue,
            context,
          );
          final selectedIcon = _getIconForValue(accBloc.dropdownValue);

          return SafeArea(
            child: Container(
              padding: MediaQuery.viewInsetsOf(context),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row: icon + close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: hintColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        MyText(
                          text: AppLocalizations.of(context)!.transferMoney,
                          textStyle: TextStyle(
                            color: labelColor,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text:
                              AppLocalizations.of(context)!.selectRecipientType,
                          textStyle: TextStyle(
                            color: hintColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recipient Type Label
                        MyText(
                          text: AppLocalizations.of(context)!.recipientTypeText,
                          textStyle: TextStyle(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Custom Inline Dropdown
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: fieldBorder, width: 1),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Selected / Header row
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isDropdownOpen = !_isDropdownOpen;
                                  });
                                },
                                borderRadius: _isDropdownOpen
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      )
                                    : BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: iconBg,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          selectedIcon,
                                          color: iconColor,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: MyText(
                                          text: selectedLabel,
                                          textStyle: TextStyle(
                                            color: labelColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _isDropdownOpen
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: hintColor,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Expanded items list
                              if (_isDropdownOpen) ...[
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: fieldBorder,
                                ),
                                ...accBloc.dropdownItems.map((item) =>
                                    _buildDropdownItem(
                                      context: context,
                                      value: item.value ?? '',
                                      label: _getLabelForValue(
                                          item.value ?? '', context),
                                      subtitle: _getSubtitleForValue(
                                          item.value ?? '', context),
                                      icon: _getIconForValue(item.value ?? ''),
                                      isSelected:
                                          accBloc.dropdownValue == item.value,
                                      isLast:
                                          accBloc.dropdownItems.last == item,
                                      fieldBorder: fieldBorder,
                                      labelColor: labelColor,
                                      hintColor: hintColor,
                                      iconBg: iconBg,
                                      iconColor: iconColor,
                                      primaryBlue: primaryBlue,
                                      onTap: () {
                                        context.read<AccBloc>().add(
                                              TransferMoneySelectedEvent(
                                                selectedTransferAmountMenuItem:
                                                    item.value!,
                                              ),
                                            );
                                        setState(() {
                                          _isDropdownOpen = false;
                                        });
                                      },
                                    )),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Amount Label
                        MyText(
                          text: AppLocalizations.of(context)!.amountText,
                          textStyle: TextStyle(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Amount Field
                        TextFormField(
                          controller: accBloc.transferAmount,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterAmount,
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 14,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: fieldBg,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: fieldBorder, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: primaryBlue, width: 1.5),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: MyText(
                                text: accBloc.walletResponse?.currencySymbol ??
                                    '₹',
                                textStyle: TextStyle(
                                  color: iconColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(maxWidth: 56),
                            suffixText: '.00',
                            suffixStyle: TextStyle(
                              color: hintColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mobile Number Label
                        MyText(
                          text: AppLocalizations.of(context)!.mobileNumber,
                          textStyle: TextStyle(
                            color: labelColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Mobile Number Field
                        TextFormField(
                          controller: accBloc.transferPhonenumber,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context)!.enterMobileNumber,
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 14,
                            ),
                            counterText: '',
                            filled: true,
                            fillColor: fieldBg,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: fieldBorder, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: primaryBlue, width: 1.5),
                            ),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.phone_android_rounded,
                                color: iconColor,
                                size: 16,
                              ),
                            ),
                            prefixIconConstraints:
                                const BoxConstraints(maxWidth: 56),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Security Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: fieldBorder, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: iconColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .transferSecureAndEncryptedText,
                                textStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Action Buttons Row
                        Row(
                          children: [
                            // Cancel Button
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: MyText(
                                    text: AppLocalizations.of(context)!.cancel,
                                    textStyle: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Transfer Money Button
                            Expanded(
                              child: InkWell(
                                onTap: accBloc.isLoading
                                    ? null
                                    : () {
                                        if (accBloc.transferAmount.text == '' ||
                                            accBloc.transferPhonenumber.text ==
                                                '') {
                                          return;
                                        }
                                        context.read<AccBloc>().add(
                                              MoneyTransferedEvent(
                                                transferAmount:
                                                    accBloc.transferAmount.text,
                                                role: accBloc.dropdownValue,
                                                transferMobile: accBloc
                                                    .transferPhonenumber.text,
                                              ),
                                            );
                                        context
                                            .read<AccBloc>()
                                            .add(UpdateEvent());
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: accBloc.isLoading
                                        ? primaryBlue.withValues(alpha: 0.6)
                                        : primaryBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: accBloc.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : MyText(
                                          text: AppLocalizations.of(context)!
                                              .transferMoney,
                                          textStyle: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownItem({
    required BuildContext context,
    required String value,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isLast,
    required Color fieldBorder,
    required Color labelColor,
    required Color hintColor,
    required Color iconBg,
    required Color iconColor,
    required Color primaryBlue,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: label,
                        textStyle: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: subtitle,
                        textStyle: TextStyle(
                          color: hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: primaryBlue,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, thickness: 1, color: fieldBorder),
      ],
    );
  }

  String _getLabelForValue(String value, BuildContext context) {
    switch (value) {
      case 'user':
        return AppLocalizations.of(context)!.user;
      case 'driver':
        return AppLocalizations.of(context)!.driver;
      default:
        return value;
    }
  }

  String _getSubtitleForValue(String value, BuildContext context) {
    switch (value) {
      case 'user':
        return 'Transfer to registered users';
      case 'driver':
        return 'Transfer to registered drivers';
      default:
        return '';
    }
  }

  IconData _getIconForValue(String value) {
    switch (value) {
      case 'user':
        return Icons.person_outline_rounded;
      case 'driver':
        return Icons.drive_eta_rounded;
      default:
        return Icons.person_outline_rounded;
    }
  }
}
