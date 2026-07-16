import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_bloc.dart';

class UpdatePasswordPage extends StatelessWidget {
  static const String routeName = '/updatePasswordPage';
  final UpdatePasswordPageArguments arg;
  const UpdatePasswordPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is ForgotPasswordUpdateSuccessState) {
            // ignore: unused_local_variable
            final role = await AppSharedPreference.getUserType();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              LoginPage.routeName,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).primaryColorDark),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.updatePassword,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Form(
                        key: context.read<AuthBloc>().formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            const _UpdatePasswordIllustration(),
                            const SizedBox(height: 24),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .createNewPasswordText,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 22,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .createNewPasswordSubText,
                              textAlign: TextAlign.center,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14,
                                  ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 28),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .newPasswordText,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).primaryColorDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            buildPasswordField(context, size),
                            const SizedBox(height: 12),
                            // Password strength bar & text
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Theme.of(context).hintColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: AppLocalizations.of(context)!
                                            .passwordCharactersLengthText,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              fontSize: 12,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            buildButton(context),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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

  Widget buildButton(BuildContext context) {
    return Center(
      child: CustomButton(
        buttonName: AppLocalizations.of(context)!.changePasswordCapsText,
        borderRadius: 12,
        height: 52,
        textSize: 16,
        leading: const Icon(
          Icons.lock_outline_rounded,
          color: Colors.white,
          size: 20,
        ),
        width: MediaQuery.sizeOf(context).width,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () async {
          // ignore: unused_local_variable
          final role = await AppSharedPreference.getUserType();
          if (!context.mounted) return;
          context.read<AuthBloc>().add(
                UpdatePasswordEvent(
                    isLoginByEmail: arg.isLoginByEmail,
                    password: context.read<AuthBloc>().rPasswordController.text,
                    emailOrMobile: arg.emailOrMobile,
                    role: context.read<AuthBloc>().loginAs),
              );
        },
      ),
    );
  }

  Widget buildPasswordField(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return CustomTextField(
      controller: context.read<AuthBloc>().rPasswordController,
      borderRadius: 12,
      filled: true,
      fillColor: fillColor,
      obscureText: !context.read<AuthBloc>().showPassword,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
      ),
      hintText: AppLocalizations.of(context)!.enterYourNewPasswordText,
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: Theme.of(context).hintColor,
        size: 20,
      ),
      suffixConstraints: BoxConstraints(maxWidth: size.width * 0.2),
      suffixIcon: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(ShowPasswordIconEvent(
              showPassword: context.read<AuthBloc>().showPassword));
        },
        child: !context.read<AuthBloc>().showPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.visibility_off_outlined,
                  color: isDark
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF9CA3AF),
                  size: 20,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.visibility_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
              ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.enterYourPassword;
        } else if (value.length < 8) {
          return AppLocalizations.of(context)!.minimumCharacRequired;
        } else {
          return null;
        }
      },
    );
  }
}

class _UpdatePasswordIllustration extends StatelessWidget {
  const _UpdatePasswordIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final circleColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);

    return Center(
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              Icons.lock_rounded,
              color: Theme.of(context).primaryColor,
              size: 80,
            ),
            Positioned(
              bottom: 30,
              right: 25,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
