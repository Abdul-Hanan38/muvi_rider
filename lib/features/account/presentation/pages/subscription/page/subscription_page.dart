import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/utils/custom_loader.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../widget/expired_sec_widget.dart';
import '../widget/no_subscription_widget.dart';
import '../widget/subscription_list_widget.dart';
import '../widget/success_sec_widget.dart';

class SubscriptionPage extends StatelessWidget {
  static const String routeName = '/subscriptionPage';
  final SubscriptionPageArguments args;
  const SubscriptionPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(GetSubscriptionListEvent())
        ..add(GetWalletHistoryListEvent(pageIndex: 1)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          final accBloc = context.read<AccBloc>();
          if (state is SubscriptionPayLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is SubscriptionPayLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is SubscriptionPaySuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is WalletEmptyState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .lowWalletBalanceForSubscription),
              ),
            );
          }
          if (state is UserUnauthenticatedState) {
            await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
          if (state is WalletPageReUpdateState) {
            accBloc.showRefresh = true;
            accBloc.add(
              AddMoneyWebViewUrlEvent(
                currencySymbol: state.currencySymbol,
                from: '2',
                requestId: state.requestId,
                money: state.money,
                planId: state.planId,
                url: state.url,
                userId: state.userId,
                context: context,
              ),
            );
          }
          if (state is PaymentUpdateState) {
            if (state.status) {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentSuccess,
                            fit: BoxFit.contain,
                            width: size.width * 0.5,
                          ),
                          SizedBox(height: size.width * 0.02),
                          Text(
                            AppLocalizations.of(context)!.paymentSuccess,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context
                                  .read<AccBloc>()
                                  .add(AccGetUserDetailsEvent());
                            },
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevents closing the dialog by tapping outside
                builder: (_) {
                  return AlertDialog(
                    content: SizedBox(
                      height: size.height * 0.45,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppImages.paymentFail,
                            fit: BoxFit.contain,
                            width: size.width * 0.4,
                          ),
                          SizedBox(height: size.width * 0.02),
                          Text(
                            AppLocalizations.of(context)!.paymentFailed,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.width * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(AppLocalizations.of(context)!.ok),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final backgroundColor =
              isDark ? const Color(0xFF070D19) : const Color(0xFFF8F9FC);

          final isNoSubscription = userData != null &&
              userData!.subscription == null &&
              !accBloc.isPlansChooseds;
          final isSuccess = (userData != null && userData!.isSubscribed!) ||
              (accBloc.subscriptionSuccessData != null &&
                  accBloc.subscriptionSuccessData!.isSubscribed == '1');
          final isExpired = (userData != null && userData!.isExpired!) &&
              !accBloc.isPlansChooseds;
          final isListActive = !isNoSubscription && !isSuccess && !isExpired;

          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: backgroundColor,
              centerTitle: true,
              leadingWidth: 72,
              leading: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InkWell(
                    onTap: () {
                      if (accBloc.isPlansChooseds) {
                        accBloc.add(ChoosePlanEvent(isPlansChoosed: false));
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(
                    text: AppLocalizations.of(context)!.subscription,
                    textStyle: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isListActive) ...[
                    const SizedBox(height: 4),
                    MyText(
                      text: AppLocalizations.of(context)!
                          .subscriptionChoosePlanText,
                      textStyle: TextStyle(
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () {
                  Future<void> onrefresh() async {
                    accBloc.add(AccGetUserDetailsEvent());
                  }

                  return onrefresh();
                },
                child: isNoSubscription
                    ? NoSubscriptionWidget(
                        cont: context, isFromAccPage: args.isFromAccPage)
                    : isSuccess
                        ? SuccessSecWidget(
                            cont: context, isFromAccPage: args.isFromAccPage)
                        : (userData != null && !userData!.hasSubscription!) ||
                                accBloc.isPlansChooseds
                            ? SubscriptionListWidget(
                                cont: context,
                                isFromAccPage: args.isFromAccPage,
                                currencySymbol: userData!.currencySymbol,
                                subscriptionListDatas: accBloc.subscriptionList)
                            : isExpired
                                ? ExpiredSecWidget(
                                    isFromAccPage: args.isFromAccPage,
                                    accBloc: accBloc,
                                  )
                                : SubscriptionListWidget(
                                    cont: context,
                                    isFromAccPage: args.isFromAccPage,
                                    currencySymbol: userData!.currencySymbol,
                                    subscriptionListDatas:
                                        accBloc.subscriptionList),
              ),
            ),
          );
        }),
      ),
    );
  }
}
