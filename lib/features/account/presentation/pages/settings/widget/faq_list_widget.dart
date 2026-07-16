import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import '../../../../domain/models/faq_model.dart';

class FaqDataListWidget extends StatelessWidget {
  final BuildContext cont;
  final List<FaqData> faqDataList;
  const FaqDataListWidget(
      {super.key, required this.cont, required this.faqDataList});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<AccBloc>(),
      child: BlocBuilder<AccBloc, AccState>(
        builder: (context, state) {
          return faqDataList.isNotEmpty
              ? Expanded(
                  child: RawScrollbar(
                    radius: const Radius.circular(20),
                    child: ListView.builder(
                      itemCount: faqDataList.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final isSelected =
                            context.read<AccBloc>().choosenFaqIndex == index;
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        final cardBgColor = isSelected
                            ? (isDark
                                ? const Color(0xFF1B243B)
                                : const Color(0xFFF5F7FF))
                            : (isDark ? const Color(0xFF121B2D) : Colors.white);

                        final borderColor = isSelected
                            ? AppColors.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE5E7EB));

                        final questionColor =
                            isDark ? Colors.white : const Color(0xFF171A1F);
                        final answerColor = const Color(0xFF9095A1);

                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            if (isSelected) {
                              context
                                  .read<AccBloc>()
                                  .add(FaqOnTapEvent(selectedFaqIndex: -1));
                            } else {
                              context
                                  .read<AccBloc>()
                                  .add(FaqOnTapEvent(selectedFaqIndex: index));
                            }
                          },
                          child: Container(
                            width: size.width,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected || isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (isSelected)
                                      Container(
                                        width: 4,
                                        color: AppColors.primary,
                                      ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: MyText(
                                                    text: faqDataList[index]
                                                        .question,
                                                    textStyle: TextStyle(
                                                      color: questionColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                                Icon(
                                                  isSelected
                                                      ? Icons
                                                          .keyboard_arrow_up_rounded
                                                      : Icons
                                                          .keyboard_arrow_down_rounded,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : const Color(0xFF9CA3AF),
                                                  size: 24,
                                                ),
                                              ],
                                            ),
                                            if (isSelected) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0),
                                                child: Divider(
                                                  color: isDark
                                                      ? const Color(0xFF1E293B)
                                                      : const Color(0xFFE5E7EB),
                                                  height: 1,
                                                ),
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 24,
                                                    width: 24,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const MyText(
                                                      text: 'Q',
                                                      textStyle: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: MyText(
                                                      text: faqDataList[index]
                                                          .question,
                                                      textStyle: TextStyle(
                                                        color: questionColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 24,
                                                    width: 24,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF374151)
                                                          : const Color(
                                                              0xFFE5E7EB),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: MyText(
                                                      text: 'A',
                                                      textStyle: TextStyle(
                                                        color: isDark
                                                            ? Colors.white
                                                            : Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: MyText(
                                                      text: faqDataList[index]
                                                          .answer,
                                                      textStyle: TextStyle(
                                                        color: answerColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : SizedBox(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: size.height * 0.08,
                        ),
                        Image.asset(
                          AppImages.faqNoDataImage,
                          height: 200,
                          width: 200,
                        ),
                        SizedBox(
                          height: size.height * 0.04,
                        ),
                        Text(AppLocalizations.of(context)!.noDataFound),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
