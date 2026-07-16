import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../application/acc_bloc.dart';

class MapSettingsPage extends StatelessWidget {
  static const String routeName = '/mapSettings';

  const MapSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {},
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.read<AccBloc>();
          if (userData == null &&
              (state is AccInitialState || state is AccDataLoadingStartState)) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return SafeArea(
            top: false,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                leadingWidth: 72,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText(
                      text: AppLocalizations.of(context)!.mapSettings,
                      textStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    MyText(
                      text: AppLocalizations.of(context)!.chooseMapSubText,
                      textStyle: const TextStyle(
                        color: Color(0xFF9095A1),
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              body: Column(
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: CarouselSlider(
                      key: ValueKey(accBloc.choosenMapIndex),
                      items: [
                        _buildMapCard(
                          context: context,
                          size: size,
                          index: 0,
                          title: AppLocalizations.of(context)!.googleMap,
                          imagePath: 'assets/images/googlemap.jpeg',
                          isSelected: accBloc.choosenMapIndex == 0,
                          onTap: () => accBloc
                              .add(ChooseMapOnTapEvent(chooseMapIndex: 0)),
                        ),
                        _buildMapCard(
                          context: context,
                          size: size,
                          index: 1,
                          title: AppLocalizations.of(context)!.openstreet,
                          imagePath: 'assets/images/fluttermap.jpg',
                          isSelected: accBloc.choosenMapIndex == 1,
                          onTap: () => accBloc
                              .add(ChooseMapOnTapEvent(chooseMapIndex: 1)),
                        ),
                      ],
                      options: CarouselOptions(
                        initialPage: accBloc.choosenMapIndex,
                        height: size.height * 0.65,
                        enlargeCenterPage: true,
                        autoPlay: false,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.72,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityBanner(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSecurityBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerColor =
        isDark ? const Color(0xFF121B2D) : const Color(0xFFF8F9FA);
    final iconBgColor =
        isDark ? const Color(0xFF1B253F) : const Color(0xFFF0F2FF);
    final iconColor = isDark ? Colors.white : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: bannerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.verified_user_outlined,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyText(
                text: AppLocalizations.of(context)!.chooseMapTipText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textStyle: const TextStyle(
                  color: Color(0xFF9095A1),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard({
    required BuildContext context,
    required Size size,
    required int index,
    required String title,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF121B2D) : Colors.white;
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected || isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    color: isDark
                        ? const Color(0xFF0F172A).withOpacity(0.4)
                        : null,
                    colorBlendMode: isDark ? BlendMode.srcOver : null,
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  MyText(
                    text: title,
                    textStyle: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF171A1F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.done, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          MyText(
                            text: AppLocalizations.of(context)!.selected,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF4B5563)
                              : const Color(0xFFD1D5DB),
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
