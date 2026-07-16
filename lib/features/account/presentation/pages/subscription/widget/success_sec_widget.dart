import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class SuccessSecWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  const SuccessSecWidget(
      {super.key, required this.cont, required this.isFromAccPage});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDark ? const Color(0xFF121B2D) : Colors.white;
          final textColor = isDark ? Colors.white : const Color(0xFF171A1F);
          final descColor =
              isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9095A1);

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                Center(
                  child: Image.asset(
                    AppImages.subcriptionPlanActive,
                    width: size.width * 0.7,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  width: size.width,
                  margin: EdgeInsets.all(size.width * 0.05),
                  padding: EdgeInsets.all(size.width * 0.06),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.2),
                              Colors.green.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: size.height * 0.025),
                      MyText(
                        text: AppLocalizations.of(context)!.subscriptionSuccess,
                        textStyle: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (userData!.subscription != null) ...[
                        SizedBox(height: size.height * 0.015),
                        MyText(
                          text:
                              '${AppLocalizations.of(context)!.subscriptionSuccessDescOne.replaceAll("\\n", "\n").replaceAll("A", userData!.subscription!.data.subscriptionName)} ${userData!.subscription!.data.expiredAt}.${AppLocalizations.of(context)!.subscriptionSuccessDescTwo.replaceAll("\\n", "\n")}',
                          textStyle: TextStyle(
                            color: descColor,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 6,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
