import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/common.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/domain/models/ticket_names_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class CreateTicketSheet extends StatefulWidget {
  final BuildContext cont;
  final List<TicketNamesList> ticketNamesList;
  final String requestId;
  final bool isFromRequest;
  final int? index;
  final int? historyPagenumber;
  const CreateTicketSheet({
    super.key,
    required this.cont,
    required this.ticketNamesList,
    required this.requestId,
    required this.isFromRequest,
    this.index,
    this.historyPagenumber,
  });

  @override
  State<CreateTicketSheet> createState() => _CreateTicketSheetState();
}

class _CreateTicketSheetState extends State<CreateTicketSheet> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sheetBgColor = isDark ? const Color(0xFF131E35) : Colors.white;
    final textDarkColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final hintTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider.value(
      value: widget.cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final accBloc = context.read<AccBloc>();

          TicketNamesList? selectedTitle;
          try {
            selectedTitle = widget.ticketNamesList
                .firstWhere((e) => e.title == accBloc.selectedTicketTitle);
          } catch (_) {
            selectedTitle = null;
          }

          final createTicketSub =
              AppLocalizations.of(context)!.createTicketReturnText;

          return Container(
            width: size.width,
            constraints: BoxConstraints(
              maxHeight: size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: sheetBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Drag Handle Indicator
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEFF6FF),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.headset_mic_outlined,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF001CAD),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: AppLocalizations.of(context)!.createTicket,
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDarkColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            MyText(
                              text: createTicketSub,
                              textStyle: TextStyle(
                                fontSize: 13,
                                color: hintTextColor,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.04),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: isDark
                                ? Colors.white70
                                : Colors.black.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Section (Scrollable)
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title Field Label
                          Row(
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.title,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDarkColor,
                                ),
                              ),
                              const MyText(
                                text: ' *',
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Custom Inline Dropdown for Tickets (matching WalletTransferMoneyWidget style)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B).withOpacity(0.3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isDropdownOpen
                                    ? primaryColor
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : AppColors.borderColors),
                                width: _isDropdownOpen ? 1.5 : 1.0,
                              ),
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
                                        horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.local_activity_outlined,
                                          color: hintTextColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: MyText(
                                            text: selectedTitle != null
                                                ? selectedTitle.title
                                                : AppLocalizations.of(context)!
                                                    .selectTitle,
                                            textStyle: TextStyle(
                                              color: selectedTitle != null
                                                  ? textDarkColor
                                                  : hintTextColor
                                                      .withOpacity(0.6),
                                              fontSize: 14,
                                              fontWeight: selectedTitle != null
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          _isDropdownOpen
                                              ? Icons.keyboard_arrow_up_rounded
                                              : Icons
                                                  .keyboard_arrow_down_rounded,
                                          color: hintTextColor,
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
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : AppColors.borderColors,
                                  ),
                                  ...widget.ticketNamesList
                                      .map((item) => _buildDropdownItem(
                                            context: context,
                                            item: item,
                                            isSelected:
                                                accBloc.selectedTicketTitle ==
                                                    item.title,
                                            isLast:
                                                widget.ticketNamesList.last ==
                                                    item,
                                            fieldBorder: isDark
                                                ? const Color(0xFF1E293B)
                                                : AppColors.borderColors,
                                            textDarkColor: textDarkColor,
                                            primaryColor: primaryColor,
                                            onTap: () {
                                              context.read<AccBloc>().add(
                                                    TicketTitleChangeEvent(
                                                      changedTitle: item.title,
                                                      id: item.id,
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
                          const SizedBox(height: 20),

                          // Description Label
                          Row(
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!.description,
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textDarkColor,
                                ),
                              ),
                              const MyText(
                                text: ' *',
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Description Field
                          Stack(
                            children: [
                              CustomTextField(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 14, 16, 36),
                                controller: context
                                    .read<AccBloc>()
                                    .supportDescriptionController,
                                hintText: AppLocalizations.of(context)!
                                    .enterDescription,
                                maxLine: 4,
                                maxLength: 500,
                                counterText: "",
                                hintTextStyle: TextStyle(
                                  fontSize: 14,
                                  color: hintTextColor.withOpacity(0.6),
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textDarkColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.edit_outlined,
                                  color: hintTextColor,
                                ),
                                fillColor: isDark
                                    ? const Color(0xFF1E293B).withOpacity(0.3)
                                    : Colors.transparent,
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : AppColors.borderColors,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : AppColors.borderColors,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: context
                                      .read<AccBloc>()
                                      .supportDescriptionController,
                                  builder: (context, value, child) {
                                    return MyText(
                                      text: "${value.text.length}/500",
                                      textStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: hintTextColor.withOpacity(0.6),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Attachments Label
                          MyText(
                            text: AppLocalizations.of(context)!.attachments,
                            textStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textDarkColor,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Attachments Dotted Box
                          InkWell(
                            onTap: accBloc.ticketAttachments.length >= 8
                                ? null
                                : () {
                                    accBloc.add(AddAttachmentTicketEvent(
                                        context: context));
                                  },
                            child: DottedBorder(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : AppColors.borderColors,
                              strokeWidth: 1.5,
                              dashPattern: const [6, 4],
                              borderType: BorderType.RRect,
                              radius: const Radius.circular(12),
                              child: Container(
                                width: size.width,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 24, horizontal: 16),
                                color: isDark
                                    ? const Color(0xFF1E293B).withOpacity(0.1)
                                    : Colors.transparent,
                                child: accBloc.ticketAttachments.isEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.cloud_upload_outlined,
                                            color: primaryColor,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 10),
                                          RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .createTicketFileDragDropText,
                                              style: TextStyle(
                                                color: textDarkColor,
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .createTicketBrowseText,
                                                  style: TextStyle(
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .createTicketMaxFilesUploadText,
                                            textStyle: TextStyle(
                                              fontSize: 12,
                                              color: hintTextColor
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.insert_drive_file_outlined,
                                            color: primaryColor,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          MyText(
                                            text: AppLocalizations.of(context)!
                                                .createTicketFilesUploadedText
                                                .replaceAll(
                                                    '111',
                                                    accBloc.ticketAttachments
                                                        .length
                                                        .toString()),
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: textDarkColor,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  accBloc.add(
                                                      ClearAttachmentEvent());
                                                },
                                                child: MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .clearAll,
                                                  textStyle: const TextStyle(
                                                    color: AppColors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (accBloc.ticketAttachments
                                                      .length <
                                                  8) ...[
                                                const SizedBox(width: 16),
                                                TextButton(
                                                  onPressed: () {
                                                    accBloc.add(
                                                        AddAttachmentTicketEvent(
                                                            context: context));
                                                  },
                                                  child: MyText(
                                                    text: AppLocalizations.of(
                                                            context)!
                                                        .addMore,
                                                    textStyle: TextStyle(
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Create Ticket Action Button
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
                  child: CustomButton(
                    buttonName: AppLocalizations.of(context)!.createTicket,
                    width: size.width,
                    height: 52,
                    borderRadius: 12,
                    textSize: 16,
                    onTap: () {
                      if ((accBloc.selectedTicketTitleId != null &&
                              accBloc.selectedTicketTitleId!.isNotEmpty) &&
                          accBloc
                              .supportDescriptionController.text.isNotEmpty) {
                        accBloc.add(
                          MakeTicketSubmitEvent(
                            description:
                                accBloc.supportDescriptionController.text,
                            titleId: accBloc.selectedTicketTitleId!,
                            attachement: accBloc.ticketAttachments,
                            requestId: widget.requestId,
                            isFromRequest: widget.isFromRequest,
                            index: widget.index,
                            pageNumber: widget.historyPagenumber,
                          ),
                        );
                        Navigator.pop(context, true);
                      } else {
                        showToast(
                            message: AppLocalizations.of(context)!
                                .fillTheRequiredField);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownItem({
    required BuildContext context,
    required TicketNamesList item,
    required bool isSelected,
    required bool isLast,
    required Color fieldBorder,
    required Color textDarkColor,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: item.title,
                    textStyle: TextStyle(
                      color: textDarkColor,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: primaryColor,
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
}
