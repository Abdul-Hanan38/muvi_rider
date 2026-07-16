// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';

import '../../../../common/app_arguments.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_constants.dart';
import '../../../../common/app_images.dart';
import '../../../../common/app_validators.dart';
import '../../../../core/model/user_detail_model.dart';
import '../../../../core/utils/custom_appbar.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';
import '../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../language/presentation/page/choose_language_page.dart';
import '../../../loading/application/loading_bloc.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';
import 'forgot_password_page.dart';
import 'signup_mobile_page.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/loginPage';
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  Timer? timer;
  timerCount(BuildContext cont,
      {required int duration, bool? isCloseTimer}) async {
    int count = duration;

    if (isCloseTimer == null) {
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        count--;
        if (count <= 0) {
          timer?.cancel();
        }
        cont.read<AuthBloc>().add(VerifyTimerEvent(duration: count));
      });
    }

    if (isCloseTimer != null && isCloseTimer) {
      timer?.cancel();
      cont.read<AuthBloc>().add(VerifyTimerEvent(duration: 0));
    }
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(CountryGetEvent())
        ..add(GetCommonModuleEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          } else if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
            CustomLoader.dismiss(context);
          } else if (state is GetCommonModuleSuccess) {
            CustomLoader.dismiss(context);
          } else if (state is GetCommonModuleFailure) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is UpdateLoginAsState) {
          } else if (state is VerifySuccessState) {
            CustomLoader.dismiss(context);
            final authBloc = context.read<AuthBloc>();
            final mobileOrEmail = authBloc.selectLoginMethods
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();

            // Validation: make sure user entered email or mobile
            if (mobileOrEmail.isEmpty) {
              showToast(
                  message:
                      AppLocalizations.of(context)!.pleaseEnterMobileOrEmail);
            } else {
              // If not empty, switch to OTP mode and call the event
              authBloc.isOtpVerify = true;
              authBloc.add(
                SignInWithOTPEvent(
                  isOtpVerify: true,
                  isForgotPassword: false,
                  mobileOrEmail: mobileOrEmail,
                  dialCode: authBloc.dialCode,
                  isLoginByEmail: authBloc.selectLoginMethods,
                ),
              );
              timerCount(context, duration: 60);
            }
          } else if (state is ForgotPasswordOnTapState) {
            CustomLoader.dismiss(context);
            final authBloc = context.read<AuthBloc>();
            final mobileOrEmail = authBloc.selectLoginMethods
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();

            // Validation: make sure user entered email or mobile
            if (mobileOrEmail.isEmpty) {
              showToast(
                  message:
                      AppLocalizations.of(context)!.pleaseEnterMobileOrEmail);
            } else {
              final authBloc = context.read<AuthBloc>();
              final mobileOrEmail = authBloc.selectLoginMethods
                  ? authBloc.rEmailController.text.trim()
                  : authBloc.rMobileController.text.trim();
              Navigator.pushNamed(
                context,
                ForgotPasswordPage.routeName,
                arguments: ForgotPasswordPageArguments(
                    isLoginByEmail: authBloc.selectLoginMethods,
                    contryCode: authBloc.dialCode,
                    countryFlag: authBloc.countryCode,
                    emailOrMobile: mobileOrEmail,
                    loginAs: context.read<AuthBloc>().loginAs),
              ).then((_) {
                context.read<AuthBloc>().isOtpVerify = false;
                context
                    .read<AuthBloc>()
                    .add(OtpVerifyEvent(isOtpVerify: false));
              });
            }
          } else if (state is ForgotPasswordOTPSendState) {
            final authBloc = context.read<AuthBloc>();
            final mobileOrEmail = authBloc.selectLoginMethods
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();
            Navigator.pushNamed(
              context,
              ForgotPasswordPage.routeName,
              arguments: ForgotPasswordPageArguments(
                  isLoginByEmail: authBloc.selectLoginMethods,
                  contryCode: authBloc.dialCode,
                  countryFlag: authBloc.countryCode,
                  emailOrMobile: mobileOrEmail,
                  loginAs: context.read<AuthBloc>().loginAs),
            ).then((_) {
              context.read<AuthBloc>().isOtpVerify = false;
              context.read<AuthBloc>().add(OtpVerifyEvent(isOtpVerify: false));
            });
          } else if (state is UserNotExistState) {
            final authBloc = context.read<AuthBloc>();
            final mobileOrEmail = authBloc.selectLoginMethods
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();
            CustomLoader.dismiss(context);
            if (mobileOrEmail.isEmpty) {
              showToast(
                  message:
                      AppLocalizations.of(context)!.pleaseEnterMobileOrEmail);
            } else {
              showToast(message: state.message);
            }
          } else if (state is LoginSuccessState ||
              state is ConfirmMobileOrEmailState) {
            if (userData != null) {
              context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            }
            if (userData!.serviceLocationId != null) {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false,
                  arguments: HomePageArguments(isFromHistory: true, from: '0'));
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  DriverProfilePage.routeName,
                  arguments: VehicleUpdateArguments(
                    from: '',
                  ),
                  (route) => false);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              appBar: CustomAppBar(
                title: (context.read<AuthBloc>().loginAs == 'driver')
                    ? AppLocalizations.of(context)!.driverConnect
                    : AppLocalizations.of(context)!.loginOwnerConnectText,
                titleIcon: Container(
                  padding: EdgeInsets.all(size.width * 0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.primary,
                  ),
                  child: Image.asset(
                    AppImages.truckLogin,
                    fit: BoxFit.contain,
                    width: size.width * 0.065,
                    color: AppColors.white,
                  ),
                ),
                automaticallyImplyLeading: false,
                textColor: Theme.of(context).primaryColorDark,
                showBorder: false,
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.width * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                        context, ChooseLanguagePage.routeName,
                                        arguments:
                                            ChangeLanguageArguments(from: 1))
                                    .then(
                                  (value) {
                                    if (!context.mounted) return;
                                    context
                                        .read<AuthBloc>()
                                        .add(GetDirectionEvent());
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  MyText(
                                      text: choosenLanguage.toUpperCase(),
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                  Icon(Icons.language_outlined,
                                      color: Theme.of(context).primaryColor),
                                  Icon(Icons.arrow_drop_down,
                                      color: Theme.of(context).primaryColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.width * 0.025),
                        MyText(
                          text: AppLocalizations.of(context)!
                              .loginWelcomeBackText,
                          textStyle: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 26,
                              ),
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text:
                              AppLocalizations.of(context)!.loginToContinueText,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if ((context.read<AuthBloc>().loginAs == 'driver' &&
                                context.read<AuthBloc>().isDriverEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isDriverMobileLogin ==
                                    '1') ||
                            (context.read<AuthBloc>().loginAs != 'driver' &&
                                context.read<AuthBloc>().isOwnerEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isOwnerMobileLogin ==
                                    '1'))
                          Container(
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF161B2E)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      context.read<AuthBloc>().isOtpVerify =
                                          false;
                                      context.read<AuthBloc>().add(
                                          SelectLoginMethodEvent(
                                              selectLoginByEmail: false));
                                      context
                                          .read<AuthBloc>()
                                          .rEmailController
                                          .clear();
                                      context
                                          .read<AuthBloc>()
                                          .passwordController
                                          .clear();
                                      context
                                          .read<AuthBloc>()
                                          .otpController
                                          .clear();
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: (context
                                                      .read<AuthBloc>()
                                                      .selectLoginMethods ==
                                                  false)
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.smartphone_outlined,
                                              size: 18,
                                              color: (context
                                                          .read<AuthBloc>()
                                                          .selectLoginMethods ==
                                                      false)
                                                  ? Colors.white
                                                  : Theme.of(context).hintColor,
                                            ),
                                            const SizedBox(width: 8),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .mobile,
                                              textStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: (context
                                                            .read<AuthBloc>()
                                                            .selectLoginMethods ==
                                                        false)
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .hintColor,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      context.read<AuthBloc>().isOtpVerify =
                                          false;
                                      context.read<AuthBloc>().add(
                                          SelectLoginMethodEvent(
                                              selectLoginByEmail: true));
                                      context
                                          .read<AuthBloc>()
                                          .rMobileController
                                          .clear();
                                      context
                                          .read<AuthBloc>()
                                          .passwordController
                                          .clear();
                                      context
                                          .read<AuthBloc>()
                                          .otpController
                                          .clear();
                                    },
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: (context
                                                      .read<AuthBloc>()
                                                      .selectLoginMethods ==
                                                  true)
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.email_outlined,
                                              size: 18,
                                              color: (context
                                                          .read<AuthBloc>()
                                                          .selectLoginMethods ==
                                                      true)
                                                  ? Colors.white
                                                  : Theme.of(context).hintColor,
                                            ),
                                            const SizedBox(width: 8),
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .email,
                                              textStyle: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: (context
                                                            .read<AuthBloc>()
                                                            .selectLoginMethods ==
                                                        true)
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .hintColor,
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 14),
                        if ((context.read<AuthBloc>().loginAs == 'driver' &&
                                context.read<AuthBloc>().isDriverEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isDriverMobileLogin ==
                                    '1') ||
                            (context.read<AuthBloc>().loginAs != 'driver' &&
                                context.read<AuthBloc>().isOwnerEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isOwnerMobileLogin ==
                                    '1')) ...[
                          (context.watch<AuthBloc>().selectLoginMethods)
                              ? buildEmailField(context)
                              : buildMobileField(context, size),
                        ] else if ((context.read<AuthBloc>().loginAs ==
                                    'driver' &&
                                context.read<AuthBloc>().isDriverEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isDriverMobileLogin ==
                                    '0') ||
                            (context.read<AuthBloc>().loginAs != 'driver' &&
                                context.read<AuthBloc>().isOwnerEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isOwnerMobileLogin ==
                                    '0')) ...[
                          buildEmailField(context)
                        ] else if ((context.read<AuthBloc>().loginAs ==
                                    'driver' &&
                                context.read<AuthBloc>().isDriverEmailLogin ==
                                    '0' &&
                                context.read<AuthBloc>().isDriverMobileLogin ==
                                    '1') ||
                            (context.read<AuthBloc>().loginAs != 'driver' &&
                                context.read<AuthBloc>().isOwnerEmailLogin ==
                                    '0' &&
                                context.read<AuthBloc>().isOwnerMobileLogin ==
                                    '1')) ...[
                          buildMobileField(context, size),
                        ],
                        const SizedBox(height: 16),
                        if ((context.read<AuthBloc>().loginAs == 'driver' &&
                                context.read<AuthBloc>().isDriverEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isDriverMobileLogin ==
                                    '1') ||
                            (context.read<AuthBloc>().loginAs != 'driver' &&
                                context.read<AuthBloc>().isOwnerEmailLogin ==
                                    '1' &&
                                context.read<AuthBloc>().isOwnerMobileLogin ==
                                    '1')) ...[
                          if (context.watch<AuthBloc>().isOtpVerify) ...[
                            if (((context.read<AuthBloc>().selectLoginMethods ==
                                                false &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isDriverSignInMobileOtp ==
                                                '1' ||
                                        context
                                                    .read<AuthBloc>()
                                                    .selectLoginMethods ==
                                                true &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isDriverSignInEmailOtp ==
                                                '1') &&
                                    context.read<AuthBloc>().loginAs ==
                                        'driver') ||
                                (context.read<AuthBloc>().selectLoginMethods ==
                                                false &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isOwnerSignInMobileOtp ==
                                                '1' ||
                                        context
                                                    .read<AuthBloc>()
                                                    .selectLoginMethods ==
                                                true &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isOwnerSignInEmailOtp ==
                                                '1') &&
                                    context.read<AuthBloc>().loginAs !=
                                        'driver')
                              buildPinField(context),
                          ] else ...[
                            if (((context
                                                    .watch<AuthBloc>()
                                                    .selectLoginMethods ==
                                                false &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isDriverSignInMobilePassword ==
                                                '1' ||
                                        context
                                                    .watch<AuthBloc>()
                                                    .selectLoginMethods ==
                                                true &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isDriverSignInEmailPassword ==
                                                '1') &&
                                    context.read<AuthBloc>().loginAs ==
                                        'driver') ||
                                ((context
                                                    .watch<AuthBloc>()
                                                    .selectLoginMethods ==
                                                false &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isOwnerSignInMobilePassword ==
                                                '1' ||
                                        context
                                                    .watch<AuthBloc>()
                                                    .selectLoginMethods ==
                                                true &&
                                            context
                                                    .read<AuthBloc>()
                                                    .isOwnerSignInEmailPassword ==
                                                '1') &&
                                    context.read<AuthBloc>().loginAs !=
                                        'driver'))
                              passwordField(context),
                          ],
                        ] else ...[
                          if (context.watch<AuthBloc>().isOtpVerify) ...[
                            if (((context
                                                .read<AuthBloc>()
                                                .isDriverSignInMobileOtp ==
                                            '1' ||
                                        context
                                                .read<AuthBloc>()
                                                .isDriverSignInEmailOtp ==
                                            '1') &&
                                    context.read<AuthBloc>().loginAs ==
                                        'driver') ||
                                (context
                                                .read<AuthBloc>()
                                                .isOwnerSignInMobileOtp ==
                                            '1' ||
                                        context
                                                .read<AuthBloc>()
                                                .isOwnerSignInEmailOtp ==
                                            '1') &&
                                    context.read<AuthBloc>().loginAs !=
                                        'driver')
                              buildPinField(context),
                          ] else ...[
                            if (((context
                                                .read<AuthBloc>()
                                                .isDriverSignInMobilePassword ==
                                            '1' ||
                                        context
                                                .read<AuthBloc>()
                                                .isDriverSignInEmailPassword ==
                                            '1') &&
                                    context.read<AuthBloc>().loginAs ==
                                        'driver') ||
                                ((context
                                                .read<AuthBloc>()
                                                .isOwnerSignInMobilePassword ==
                                            '1' ||
                                        context
                                                .read<AuthBloc>()
                                                .isOwnerSignInEmailPassword ==
                                            '1') &&
                                    context.read<AuthBloc>().loginAs !=
                                        'driver'))
                              passwordField(context),
                          ],
                        ],
                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            bool isChecked = false;

                            if (state is SelectTermsAndConditionCheckBoxState) {
                              isChecked = state.isTermsAndConditionsChecked;
                            } else {
                              isChecked = context
                                  .read<AuthBloc>()
                                  .isTermsAndConditionsChecked;
                            }

                            return Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read<AuthBloc>().add(
                                          SelectTermsAndConditionCheckBoxEvent(
                                            isTermsAndConditionsChecked:
                                                !isChecked,
                                          ),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: isChecked
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        width: 1.5,
                                        color: isChecked
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context)
                                                .hintColor
                                                .withOpacity(0.4),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: isChecked
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    MyText(
                                      text:
                                          '${AppLocalizations.of(context)!.agreeTermsText} ',
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(fontSize: 13),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          TermsPrivacyPolicyViewPage.routeName,
                                          arguments:
                                              TermsAndPrivacyPolicyArguments(
                                            isPrivacyPolicy: false,
                                          ),
                                        );
                                      },
                                      child: MyText(
                                        text: AppLocalizations.of(context)!
                                            .termsAndConditions,
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        buildLoginButton(context),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF232A45)
                                    : const Color(0xFFE5E7EB),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: MyText(
                                text: AppLocalizations.of(context)!
                                    .logincontinueWithOthersText,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF232A45)
                                    : const Color(0xFFE5E7EB),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        if (context.read<AuthBloc>().isDriverSignUpFeature ==
                            '1') ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyText(
                                text:
                                    '${AppLocalizations.of(context)!.dontHaveAnAccount} ',
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                        fontSize: 13,
                                        color: Theme.of(context).hintColor),
                              ),
                              InkWell(
                                onTap: () {
                                  if ((context.read<AuthBloc>().loginAs == 'driver' &&
                                          context.read<AuthBloc>().isDriverEmailLogin ==
                                              '1' &&
                                          context.read<AuthBloc>().isDriverMobileLogin ==
                                              '1') ||
                                      (context.read<AuthBloc>().loginAs != 'driver' &&
                                          context.read<AuthBloc>().isOwnerEmailLogin ==
                                              '1' &&
                                          context.read<AuthBloc>().isOwnerMobileLogin ==
                                              '1')) {
                                    Navigator.pushNamed(
                                        context, SignupMobilePage.routeName,
                                        arguments: SignupMobilePageArguments(
                                            type: context
                                                .read<AuthBloc>()
                                                .loginAs,
                                            mobileOrEmailSignUp: context
                                                .read<AuthBloc>()
                                                .selectLoginMethods));
                                  } else if ((context.read<AuthBloc>().loginAs ==
                                              'driver' &&
                                          context.read<AuthBloc>().isDriverEmailLogin ==
                                              '0' &&
                                          context.read<AuthBloc>().isDriverMobileLogin ==
                                              '1') ||
                                      (context.read<AuthBloc>().loginAs != 'driver' &&
                                          context.read<AuthBloc>().isOwnerEmailLogin ==
                                              '0' &&
                                          context.read<AuthBloc>().isOwnerMobileLogin ==
                                              '1')) {
                                    Navigator.pushNamed(
                                        context, SignupMobilePage.routeName,
                                        arguments: SignupMobilePageArguments(
                                            type: context
                                                .read<AuthBloc>()
                                                .loginAs,
                                            mobileOrEmailSignUp: false));
                                  } else if ((context.read<AuthBloc>().loginAs ==
                                              'driver' &&
                                          context.read<AuthBloc>().isDriverEmailLogin ==
                                              '1' &&
                                          context
                                                  .read<AuthBloc>()
                                                  .isDriverMobileLogin ==
                                              '0') ||
                                      (context.read<AuthBloc>().loginAs != 'driver' &&
                                          context.read<AuthBloc>().isOwnerEmailLogin == '1' &&
                                          context.read<AuthBloc>().isOwnerMobileLogin == '0')) {
                                    Navigator.pushNamed(
                                        context, SignupMobilePage.routeName,
                                        arguments: SignupMobilePageArguments(
                                            type: context
                                                .read<AuthBloc>()
                                                .loginAs,
                                            mobileOrEmailSignUp: true));
                                  }
                                },
                                child: MyText(
                                  text:
                                      '${AppLocalizations.of(context)!.signup} ',
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (context.read<AuthBloc>().isOwnerLogin == '1')
                          InkWell(
                            onTap: () {
                              if (context.read<AuthBloc>().loginAs ==
                                  'driver') {
                                context
                                    .read<AuthBloc>()
                                    .add(ChooseLoginAsEvent(loginAs: 'owner'));
                                context
                                    .read<AuthBloc>()
                                    .add(UpdateLoginAsEvent(loginAs: 'owner'));
                              } else {
                                context
                                    .read<AuthBloc>()
                                    .add(ChooseLoginAsEvent(loginAs: 'driver'));
                                context
                                    .read<AuthBloc>()
                                    .add(UpdateLoginAsEvent(loginAs: 'driver'));
                              }
                            },
                            child: MyText(
                              text: (context.read<AuthBloc>().loginAs ==
                                      'driver')
                                  ? AppLocalizations.of(context)!.loginAsOwner
                                  : AppLocalizations.of(context)!.loginAsDriver,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
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
    );
  }

  Widget buildMobileField(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.phoneNumber,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).primaryColorDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: context.read<AuthBloc>().rMobileController,
          filled: true,
          borderRadius: 12,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          enabled: context.read<AuthBloc>().isLoginByEmail,
          hintText: AppLocalizations.of(context)!.mobile,
          focusNode: context.read<AuthBloc>().mobileFocusNode,
          keyboardType: TextInputType.number,
          prefixConstraints: const BoxConstraints(maxWidth: 100),
          prefixIcon: Center(
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  enableDrag: true,
                  context: context,
                  builder: (cont) {
                    return SelectCountryWidget(
                        countries: context.read<AuthBloc>().countries,
                        cont: context);
                  },
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  Container(
                    height: 18,
                    width: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Theme.of(context).hintColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      image: (context.read<AuthBloc>().flagImage.isNotEmpty)
                          ? DecorationImage(
                              image: NetworkImage(
                                  context.read<AuthBloc>().flagImage),
                              fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  MyText(
                    text: context.read<AuthBloc>().dialCode,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: Color(0xFF6B7280)),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.only(left: 8),
                    color: borderColor,
                  ),
                ],
              ),
            ),
          ),
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().rMobileController.clear();
            },
            child: Icon(
              Icons.cancel_outlined,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          validator: (value) {
            if (value!.isNotEmpty &&
                !AppValidation.mobileNumberValidate(value)) {
              return AppLocalizations.of(context)!.enterValidMobile;
            } else if (value.isEmpty) {
              return AppLocalizations.of(context)!.pleaseEnterMobileNumber;
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget buildEmailField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.email,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: context.read<AuthBloc>().rEmailController,
          filled: true,
          borderRadius: 12,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          hintText: AppLocalizations.of(context)!.enterEmail,
          focusNode: context.read<AuthBloc>().emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().rEmailController.clear();
            },
            child: Icon(
              Icons.cancel_outlined,
              color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
              size: 20,
            ),
          ),
          validator: (value) {
            if (value!.isNotEmpty && !AppValidation.emailValidate(value)) {
              return AppLocalizations.of(context)!.enterValidEmail;
            } else if (value.isEmpty) {
              return AppLocalizations.of(context)!.enterEmail;
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget passwordField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.password,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).primaryColorDark,
              fontSize: 14,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: context.read<AuthBloc>().passwordController,
          filled: true,
          obscureText: !context.read<AuthBloc>().showPassword,
          borderRadius: 12,
          fillColor: fillColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderColor, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          ),
          hintText: AppLocalizations.of(context)!.enterYourPassword,
          suffixIcon: InkWell(
            onTap: () {
              context.read<AuthBloc>().add(ShowPasswordIconEvent(
                  showPassword: context.read<AuthBloc>().showPassword));
            },
            child: !context.read<AuthBloc>().showPassword
                ? Icon(
                    Icons.visibility_off_outlined,
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                    size: 20,
                  )
                : Icon(
                    Icons.visibility_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                final mobileNumber =
                    context.read<AuthBloc>().rMobileController.text.trim();
                final email = context.read<AuthBloc>().rEmailController.text;

                context.read<AuthBloc>().add(VerifyUserEvent(
                    loginAs: context.read<AuthBloc>().loginAs,
                    mobileOrEmail: (context.read<AuthBloc>().selectLoginMethods)
                        ? email
                        : mobileNumber,
                    loginByMobile: (context.read<AuthBloc>().selectLoginMethods)
                        ? true
                        : false,
                    forgotPassword: true));
              },
              child: MyText(
                text: '${AppLocalizations.of(context)!.forgotPassword}?',
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),

            // sign in using otp
            if ((context.read<AuthBloc>().loginAs == 'driver' &&
                    context.read<AuthBloc>().isDriverEmailLogin == '1' &&
                    context.read<AuthBloc>().isDriverMobileLogin == '1') ||
                (context.read<AuthBloc>().loginAs != 'driver' &&
                    context.read<AuthBloc>().isOwnerEmailLogin == '1' &&
                    context.read<AuthBloc>().isOwnerMobileLogin == '1')) ...[
              if (((context.watch<AuthBloc>().selectLoginMethods == false &&
                              context
                                      .read<AuthBloc>()
                                      .isDriverSignInMobileOtp ==
                                  '1' ||
                          context.watch<AuthBloc>().selectLoginMethods ==
                                  true &&
                              context.read<AuthBloc>().isDriverSignInEmailOtp ==
                                  '1') &&
                      context.read<AuthBloc>().loginAs == 'driver') ||
                  ((context.watch<AuthBloc>().selectLoginMethods == false &&
                              context.read<AuthBloc>().isOwnerSignInMobileOtp ==
                                  '1' ||
                          context.watch<AuthBloc>().selectLoginMethods ==
                                  true &&
                              context.read<AuthBloc>().isOwnerSignInEmailOtp ==
                                  '1') &&
                      context.watch<AuthBloc>().loginAs != 'driver'))
                InkWell(
                  onTap: () {
                    final authBloc = context.read<AuthBloc>();
                    final mobileOrEmail = authBloc.selectLoginMethods
                        ? authBloc.rEmailController.text.trim()
                        : authBloc.rMobileController.text.trim();
                    FocusScope.of(context).unfocus();
                    if (mobileOrEmail.isEmpty) {
                      showToast(
                          message: AppLocalizations.of(context)!
                              .pleaseEnterMobileOrEmail);
                    } else {
                      final mobileNumber = context
                          .read<AuthBloc>()
                          .rMobileController
                          .text
                          .trim();
                      final email =
                          context.read<AuthBloc>().rEmailController.text;

                      context.read<AuthBloc>().add(VerifyUserEvent(
                          loginAs: context.read<AuthBloc>().loginAs,
                          mobileOrEmail:
                              (context.read<AuthBloc>().selectLoginMethods)
                                  ? email
                                  : mobileNumber,
                          loginByMobile:
                              (context.read<AuthBloc>().selectLoginMethods)
                                  ? true
                                  : false,
                          forgotPassword: false));
                    }
                  },
                  child: MyText(
                    text: AppLocalizations.of(context)!.signUsingOtp,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                  ),
                ),
            ]
            // sign in using otp for mobile login
            else if ((context.read<AuthBloc>().loginAs == 'driver' &&
                    context.read<AuthBloc>().isDriverEmailLogin == '0' &&
                    context.read<AuthBloc>().isDriverMobileLogin == '1') ||
                (context.read<AuthBloc>().loginAs != 'driver' &&
                    context.read<AuthBloc>().isOwnerEmailLogin == '0' &&
                    context.read<AuthBloc>().isOwnerMobileLogin == '1')) ...[
              if (((context.read<AuthBloc>().isDriverSignInMobileOtp == '1') &&
                      context.read<AuthBloc>().loginAs == 'driver') ||
                  ((context.read<AuthBloc>().isOwnerSignInMobileOtp == '1') &&
                      context.watch<AuthBloc>().loginAs != 'driver'))
                InkWell(
                  onTap: () {
                    context.read<AuthBloc>().selectLoginMethods = false;
                    final authBloc = context.read<AuthBloc>();
                    final mobileOrEmail =
                        authBloc.rMobileController.text.trim();
                    FocusScope.of(context).unfocus();
                    if (mobileOrEmail.isEmpty) {
                      showToast(
                          message: AppLocalizations.of(context)!
                              .pleaseEnterMobileOrEmail);
                    } else {
                      final mobileNumber = context
                          .read<AuthBloc>()
                          .rMobileController
                          .text
                          .trim();

                      context.read<AuthBloc>().add(VerifyUserEvent(
                          loginAs: context.read<AuthBloc>().loginAs,
                          mobileOrEmail: mobileNumber,
                          loginByMobile: false,
                          forgotPassword: false));
                    }
                  },
                  child: MyText(
                    text: AppLocalizations.of(context)!.signUsingOtp,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                  ),
                ),
            ]
            // sign in using otp for email
            else if ((context.read<AuthBloc>().loginAs == 'driver' &&
                    context.read<AuthBloc>().isDriverEmailLogin == '1' &&
                    context.read<AuthBloc>().isDriverMobileLogin == '0') ||
                (context.read<AuthBloc>().loginAs != 'driver' &&
                    context.read<AuthBloc>().isOwnerEmailLogin == '1' &&
                    context.read<AuthBloc>().isOwnerMobileLogin == '0')) ...[
              if (((context.read<AuthBloc>().isDriverSignInEmailOtp == '1') &&
                      context.read<AuthBloc>().loginAs == 'driver') ||
                  ((context.read<AuthBloc>().isOwnerSignInEmailOtp == '1') &&
                      context.watch<AuthBloc>().loginAs != 'driver'))
                InkWell(
                  onTap: () {
                    context.read<AuthBloc>().selectLoginMethods = true;
                    final authBloc = context.read<AuthBloc>();
                    final mobileOrEmail = authBloc.rEmailController.text.trim();
                    FocusScope.of(context).unfocus();
                    if (mobileOrEmail.isEmpty) {
                      showToast(
                          message: AppLocalizations.of(context)!
                              .pleaseEnterMobileOrEmail);
                    } else {
                      final email =
                          context.read<AuthBloc>().rEmailController.text;

                      context.read<AuthBloc>().add(VerifyUserEvent(
                          loginAs: context.read<AuthBloc>().loginAs,
                          mobileOrEmail: email,
                          loginByMobile: true,
                          forgotPassword: false));
                    }
                  },
                  child: MyText(
                    text: AppLocalizations.of(context)!.signUsingOtp,
                    textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget buildPinField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.enterOtp,
          textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).primaryColorDark, fontSize: 16),
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          appContext: context,
          controller: context.read<AuthBloc>().otpController,
          textStyle: Theme.of(context).textTheme.bodyLarge,
          length: 6,
          autoFocus: true,
          obscureText: false,
          blinkWhenObscuring: false,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: 45,
            fieldWidth: 45,
            activeFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveFillColor: Theme.of(context).scaffoldBackgroundColor,
            inactiveColor: Theme.of(context).hintColor,
            selectedFillColor: Theme.of(context).scaffoldBackgroundColor,
            selectedColor: Theme.of(context).disabledColor,
            selectedBorderWidth: 1,
            inactiveBorderWidth: 1,
            activeBorderWidth: 1,
            activeColor: Theme.of(context).hintColor,
          ),
          cursorColor: Theme.of(context).dividerColor,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          enablePinAutofill: false,
          autoDisposeControllers: false,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          beforeTextPaste: (_) => false,
          onChanged: (_) => context.read<AuthBloc>().add(OTPOnChangeEvent()),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: context.read<AuthBloc>().timerDuration != 0
                  ? null
                  : () {
                      final mobileNumber = context
                          .read<AuthBloc>()
                          .rMobileController
                          .text
                          .trim();
                      final email =
                          context.read<AuthBloc>().rEmailController.text;
                      context.read<AuthBloc>();
                      context.read<AuthBloc>().add(VerifyUserEvent(
                          loginAs: context.read<AuthBloc>().loginAs,
                          mobileOrEmail:
                              (context.read<AuthBloc>().selectLoginMethods)
                                  ? email
                                  : mobileNumber,
                          loginByMobile:
                              (context.read<AuthBloc>().selectLoginMethods)
                                  ? true
                                  : false,
                          forgotPassword: false));
                    },
              child: MyText(
                text: context.read<AuthBloc>().timerDuration != 0
                    ? '${AppLocalizations.of(context)!.resendOtp} 00:${context.read<AuthBloc>().timerDuration}'
                    : AppLocalizations.of(context)!.resendOtp,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      color: context.read<AuthBloc>().timerDuration != 0
                          ? Theme.of(context).disabledColor
                          : AppColors.blackText,
                    ),
              ),
            ),
            if (((context.read<AuthBloc>().selectLoginMethods == false &&
                            context
                                    .read<AuthBloc>()
                                    .isDriverSignInMobilePassword ==
                                '1' ||
                        context.watch<AuthBloc>().selectLoginMethods == true &&
                            context
                                    .read<AuthBloc>()
                                    .isDriverSignInEmailPassword ==
                                '1') &&
                    context.read<AuthBloc>().loginAs == 'driver') ||
                ((context.read<AuthBloc>().selectLoginMethods == false &&
                            context
                                    .read<AuthBloc>()
                                    .isOwnerSignInMobilePassword ==
                                '1' ||
                        context.watch<AuthBloc>().selectLoginMethods == true &&
                            context
                                    .read<AuthBloc>()
                                    .isOwnerSignInEmailPassword ==
                                '1') &&
                    context.read<AuthBloc>().loginAs != 'driver'))
              InkWell(
                onTap: () {
                  context.read<AuthBloc>().isOtpVerify = false;
                  FocusScope.of(context).unfocus();
                  context
                      .read<AuthBloc>()
                      .add(OtpVerifyEvent(isOtpVerify: false));
                  timerCount(context, duration: 0, isCloseTimer: true);
                },
                child: MyText(
                  text: AppLocalizations.of(context)!.signUsingPassword,
                  textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 10),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget buildLoginButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child:
              // login for both enable
              ((context.read<AuthBloc>().loginAs == 'driver' &&
                          context.read<AuthBloc>().isDriverEmailLogin == '1' &&
                          context.read<AuthBloc>().isDriverMobileLogin ==
                              '1') ||
                      (context.read<AuthBloc>().loginAs != 'driver' &&
                          context.read<AuthBloc>().isOwnerEmailLogin == '1' &&
                          context.read<AuthBloc>().isOwnerMobileLogin == '1'))
                  ? CustomButton(
                      borderRadius: 12,
                      height: 52,
                      width: MediaQuery.sizeOf(context).width,
                      buttonName: (((((context.read<AuthBloc>().selectLoginMethods == false && context.read<AuthBloc>().isDriverSignInMobilePassword == '0' && context.read<AuthBloc>().isDriverSignInMobileOtp == '1' && context.read<AuthBloc>().isOtpVerify == false) ||
                                      (context.read<AuthBloc>().selectLoginMethods == true &&
                                          context
                                                  .read<AuthBloc>()
                                                  .isDriverSignInEmailPassword ==
                                              '0' &&
                                          context.read<AuthBloc>().isDriverSignInEmailOtp ==
                                              '1' &&
                                          context.read<AuthBloc>().isOtpVerify ==
                                              false))) &&
                                  context.read<AuthBloc>().choosenLoginAs ==
                                      'driver') ||
                              ((((context.read<AuthBloc>().selectLoginMethods == false &&
                                          context
                                                  .read<AuthBloc>()
                                                  .isOwnerSignInMobilePassword ==
                                              '0' &&
                                          context.read<AuthBloc>().isOwnerSignInMobileOtp ==
                                              '1' &&
                                          context.read<AuthBloc>().isOtpVerify ==
                                              false) ||
                                      (context.read<AuthBloc>().selectLoginMethods == true &&
                                          context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                          context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                          context.read<AuthBloc>().isOtpVerify == false))) &&
                                  context.read<AuthBloc>().choosenLoginAs != 'driver'))
                          ? 'Send OTP'
                          : AppLocalizations.of(context)!.signIn,
                      textSize: 16,
                      isLoader: context.read<AuthBloc>().isLoading,
                      onTap: () {
                        if (context
                                .read<AuthBloc>()
                                .isTermsAndConditionsChecked ==
                            true) {
                          FocusScope.of(context).unfocus();
                          if (((context.read<AuthBloc>().selectLoginMethods == false &&
                                          context.read<AuthBloc>().isDriverSignInMobilePassword ==
                                              '0' &&
                                          context.read<AuthBloc>().isDriverSignInMobileOtp ==
                                              '1' &&
                                          context.read<AuthBloc>().isOtpVerify ==
                                              false ||
                                      context.read<AuthBloc>().selectLoginMethods == true &&
                                          context.read<AuthBloc>().isDriverSignInEmailPassword ==
                                              '0' &&
                                          context.read<AuthBloc>().isDriverSignInEmailOtp ==
                                              '1' &&
                                          context.read<AuthBloc>().isOtpVerify ==
                                              false) &&
                                  context.read<AuthBloc>().loginAs ==
                                      'driver') ||
                              ((context.read<AuthBloc>().selectLoginMethods == false &&
                                          context
                                                  .read<AuthBloc>()
                                                  .isOwnerSignInMobilePassword ==
                                              '0' &&
                                          context.read<AuthBloc>().isOwnerSignInMobileOtp ==
                                              '1' &&
                                          context.read<AuthBloc>().isOtpVerify ==
                                              false ||
                                      context.read<AuthBloc>().selectLoginMethods == true &&
                                          context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                          context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                          context.read<AuthBloc>().isOtpVerify == false) &&
                                  context.read<AuthBloc>().loginAs != 'driver')) {
                            final authBloc = context.read<AuthBloc>();
                            final mobileOrEmail = authBloc.selectLoginMethods
                                ? authBloc.rEmailController.text.trim()
                                : authBloc.rMobileController.text.trim();
                            if (mobileOrEmail.isEmpty) {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .pleaseEnterMobileOrEmail);
                            } else {
                              final mobileNumber = context
                                  .read<AuthBloc>()
                                  .rMobileController
                                  .text
                                  .trim();
                              final email = context
                                  .read<AuthBloc>()
                                  .rEmailController
                                  .text;

                              context.read<AuthBloc>().add(VerifyUserEvent(
                                  loginAs: context.read<AuthBloc>().loginAs,
                                  mobileOrEmail: (context
                                          .read<AuthBloc>()
                                          .selectLoginMethods)
                                      ? email
                                      : mobileNumber,
                                  loginByMobile: (context
                                          .read<AuthBloc>()
                                          .selectLoginMethods)
                                      ? true
                                      : false,
                                  forgotPassword: false));
                            }
                          } else {
                            final mobileNumber = context
                                .read<AuthBloc>()
                                .rMobileController
                                .text
                                .trim();
                            final password = context
                                .read<AuthBloc>()
                                .passwordController
                                .text
                                .trim();
                            final email =
                                context.read<AuthBloc>().rEmailController.text;
                            if (context.read<AuthBloc>().isOtpVerify) {
                              //otp
                              context.read<AuthBloc>().add(
                                    ConfirmOrVerifyOTPEvent(
                                      isUserExist:
                                          context.read<AuthBloc>().userExist,
                                      isLoginByEmail: (context
                                              .read<AuthBloc>()
                                              .selectLoginMethods)
                                          ? true
                                          : false,
                                      isOtpVerify:
                                          context.read<AuthBloc>().isOtpVerify,
                                      isForgotPasswordVerify: false,
                                      mobileOrEmail: (context
                                              .read<AuthBloc>()
                                              .selectLoginMethods)
                                          ? email
                                          : mobileNumber,
                                      otp: context
                                          .read<AuthBloc>()
                                          .otpController
                                          .text,
                                      password: password,
                                      firebaseVerificationId: context
                                          .read<AuthBloc>()
                                          .firebaseVerificationId,
                                      loginAs: context.read<AuthBloc>().loginAs,
                                    ),
                                  );
                            } else {
                              //password
                              context.read<AuthBloc>().add(LoginUserEvent(
                                    emailOrMobile: (context
                                            .read<AuthBloc>()
                                            .selectLoginMethods)
                                        ? email
                                        : mobileNumber,
                                    otp: context
                                        .read<AuthBloc>()
                                        .otpController
                                        .text,
                                    password: password,
                                    isOtpLogin:
                                        context.read<AuthBloc>().isOtpVerify,
                                    isLoginByEmail: (context
                                            .read<AuthBloc>()
                                            .selectLoginMethods)
                                        ? true
                                        : false,
                                    loginAs: context.read<AuthBloc>().loginAs,
                                  ));
                            }
                          }
                        } else {
                          showToast(
                              message: AppLocalizations.of(context)!
                                  .acceptTermsAndConditions);
                        }
                      },
                    )
                  // login by email only
                  : ((context.read<AuthBloc>().loginAs == 'driver' &&
                              context.read<AuthBloc>().isDriverEmailLogin ==
                                  '1' &&
                              context.read<AuthBloc>().isDriverMobileLogin ==
                                  '0') ||
                          (context.read<AuthBloc>().loginAs != 'driver' &&
                              context.read<AuthBloc>().isOwnerEmailLogin ==
                                  '1' &&
                              context.read<AuthBloc>().isOwnerMobileLogin ==
                                  '0'))
                      ? CustomButton(
                          borderRadius: 12,
                          height: 52,
                          width: MediaQuery.sizeOf(context).width,
                          buttonName: (((((context.read<AuthBloc>().selectLoginMethods == false && context.read<AuthBloc>().isDriverSignInMobilePassword == '0' && context.read<AuthBloc>().isDriverSignInMobileOtp == '1' && context.read<AuthBloc>().isOtpVerify == false) ||
                                          (context.read<AuthBloc>().selectLoginMethods == true &&
                                              context.read<AuthBloc>().isDriverSignInEmailPassword ==
                                                  '0' &&
                                              context
                                                      .read<AuthBloc>()
                                                      .isDriverSignInEmailOtp ==
                                                  '1' &&
                                              context.read<AuthBloc>().isOtpVerify ==
                                                  false))) &&
                                      context.read<AuthBloc>().choosenLoginAs ==
                                          'driver') ||
                                  ((((context.read<AuthBloc>().selectLoginMethods == false &&
                                              context
                                                      .read<AuthBloc>()
                                                      .isOwnerSignInMobilePassword ==
                                                  '0' &&
                                              context
                                                      .read<AuthBloc>()
                                                      .isOwnerSignInMobileOtp ==
                                                  '1' &&
                                              context.read<AuthBloc>().isOtpVerify ==
                                                  false) ||
                                          (context.read<AuthBloc>().selectLoginMethods == true &&
                                              context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                              context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                              context.read<AuthBloc>().isOtpVerify == false))) &&
                                      context.read<AuthBloc>().choosenLoginAs != 'driver'))
                              ? 'Send OTP'
                              : AppLocalizations.of(context)!.signIn,
                          textSize: 16,
                          isLoader: context.read<AuthBloc>().isLoading,
                          onTap: () {
                            if (context
                                    .read<AuthBloc>()
                                    .isTermsAndConditionsChecked ==
                                true) {
                              context.read<AuthBloc>().selectLoginMethods =
                                  true;
                              FocusScope.of(context).unfocus();
                              if (((context.read<AuthBloc>().selectLoginMethods == false &&
                                              context.read<AuthBloc>().isDriverSignInMobilePassword ==
                                                  '0' &&
                                              context.read<AuthBloc>().isDriverSignInMobileOtp ==
                                                  '1' &&
                                              context.read<AuthBloc>().isOtpVerify ==
                                                  false ||
                                          context.read<AuthBloc>().selectLoginMethods == true &&
                                              context.read<AuthBloc>().isDriverSignInEmailPassword ==
                                                  '0' &&
                                              context.read<AuthBloc>().isDriverSignInEmailOtp ==
                                                  '1' &&
                                              context.read<AuthBloc>().isOtpVerify ==
                                                  false) &&
                                      context.read<AuthBloc>().loginAs ==
                                          'driver') ||
                                  ((context.read<AuthBloc>().selectLoginMethods == false &&
                                              context
                                                      .read<AuthBloc>()
                                                      .isOwnerSignInMobilePassword ==
                                                  '0' &&
                                              context
                                                      .read<AuthBloc>()
                                                      .isOwnerSignInMobileOtp ==
                                                  '1' &&
                                              context.read<AuthBloc>().isOtpVerify ==
                                                  false ||
                                          context.read<AuthBloc>().selectLoginMethods == true &&
                                              context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                              context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                              context.read<AuthBloc>().isOtpVerify == false) &&
                                      context.read<AuthBloc>().loginAs != 'driver')) {
                                final authBloc = context.read<AuthBloc>();
                                final mobileOrEmail =
                                    authBloc.rEmailController.text.trim();
                                if (mobileOrEmail.isEmpty) {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .pleaseEnterMobileOrEmail);
                                } else {
                                  final email = context
                                      .read<AuthBloc>()
                                      .rEmailController
                                      .text;

                                  context.read<AuthBloc>().add(VerifyUserEvent(
                                      loginAs: context.read<AuthBloc>().loginAs,
                                      mobileOrEmail: email,
                                      loginByMobile: true,
                                      forgotPassword: false));
                                }
                              } else {
                                final password = context
                                    .read<AuthBloc>()
                                    .passwordController
                                    .text
                                    .trim();
                                final email = context
                                    .read<AuthBloc>()
                                    .rEmailController
                                    .text;
                                if (context.read<AuthBloc>().isOtpVerify) {
                                  //otp
                                  context.read<AuthBloc>().add(
                                        ConfirmOrVerifyOTPEvent(
                                          isUserExist: context
                                              .read<AuthBloc>()
                                              .userExist,
                                          isLoginByEmail: true,
                                          isOtpVerify: context
                                              .read<AuthBloc>()
                                              .isOtpVerify,
                                          isForgotPasswordVerify: false,
                                          mobileOrEmail: email,
                                          otp: context
                                              .read<AuthBloc>()
                                              .otpController
                                              .text,
                                          password: password,
                                          firebaseVerificationId: context
                                              .read<AuthBloc>()
                                              .firebaseVerificationId,
                                          loginAs:
                                              context.read<AuthBloc>().loginAs,
                                        ),
                                      );
                                } else {
                                  //password
                                  context.read<AuthBloc>().add(LoginUserEvent(
                                        emailOrMobile: email,
                                        otp: context
                                            .read<AuthBloc>()
                                            .otpController
                                            .text,
                                        password: password,
                                        isOtpLogin: context
                                            .read<AuthBloc>()
                                            .isOtpVerify,
                                        isLoginByEmail: true,
                                        loginAs:
                                            context.read<AuthBloc>().loginAs,
                                      ));
                                }
                              }
                            } else {
                              showToast(
                                  message: AppLocalizations.of(context)!
                                      .acceptTermsAndConditions);
                            }
                          },
                        )
                      // login by mobile only
                      : ((context.read<AuthBloc>().loginAs == 'driver' &&
                                  context.read<AuthBloc>().isDriverEmailLogin ==
                                      '0' &&
                                  context
                                          .read<AuthBloc>()
                                          .isDriverMobileLogin ==
                                      '1') ||
                              (context.read<AuthBloc>().loginAs != 'driver' &&
                                  context.read<AuthBloc>().isOwnerEmailLogin ==
                                      '0' &&
                                  context.read<AuthBloc>().isOwnerMobileLogin ==
                                      '1'))
                          ? CustomButton(
                              borderRadius: 12,
                              height: 52,
                              width: MediaQuery.sizeOf(context).width,
                              buttonName: (((((context.read<AuthBloc>().selectLoginMethods == false && context.read<AuthBloc>().isDriverSignInMobilePassword == '0' && context.read<AuthBloc>().isDriverSignInMobileOtp == '1' && context.read<AuthBloc>().isOtpVerify == false) ||
                                              (context.read<AuthBloc>().selectLoginMethods == true &&
                                                  context.read<AuthBloc>().isDriverSignInEmailPassword ==
                                                      '0' &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isDriverSignInEmailOtp ==
                                                      '1' &&
                                                  context.read<AuthBloc>().isOtpVerify ==
                                                      false))) &&
                                          context.read<AuthBloc>().choosenLoginAs ==
                                              'driver') ||
                                      ((((context.read<AuthBloc>().selectLoginMethods == false &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isOwnerSignInMobilePassword ==
                                                      '0' &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isOwnerSignInMobileOtp ==
                                                      '1' &&
                                                  context.read<AuthBloc>().isOtpVerify ==
                                                      false) ||
                                              (context.read<AuthBloc>().selectLoginMethods == true &&
                                                  context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                                  context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                                  context.read<AuthBloc>().isOtpVerify == false))) &&
                                          context.read<AuthBloc>().choosenLoginAs != 'driver'))
                                  ? 'Send OTP'
                                  : AppLocalizations.of(context)!.signIn,
                              textSize: 16,
                              isLoader: context.read<AuthBloc>().isLoading,
                              onTap: () {
                                if (context
                                        .read<AuthBloc>()
                                        .isTermsAndConditionsChecked ==
                                    true) {
                                  context.read<AuthBloc>().selectLoginMethods =
                                      false;
                                  FocusScope.of(context).unfocus();
                                  if (((context.read<AuthBloc>().selectLoginMethods == false &&
                                                  context.read<AuthBloc>().isDriverSignInMobilePassword ==
                                                      '0' &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isDriverSignInMobileOtp ==
                                                      '1' &&
                                                  context.read<AuthBloc>().isOtpVerify ==
                                                      false ||
                                              context.read<AuthBloc>().selectLoginMethods == true &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isDriverSignInEmailPassword ==
                                                      '0' &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isDriverSignInEmailOtp ==
                                                      '1' &&
                                                  context.read<AuthBloc>().isOtpVerify ==
                                                      false) &&
                                          context.read<AuthBloc>().loginAs ==
                                              'driver') ||
                                      ((context.read<AuthBloc>().selectLoginMethods == false &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isOwnerSignInMobilePassword ==
                                                      '0' &&
                                                  context
                                                          .read<AuthBloc>()
                                                          .isOwnerSignInMobileOtp ==
                                                      '1' &&
                                                  context.read<AuthBloc>().isOtpVerify ==
                                                      false ||
                                              context.read<AuthBloc>().selectLoginMethods == true &&
                                                  context.read<AuthBloc>().isOwnerSignInEmailPassword == '0' &&
                                                  context.read<AuthBloc>().isOwnerSignInEmailOtp == '1' &&
                                                  context.read<AuthBloc>().isOtpVerify == false) &&
                                          context.read<AuthBloc>().loginAs != 'driver')) {
                                    final authBloc = context.read<AuthBloc>();
                                    final mobileOrEmail =
                                        authBloc.rMobileController.text.trim();
                                    if (mobileOrEmail.isEmpty) {
                                      showToast(
                                          message: AppLocalizations.of(context)!
                                              .pleaseEnterMobileOrEmail);
                                    } else {
                                      final mobileNumber = context
                                          .read<AuthBloc>()
                                          .rMobileController
                                          .text
                                          .trim();

                                      context.read<AuthBloc>().add(
                                          VerifyUserEvent(
                                              loginAs: context
                                                  .read<AuthBloc>()
                                                  .loginAs,
                                              mobileOrEmail: mobileNumber,
                                              loginByMobile: false,
                                              forgotPassword: false));
                                    }
                                  } else {
                                    final mobileNumber = context
                                        .read<AuthBloc>()
                                        .rMobileController
                                        .text
                                        .trim();
                                    final password = context
                                        .read<AuthBloc>()
                                        .passwordController
                                        .text
                                        .trim();
                                    if (context.read<AuthBloc>().isOtpVerify) {
                                      //otp
                                      context.read<AuthBloc>().add(
                                            ConfirmOrVerifyOTPEvent(
                                              isUserExist: context
                                                  .read<AuthBloc>()
                                                  .userExist,
                                              isLoginByEmail: false,
                                              isOtpVerify: context
                                                  .read<AuthBloc>()
                                                  .isOtpVerify,
                                              isForgotPasswordVerify: false,
                                              mobileOrEmail: mobileNumber,
                                              otp: context
                                                  .read<AuthBloc>()
                                                  .otpController
                                                  .text,
                                              password: password,
                                              firebaseVerificationId: context
                                                  .read<AuthBloc>()
                                                  .firebaseVerificationId,
                                              loginAs: context
                                                  .read<AuthBloc>()
                                                  .loginAs,
                                            ),
                                          );
                                    } else {
                                      //password
                                      context
                                          .read<AuthBloc>()
                                          .add(LoginUserEvent(
                                            emailOrMobile: mobileNumber,
                                            otp: context
                                                .read<AuthBloc>()
                                                .otpController
                                                .text,
                                            password: password,
                                            isOtpLogin: context
                                                .read<AuthBloc>()
                                                .isOtpVerify,
                                            isLoginByEmail: false,
                                            loginAs: context
                                                .read<AuthBloc>()
                                                .loginAs,
                                          ));
                                    }
                                  }
                                } else {
                                  showToast(
                                      message: AppLocalizations.of(context)!
                                          .acceptTermsAndConditions);
                                }
                              },
                            )
                          : const SizedBox(),
        );
      },
    );
  }
}
