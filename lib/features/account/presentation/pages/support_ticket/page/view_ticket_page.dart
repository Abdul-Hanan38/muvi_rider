import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/reply_ticket_widget.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/support_reply_message_list.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/view_ticket_card.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

class ViewTicketPage extends StatelessWidget {
  static const String routeName = '/viewTicketPage';
  final ViewTicketPageArguments args;
  const ViewTicketPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(ViewTicketEvent(id: args.id)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final scaffoldBgColor =
                isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
            final primaryText =
                isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
            final secondaryText =
                isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

            return Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: scaffoldBgColor,
                appBar: AppBar(
                  backgroundColor: scaffoldBgColor,
                  elevation: 0,
                  centerTitle: true,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon:
                          Icon(Icons.arrow_back, color: primaryText, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        text: AppLocalizations.of(context)!.viewTicket,
                        textStyle: TextStyle(
                          color: primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: args.ticketId,
                        textStyle: TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (context.read<AccBloc>().supportTicketData !=
                            null) ...[
                          const SizedBox(height: 16),
                          ViewTicketCard(
                            size: size,
                            ticketData:
                                context.read<AccBloc>().supportTicketData!,
                          ),
                          if (context
                              .read<AccBloc>()
                              .replyMessages
                              .isNotEmpty) ...[
                            const SizedBox(height: 20),
                            SupportReplyMessageList(
                              size: size,
                            ),
                          ],
                          const SizedBox(height: 20),
                          ReplyContainer(
                            id: args.id,
                            size: size,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
