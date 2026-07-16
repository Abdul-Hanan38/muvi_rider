// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/create_ticket_sheet.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/support_empty_widget.dart';
import 'package:restart_tagxi/features/account/presentation/pages/support_ticket/widgets/ticket_card.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';

class SupportTicketPage extends StatefulWidget {
  static const String routeName = '/supportTicketPage';
  final SupportTicketPageArguments args;
  const SupportTicketPage({super.key, required this.args});

  @override
  State<SupportTicketPage> createState() => _SupportTicketPageState();
}

class _SupportTicketPageState extends State<SupportTicketPage> {
  int _activeTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(GetTicketListEvent(isFromAcc: true)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is GetTicketListLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is GetTicketListLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is CreateSupportTicketState) {
            if (context.read<AccBloc>().isTicketSheetOpened) return;

            context.read<AccBloc>().isTicketSheetOpened = true;
            showModalBottomSheet(
              isScrollControlled: true,
              enableDrag: true,
              isDismissible: true,
              context: context,
              builder: (cont) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: CreateTicketSheet(
                    requestId: state.requestId,
                    cont: context,
                    ticketNamesList: state.ticketNamesList,
                    isFromRequest: state.isFromRequest,
                  ),
                );
              },
            ).then((value) {
              if (value != null && value == true) {
                if (context.mounted) {
                  CustomLoader.loader(context);
                }
              }
            }).whenComplete(() {
              if (context.mounted) {
                context.read<AccBloc>().isTicketSheetOpened = false;
              }
            });
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final scaffoldBgColor =
                isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);
            final primaryText =
                isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
            final primaryBlue =
                isDark ? AppColors.secondary : AppColors.primary;

            final ticketsList = context.read<AccBloc>().ticketList;
            final filteredList = ticketsList.where((ticket) {
              bool matchesStatus = true;
              if (_activeTabIndex == 1) {
                matchesStatus = ticket.status == 2;
              } else if (_activeTabIndex == 2) {
                matchesStatus = ticket.status == 3;
              } else if (_activeTabIndex == 3) {
                matchesStatus = ticket.status == 4;
              }

              bool matchesQuery = true;
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                matchesQuery = ticket.ticketId.toLowerCase().contains(query) ||
                    (ticket.ticketTitle != null &&
                        ticket.ticketTitle.title
                            .toString()
                            .toLowerCase()
                            .contains(query)) ||
                    ticket.title.toLowerCase().contains(query);
              }

              return matchesStatus && matchesQuery;
            }).toList();

            return Directionality(
              textDirection: context.read<AccBloc>().textDirection == 'rtl'
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: scaffoldBgColor,
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  backgroundColor: scaffoldBgColor,
                  elevation: 0,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: primaryText),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: MyText(
                    text: AppLocalizations.of(context)!.supportTicket,
                    textStyle: TextStyle(
                      color: primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                body: SizedBox(
                  height: size.height,
                  width: size.width,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        if (filteredList.isNotEmpty) ...[
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return TicketCard(
                                size: size,
                                ticketData: filteredList[index],
                                isFromViewPage: false,
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 16);
                            },
                            itemCount: filteredList.length,
                          ),
                          const SizedBox(height: 120),
                        ] else if (!context.read<AccBloc>().isLoading) ...[
                          const SupportEmptyWidget(),
                        ]
                      ],
                    ),
                  ),
                ),
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton(
                    shape: const CircleBorder(),
                    backgroundColor: primaryBlue,
                    onPressed: () {
                      context.read<AccBloc>().add(
                            CreateSupportTicketEvent(
                              requestId: widget.args.requestId,
                              isFromRequest: widget.args.isFromRequest,
                            ),
                          );
                    },
                    child: const Icon(
                      Icons.add,
                      size: 28,
                      color: Colors.white,
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
