import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../common/app_constants.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class VehicleStatusWidget extends StatelessWidget {
  final BuildContext cont;
  const VehicleStatusWidget({super.key, required this.cont});

  Widget _buildStatusItem({
    required BuildContext context,
    required String text,
    required int statusValue,
    required int currentStatus,
    required Color activeDotColor,
    required Color activeBgColorLight,
    required Color activeBgColorDark,
    required Color activeBorderColorLight,
    required Color activeBorderColorDark,
    required Color activeTextColorLight,
    required Color activeTextColorDark,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentStatus == statusValue;

    final dotColor = isSelected
        ? activeDotColor
        : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF));

    final itemBgColor = isSelected
        ? (isDark ? activeBgColorDark : activeBgColorLight)
        : Colors.transparent;

    final itemBorderColor = isSelected
        ? (isDark ? activeBorderColorDark : activeBorderColorLight)
        : Colors.transparent;

    final textColor = isSelected
        ? (isDark ? activeTextColorDark : activeTextColorLight)
        : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563));

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: itemBgColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: itemBorderColor, width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: (choosenLanguage == 'ta') ? 11 : 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final currentMenu = context.read<HomeBloc>().choosenCarMenu;

          final capsuleBgColor =
              isDark ? const Color(0xFF121B2D) : Colors.white;
          final capsuleBorderColor =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);

          return Container(
            margin: EdgeInsets.only(
                left: size.width * 0.075, right: size.width * 0.075),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            height: 52,
            width: size.width * 0.85,
            decoration: BoxDecoration(
              color: capsuleBgColor,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: capsuleBorderColor, width: 1.0),
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
            child: Row(
              children: [
                // Online Option
                _buildStatusItem(
                  context: context,
                  text: AppLocalizations.of(context)!.onlineSmall,
                  statusValue: 1,
                  currentStatus: currentMenu,
                  activeDotColor: const Color(0xFF22C55E),
                  activeBgColorLight: const Color(0xFFF0FDF4),
                  activeBgColorDark: const Color(0xFF22C55E).withOpacity(0.12),
                  activeBorderColorLight:
                      const Color(0xFF22C55E).withOpacity(0.2),
                  activeBorderColorDark:
                      const Color(0xFF22C55E).withOpacity(0.2),
                  activeTextColorLight: const Color(0xFF15803D),
                  activeTextColorDark: const Color(0xFF4ADE80),
                  onTap: () {
                    context.read<HomeBloc>().add(ChooseCarMenuEvent(menu: 1));
                  },
                ),

                // Offline Option
                _buildStatusItem(
                  context: context,
                  text: AppLocalizations.of(context)!.offlineSmall,
                  statusValue: 2,
                  currentStatus: currentMenu,
                  activeDotColor: Colors.red,
                  activeBgColorLight: const Color(0xFFFEF2F2),
                  activeBgColorDark: Colors.red.withOpacity(0.12),
                  activeBorderColorLight: Colors.red.withOpacity(0.2),
                  activeBorderColorDark: Colors.red.withOpacity(0.2),
                  activeTextColorLight: const Color(0xFFB91C1C),
                  activeTextColorDark: const Color(0xFFFCA5A5),
                  onTap: () {
                    context.read<HomeBloc>().add(ChooseCarMenuEvent(menu: 2));
                  },
                ),

                // Onride Option
                _buildStatusItem(
                  context: context,
                  text: AppLocalizations.of(context)!.onrideSmall,
                  statusValue: 3,
                  currentStatus: currentMenu,
                  activeDotColor: Colors.orange,
                  activeBgColorLight: const Color(0xFFFFF7ED),
                  activeBgColorDark: Colors.orange.withOpacity(0.12),
                  activeBorderColorLight: Colors.orange.withOpacity(0.2),
                  activeBorderColorDark: Colors.orange.withOpacity(0.2),
                  activeTextColorLight: const Color(0xFFC2410C),
                  activeTextColorDark: const Color(0xFFFDBA74),
                  onTap: () {
                    context.read<HomeBloc>().add(ChooseCarMenuEvent(menu: 3));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
