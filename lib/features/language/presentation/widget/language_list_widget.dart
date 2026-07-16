import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/localization.dart';
import '../../../../common/app_colors.dart';
import '../../../../core/utils/custom_text.dart';
import '../../application/language_bloc.dart';
import '../../domain/models/language_listing_model.dart';

class LanguageListWidget extends StatelessWidget {
  final BuildContext cont;
  final List<LocaleLanguageList> languageList;
  const LanguageListWidget(
      {super.key, required this.cont, required this.languageList});

  String _getLanguageInitial(String lang) {
    switch (lang) {
      case 'ar':
        return 'ع';
      case 'fr':
        return 'A';
      case 'es':
        return 'ñ';
      case 'sq':
        return 'Ë';
      case 'az':
        return 'Ə';
      case 'pt':
        return 'P';
      case 'ro':
        return 'R';
      case 'ru':
        return 'Я';
      case 'sw':
        return 'S';
      case 'th':
        return 'ท';
      case 'tr':
        return 'T';
      case 'bn':
        return 'ব';
      case 'ur':
        return 'ا';
      case 'vi':
        return 'V';
      case 'zh':
        return '中';
      case 'nl':
        return 'N';
      case 'de':
        return 'D';
      case 'hi':
        return 'ह';
      case 'id':
        return 'I';
      case 'it':
        return 'I';
      case 'ko':
        return '한';
      case 'ms':
        return 'M';
      case 'ja':
        return '日';
      case 'pl':
        return 'P';
      case 'fa':
        return 'ف';
      case 'am':
        return 'አ';
      case 'fil':
        return 'F';
      default:
        return lang.isNotEmpty ? lang.toUpperCase().substring(0, 1) : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<LanguageBloc>(),
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return RawScrollbar(
            radius: const Radius.circular(20),
            child: ListView.builder(
              itemCount: languageList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final isSelected =
                    context.read<LanguageBloc>().selectedIndex == index;
                final isDark = Theme.of(context).brightness == Brightness.dark;

                final cardBgColor = isSelected
                    ? (isDark
                        ? const Color(0xFF18233C)
                        : const Color(0xFFF0F2FF))
                    : (isDark ? const Color(0xFF131E35) : Colors.white);

                final cardBorderColor = isSelected
                    ? AppColors.primary
                    : (isDark
                        ? const Color(0xFF1F2D4A)
                        : const Color(0xFFF1F3F6));

                final borderW = isSelected ? 1.5 : 1.0;
                final textDarkColor =
                    isDark ? Colors.white : const Color(0xFF19191F);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () {
                      context.read<LanguageBloc>().add(
                          LanguageSelectEvent(selectedLanguageIndex: index));
                      context.read<LocalizationBloc>().add(
                          LocalizationInitialEvent(
                              isDark: Theme.of(context).brightness ==
                                  Brightness.dark,
                              locale: Locale(languageList[index].lang)));
                    },
                    child: Container(
                      width: size.width,
                      padding: EdgeInsets.symmetric(
                        vertical: size.width * 0.035,
                        horizontal: size.width * 0.04,
                      ),
                      margin: EdgeInsets.only(bottom: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: cardBorderColor, width: borderW),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected
                                  ? null
                                  : (isDark
                                      ? const Color(0xFF1F2D4A)
                                      : const Color(0xFFF1F3F6)),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: (languageList[index].lang == 'en')
                                  ? const Icon(
                                      Icons.language_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      _getLanguageInitial(
                                          languageList[index].lang),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B)),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: MyText(
                              text: languageList[index].name,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: textDarkColor,
                                  ),
                            ),
                          ),
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? const Color(0xFF475569)
                                    : const Color(0xFFCBD5E1)),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
