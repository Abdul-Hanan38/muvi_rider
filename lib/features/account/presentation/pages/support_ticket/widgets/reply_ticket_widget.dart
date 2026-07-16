import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/core/utils/custom_textfield.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';

class ReplyContainer extends StatefulWidget {
  final Size size;
  final String id;

  const ReplyContainer({
    super.key,
    required this.size,
    required this.id,
  });

  @override
  State<ReplyContainer> createState() => _ReplyContainerState();
}

class _ReplyContainerState extends State<ReplyContainer> {
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AccBloc>().supportMessageReplyController;
    controller.addListener(_updateCharCount);
    _charCount = controller.text.length;
  }

  void _updateCharCount() {
    if (mounted) {
      setState(() {
        _charCount =
            context.read<AccBloc>().supportMessageReplyController.text.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor =
        isDark ? const Color(0xFF131E35) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F4F6);
    final primaryText =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;

    final bloc = context.read<AccBloc>();
    final isClosed = bloc.supportTicketData?.status == 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.size.width * 0.047),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    MyText(
                      text: AppLocalizations.of(context)!.replyText,
                      textStyle: TextStyle(
                        color: primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.messageText,
                      textStyle: TextStyle(
                        color: primaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const MyText(
                      text: ' *',
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CustomTextField(
                      borderRadius: 12,
                      controller: bloc.supportMessageReplyController,
                      hintText: AppLocalizations.of(context)!.enterMessage,
                      hintTextStyle:
                          TextStyle(fontSize: 14, color: secondaryText),
                      style: TextStyle(fontSize: 14, color: primaryText),
                      maxLine: 5,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryBlue, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: borderColor, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: MyText(
                        text: "$_charCount/1000",
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          BlocConsumer<AccBloc, AccState>(
            listener: (cont, state) {},
            builder: (cont, state) {
              final activeColor = primaryBlue;

              return InkWell(
                onTap: !isClosed
                    ? () {
                        if (bloc
                            .supportMessageReplyController.text.isNotEmpty) {
                          bloc.add(
                            TicketReplyMessageEvent(
                              context: context,
                              id: widget.id,
                              messageText:
                                  bloc.supportMessageReplyController.text,
                            ),
                          );
                        } else {
                          showToast(
                            message: AppLocalizations.of(context)!
                                .fillTheMessageField,
                          );
                        }
                      }
                    : null,
                child: Container(
                  width: widget.size.width * 0.9,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isClosed
                        ? []
                        : [
                            BoxShadow(
                              color: activeColor.withOpacity(0.24),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      MyText(
                        text: AppLocalizations.of(context)!.send,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
