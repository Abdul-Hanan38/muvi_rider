import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../application/acc_bloc.dart';
import '../widget/chat_history_widget.dart';

class AdminChat extends StatelessWidget {
  static const String routeName = '/adminchat';

  const AdminChat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetUserDetailsEvent())
        ..add(GetAdminChatHistoryListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).primaryColorDark),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              titleSpacing: 0,
              title: Text(
                AppLocalizations.of(context)!.adminChat,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: context.read<AccBloc>().scroolController,
                        child: Column(
                          children: [
                            AdminChatHistoryWidget(
                              cont: context,
                              adminChatList:
                                  context.read<AccBloc>().adminChatList,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom Input bar
                    Container(
                      margin: EdgeInsets.only(
                        top: 8,
                        bottom: MediaQuery.paddingOf(context).bottom + 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  // Text Field
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          context.read<AccBloc>().adminchatText,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 15,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppLocalizations.of(context)!
                                            .typeMessage,
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 15,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Blue circular send button
                          GestureDetector(
                            onTap: () {
                              if (context
                                  .read<AccBloc>()
                                  .adminchatText
                                  .text
                                  .isNotEmpty) {
                                context.read<AccBloc>().add(
                                      SendAdminMessageEvent(
                                        newChat: context
                                                .read<AccBloc>()
                                                .adminChatList
                                                .isEmpty
                                            ? '0'
                                            : '1',
                                        message: context
                                            .read<AccBloc>()
                                            .adminchatText
                                            .text,
                                        chatId: context
                                                .read<AccBloc>()
                                                .adminChatList
                                                .isEmpty
                                            ? ""
                                            : context
                                                .read<AccBloc>()
                                                .adminChatList[0]
                                                .conversationId,
                                      ),
                                    );
                                context.read<AccBloc>().adminchatText.clear();
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
