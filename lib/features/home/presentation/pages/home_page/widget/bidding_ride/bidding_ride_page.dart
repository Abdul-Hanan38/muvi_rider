import 'package:flutter/material.dart';
import 'package:restart_tagxi/features/home/presentation/pages/home_page/widget/bidding_ride/bidding_ride_list_widget.dart';

class BiddingRidePage extends StatelessWidget {
  final BuildContext cont;
  const BiddingRidePage({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: BiddingRideListWidget(cont: cont),
      ),
    );
  }
}
