import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restart_tagxi/common/app_images.dart';
import 'package:restart_tagxi/common/local_data.dart';
import 'package:restart_tagxi/core/model/user_detail_model.dart';
import 'package:restart_tagxi/core/utils/extensions.dart';
import 'package:restart_tagxi/features/account/presentation/pages/profile/page/update_details.dart';
import '../../../../../../common/app_arguments.dart';
import '../../../../../../common/app_colors.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../auth/presentation/pages/login_page.dart';
import '../../../../application/acc_bloc.dart';
import 'update_phone_number_page.dart';

class ProfileInfoPage extends StatelessWidget {
  static const String routeName = '/editPage';

  const ProfileInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(AccGetUserDetailsEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is UserProfileDetailsLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is UpdatedUserDetailsState) {}
          if (state is UpdateUserDetailsFailureState) {
            context.showSnackBar(
                message: AppLocalizations.of(context)!.failToUpdateDetails);
          }
          if (state is UserDetailsButtonSuccess) {
            context.read<AccBloc>().add(AccGetUserDetailsEvent());
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
          if (state is UserDetailEditState) {
            Navigator.pushNamed(
              context,
              UpdateDetails.routeName,
              arguments: UpdateDetailsArguments(
                  header: state.header, text: state.text, userData: userData!),
            ).then(
              (value) {
                // ignore: use_build_context_synchronously
                context.read<AccBloc>().add(AccGetUserDetailsEvent());
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final cardBgColor = isDark ? const Color(0xFF131C2E) : Colors.white;
            final cardBorderColor =
                isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

            return (userData != null)
                ? Scaffold(
                    backgroundColor: isDark
                        ? const Color(0xFF0B1220)
                        : const Color(0xFFF8FAFC),
                    appBar: AppBar(
                      backgroundColor: isDark
                          ? const Color(0xFF0B1220)
                          : const Color(0xFFF8FAFC),
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        onPressed: () {
                          Navigator.pop(context, userData);
                        },
                      ),
                      centerTitle: true,
                      toolbarHeight: 80,
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyText(
                            text: AppLocalizations.of(context)!
                                .personalInformation,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .manageYourPersonalDetailsText,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card 1: Profile Photo Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 32, horizontal: 24),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: cardBorderColor, width: 1),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Concentric dotted circles
                                        CustomPaint(
                                          size: const Size(130, 130),
                                          painter: DottedCirclePainter(
                                            color: isDark
                                                ? AppColors.primary
                                                    .withOpacity(0.3)
                                                : AppColors.primary
                                                    .withOpacity(0.12),
                                            radiusFactor: 1.0,
                                          ),
                                        ),
                                        CustomPaint(
                                          size: const Size(130, 130),
                                          painter: DottedCirclePainter(
                                            color: isDark
                                                ? AppColors.primary
                                                    .withOpacity(0.5)
                                                : AppColors.primary
                                                    .withOpacity(0.2),
                                            radiusFactor: 0.85,
                                          ),
                                        ),
                                        // Avatar Container
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.08),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(45),
                                            child: userData!
                                                    .profilePicture.isNotEmpty
                                                ? Image.network(
                                                    userData!.profilePicture,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                            AppImages
                                                                .defaultProfile,
                                                            fit: BoxFit.cover),
                                                  )
                                                : Image.asset(
                                                    AppImages.defaultProfile,
                                                    fit: BoxFit.cover),
                                          ),
                                        ),
                                        // Add plus button overlay
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: InkWell(
                                            onTap: () =>
                                                _showImageSourceSheet(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isDark
                                                    ? const Color(0xFF131C2E)
                                                    : Colors.white,
                                              ),
                                              child: Container(
                                                height: 28,
                                                width: 28,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .addProfilePhoto,
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .addProfilePhotoSubText,
                                    textStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Card 2: Details List Card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                    color: cardBorderColor, width: 1),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    context: context,
                                    label: AppLocalizations.of(context)!.name,
                                    value: userData!.name,
                                    icon: Icons.person_outline_rounded,
                                    iconBgColor: isDark
                                        ? const Color(0xFF1E3A8A)
                                            .withOpacity(0.3)
                                        : const Color(0xFFEFF6FF),
                                    iconColor: isDark
                                        ? const Color(0xFF60A5FA)
                                        : const Color(0xFF3B82F6),
                                    onTap: () {
                                      context
                                          .read<AccBloc>()
                                          .add(UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .name,
                                            text: userData!.name,
                                          ));
                                    },
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    indent: 76,
                                    endIndent: 16,
                                  ),
                                  _buildDetailRow(
                                    context: context,
                                    label: AppLocalizations.of(context)!.mobile,
                                    value: userData!.mobile,
                                    icon: Icons.local_phone_outlined,
                                    iconBgColor: isDark
                                        ? const Color(0xFF064E3B)
                                            .withOpacity(0.3)
                                        : const Color(0xFFECFDF5),
                                    iconColor: isDark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF10B981),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const UpdatePhoneNumberPage(),
                                        ),
                                      );
                                      if (context.mounted) {
                                        context
                                            .read<AccBloc>()
                                            .add(AccGetUserDetailsEvent());
                                      }
                                    },
                                  ),
                                  Divider(
                                    height: 1,
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9),
                                    indent: 76,
                                    endIndent: 16,
                                  ),
                                  _buildDetailRow(
                                    context: context,
                                    label: AppLocalizations.of(context)!.email,
                                    value: userData!.email,
                                    icon: Icons.mail_outline_rounded,
                                    iconBgColor: isDark
                                        ? const Color(0xFF4C1D95)
                                            .withOpacity(0.3)
                                        : const Color(0xFFF5F3FF),
                                    iconColor: isDark
                                        ? const Color(0xFFA78BFA)
                                        : const Color(0xFF8B5CF6),
                                    onTap: () {
                                      context
                                          .read<AccBloc>()
                                          .add(UserDetailEditEvent(
                                            header:
                                                AppLocalizations.of(context)!
                                                    .email,
                                            text: userData!.email,
                                          ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Scaffold(
                    body: Loader(),
                  );
          },
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context)
                    .primaryColorDark
                    .withAlpha((0.5 * 255).toInt()),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.camera,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .primaryColorDark
                        .withAlpha((0.5 * 255).toInt())),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                size: 20,
                color: Theme.of(context)
                    .primaryColorDark
                    .withAlpha((0.5 * 255).toInt()),
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.gallery,
                textStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context)
                        .primaryColorDark
                        .withAlpha((0.5 * 255).toInt())),
              ),
              onTap: () {
                Navigator.pop(context);
                _updateProfileImage(context, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateProfileImage(BuildContext context, ImageSource source) {
    final AccBloc accBloc = context.read<AccBloc>();
    accBloc.add(UpdateImageEvent(
      name: userData!.name,
      email: userData!.email,
      gender: userData!.gender,
      source: source,
    ));
  }
}

// Concentric dotted circles painter
class DottedCirclePainter extends CustomPainter {
  final Color color;
  final double radiusFactor;

  DottedCirclePainter({required this.color, required this.radiusFactor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = min(size.width, size.height) / 2;
    final double radius = maxRadius * radiusFactor;

    final int dotCount = (2 * pi * radius / 6).floor();
    for (int i = 0; i < dotCount; i++) {
      final double angle = (i * 2 * pi) / dotCount;
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DottedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radiusFactor != radiusFactor;
  }
}

// Widget builder for modern detail row
Widget _buildDetailRow({
  required BuildContext context,
  required String label,
  required String value,
  required IconData icon,
  required Color iconBgColor,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: label,
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                MyText(
                  text: value,
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
              color: isDark
                  ? const Color(0xFF1E293B).withOpacity(0.5)
                  : Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
                const SizedBox(width: 6),
                MyText(
                  text: AppLocalizations.of(context)!.edit,
                  textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
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
