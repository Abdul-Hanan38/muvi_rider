import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/admin_chat_model.dart';

class AdminChatHistoryWidget extends StatelessWidget {
  final BuildContext cont;
  final List<ChatData> adminChatList;
  const AdminChatHistoryWidget(
      {super.key, required this.cont, required this.adminChatList});

  Widget _buildDateSeparator(BuildContext context, String text, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: MyText(
          text: text,
          textStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return adminChatList.isNotEmpty
              ? RawScrollbar(
                  radius: const Radius.circular(20),
                  child: ListView.builder(
                    itemCount: adminChatList.length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context
                            .read<AccBloc>()
                            .scroolController
                            .hasClients) {
                          context.read<AccBloc>().scroolController.animateTo(
                              context
                                  .read<AccBloc>()
                                  .scroolController
                                  .position
                                  .maxScrollExtent,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease);
                        }
                      });

                      if (userData == null) {
                        return const Scaffold(
                          body: Loader(),
                        );
                      }

                      final isMe = adminChatList[index].senderId ==
                          userData!.userId.toString();
                      return Column(
                        children: [
                          if (index == 0)
                            _buildDateSeparator(context, "Today", isDark),
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              constraints:
                                  BoxConstraints(maxWidth: size.width * 0.75),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF0F4BEB)
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9)),
                                borderRadius: isMe
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(4),
                                      )
                                    : const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                              ),
                              child: Text(
                                adminChatList[index].message,
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A)),
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isMe ? 0 : 12,
                                right: isMe ? 12 : 0,
                                bottom: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    adminChatList[index].userTimezone,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                      fontSize: 11,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.done_all,
                                      color: Color(0xFF0F4BEB),
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                )
              : const SizedBox();
        },
      ),
    );
  }
}
