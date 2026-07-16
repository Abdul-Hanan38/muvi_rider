import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/features/home/application/home_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../../common/app_colors.dart';

class ChatPageWidget extends StatelessWidget {
  const ChatPageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor = isDark ? const Color(0xFF0F1322) : Colors.white;

    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      final bloc = context.read<HomeBloc>();

      return Scaffold(
        backgroundColor: scaffoldBgColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: scaffoldBgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              size: 18,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(ChatSeenEvent());
              bloc.add(ShowChatEvent());
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              // User avatar
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF312E81)
                      : const Color(0xFFE8DBFF),
                ),
                child: (userData!.onTripRequest!.userImage.isEmpty)
                    ? Icon(
                        Icons.person,
                        size: 24,
                        color: isDark
                            ? const Color(0xFFC084FC)
                            : const Color(0xFF7C3AED),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: userData!.onTripRequest!.userImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: Loader(),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 24,
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : const Color(0xFF7C3AED),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              // User Name + Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userData!.onTripRequest!.userName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.call_outlined,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                size: 22,
              ),
              onPressed: () async {
                final mobile = userData!.onTripRequest!.userMobile;
                if (mobile.isNotEmpty) {
                  await launchUrl(Uri.parse('tel:$mobile'));
                }
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: size.width,
                height: 1, // Thin divider below appbar
                color:
                    isDark ? const Color(0xFF232A45) : const Color(0xFFE2E8F0),
              ),
              // Chat messages
              Expanded(
                child: SingleChildScrollView(
                  controller: bloc.chatScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _chatHistoryData(size, context, bloc.chats),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Input bar
              _inputBar(context, size, bloc),
            ],
          ),
        ),
      );
    });
  }

  Widget _inputBar(BuildContext context, Size size, HomeBloc bloc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1322) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF232A45) : const Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF161B2E) : const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF232A45)
                      : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Blue Plus Action Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: bloc.chatField,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.typeMessage,
                        hintStyle: TextStyle(
                          color: isDark
                              ? const Color(0xFF475569)
                              : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Smiley Icon
                  Icon(
                    Icons.sentiment_satisfied_alt_rounded,
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFF94A3B8),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Circle Button
          GestureDetector(
            onTap: () {
              if (bloc.chatField.text.isNotEmpty) {
                bloc.add(SendChatEvent(message: bloc.chatField.text));
                bloc.chatField.clear();
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatHistoryData(
      Size size, BuildContext context, List<dynamic> chatList) {
    if (chatList.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RawScrollbar(
      radius: const Radius.circular(20),
      child: ListView.builder(
        itemCount: chatList.length,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final bloc = context.read<HomeBloc>();
            if (bloc.chatScrollController.hasClients) {
              bloc.chatScrollController.animateTo(
                bloc.chatScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            }
          });

          final isMe = chatList[index]['from_type'] != 1;
          Color bubbleBgColor = isMe
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9));
          Color textColor = isMe
              ? Colors.white
              : (isDark ? Colors.white : const Color(0xFF0F172A));

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: size.width * 0.72),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: bubbleBgColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isMe
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      chatList[index]['message'],
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp row
                Row(
                  mainAxisAlignment:
                      isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Text(
                      chatList[index]['converted_created_at'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      // Blue Double checkmark icon for sent messages
                      const Icon(
                        Icons.done_all_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
