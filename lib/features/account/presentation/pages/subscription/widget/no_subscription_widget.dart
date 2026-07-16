import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';

class NoSubscriptionWidget extends StatelessWidget {
  final BuildContext cont;
  final bool isFromAccPage;
  const NoSubscriptionWidget(
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
          final primaryColor = isDark ? AppColors.secondary : AppColors.primary;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                Center(
                  child: Image.asset(
                    AppImages.subcriptionPlan,
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
                              primaryColor.withOpacity(0.2),
                              primaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.assignment_late_outlined,
                          color: primaryColor,
                          size: 32,
                        ),
                      ),
                      SizedBox(height: size.height * 0.025),
                      MyText(
                        text: AppLocalizations.of(context)!.noSubscription,
                        textStyle: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.015),
                      MyText(
                        text:
                            AppLocalizations.of(context)!.noSubscriptionContent,
                        textStyle: TextStyle(
                          color: descColor,
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 5,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.04),
                      InkWell(
                        onTap: () {
                          context.read<AccBloc>().add(
                                ChoosePlanEvent(isPlansChoosed: true),
                              );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.choosePlan,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Positioned(
                                right: 0,
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
