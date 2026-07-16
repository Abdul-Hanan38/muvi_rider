import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/otp_page.dart';
import '../../../../common/app_validators.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../account/presentation/pages/settings/page/terms_privacy_policy_view_page.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';

class SignupMobilePage extends StatelessWidget {
  static const String routeName = '/SignupMobilePage';
  final SignupMobilePageArguments arg;

  const SignupMobilePage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          } else if (state is AuthDataLoadedState) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is ValidateMobileFailureState) {
          } else if (state is ValidateMobileSuccessState) {
            final authBloc = context.read<AuthBloc>();
            final mobileOrEmail = arg.mobileOrEmailSignUp
                ? authBloc.rEmailController.text.trim()
                : authBloc.rMobileController.text.trim();
            if (mobileOrEmail.isNotEmpty) {
              Navigator.pushNamed(context, OtpPage.routeName,
                  arguments: OtpPageArguments(
                      mobileOrEmail: mobileOrEmail,
                      dialCode: authBloc.dialCode,
                      countryCode: context.read<AuthBloc>().countryCode,
                      countryFlag: context.read<AuthBloc>().flagImage,
                      isLoginByEmail: arg.mobileOrEmailSignUp,
                      isOtpVerify: true,
                      userExist: context.read<AuthBloc>().userExist,
                      isDemoLogin: true,
                      countryList: context.read<AuthBloc>().countries,
                      isRefferalEarnings:
                          context.read<AuthBloc>().isRefferalEarnings,
                      type: arg.type));
            } else {
              showToast(
                  message:
                      AppLocalizations.of(context)!.pleaseEnterMobileNumber);
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                centerTitle: true,
                title: Text(
                  (arg.mobileOrEmailSignUp == false)
                      ? AppLocalizations.of(context)!.verifyPhone
                      : AppLocalizations.of(context)!.verifyEmailText,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).primaryColorDark),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        const _SignupIllustration(),
                        const SizedBox(height: 24),
                        MyText(
                          text: (arg.mobileOrEmailSignUp == false)
                              ? AppLocalizations.of(context)!.verifyMobileNumber
                              : AppLocalizations.of(context)!.verifyEmailId,
                          textAlign: TextAlign.center,
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
                          text: (arg.mobileOrEmailSignUp == false)
                              ? AppLocalizations.of(context)!
                                  .signupPasswordSendMobileText
                              : AppLocalizations.of(context)!
                                  .signupPasswordSendEmailText,
                          textAlign: TextAlign.center,
                          textStyle:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14,
                                  ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 28),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: MyText(
                            text: (arg.mobileOrEmailSignUp == false)
                                ? AppLocalizations.of(context)!.mobileNumber
                                : AppLocalizations.of(context)!.email,
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
                        if (arg.mobileOrEmailSignUp == false) ...[
                          buildMobileField(context, size),
                        ] else ...[
                          buildEmailField(context)
                        ],
                        const SizedBox(height: 14),
                        // Terms Info Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                        ),
                                    children: [
                                      TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .signupContinuingAgreementText),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              TermsPrivacyPolicyViewPage
                                                  .routeName,
                                              arguments:
                                                  TermsAndPrivacyPolicyArguments(
                                                isPrivacyPolicy: false,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .termsOfService,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .signupAndText),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              TermsPrivacyPolicyViewPage
                                                  .routeName,
                                              arguments:
                                                  TermsAndPrivacyPolicyArguments(
                                                isPrivacyPolicy: true,
                                              ),
                                            );
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .privacyPolicyText,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const TextSpan(text: "."),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildSendOtpButton(context),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MyText(
                              text:
                                  '${AppLocalizations.of(context)!.alreadyHaveAccount} ',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14,
                                  ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    LoginPage.routeName, (route) => false,
                                    arguments:
                                        LoginPageArguments(type: arg.type));
                              },
                              child: MyText(
                                text: AppLocalizations.of(context)!.signIn,
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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

    return CustomTextField(
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
                          image:
                              NetworkImage(context.read<AuthBloc>().flagImage),
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
        if (value!.isNotEmpty && !AppValidation.mobileNumberValidate(value)) {
          return AppLocalizations.of(context)!.enterValidMobile;
        } else if (value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterMobileNumber;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildEmailField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return CustomTextField(
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
    );
  }

  Widget buildSendOtpButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: CustomButton(
            borderRadius: 12,
            height: 52,
            width: MediaQuery.sizeOf(context).width,
            buttonName: AppLocalizations.of(context)!.sendOtp,
            textSize: 16,
            isLoader: context.read<AuthBloc>().isLoading,
            onTap: () {
              final mobileNumber =
                  context.read<AuthBloc>().rMobileController.text.trim();
              final email = context.read<AuthBloc>().rEmailController.text;
              context.read<AuthBloc>();
              final bool isEmail = AppValidation.emailValidate(email);
              if (arg.mobileOrEmailSignUp == true) {
                if (email.isEmpty) {
                  showToast(
                    message: AppLocalizations.of(context)!.enterEmail,
                  );
                  return;
                }

                if (!isEmail) {
                  showToast(
                    message: AppLocalizations.of(context)!.enterValidEmail,
                  );
                  return;
                }
                context.read<AuthBloc>().add(
                      ValidateMobileEvent(
                        loginAs: arg.type,
                        mobileOrEmail: email,
                        isLoginByEmail: true,
                      ),
                    );
              } else {
                if (mobileNumber.isEmpty) {
                  showToast(
                    message:
                        AppLocalizations.of(context)!.pleaseEnterMobileNumber,
                  );
                  return;
                }

                if (!AppValidation.mobileNumberValidate(mobileNumber)) {
                  showToast(
                    message: AppLocalizations.of(context)!.enterValidMobile,
                  );
                  return;
                }

                context.read<AuthBloc>().add(
                      ValidateMobileEvent(
                        loginAs: arg.type,
                        mobileOrEmail: mobileNumber,
                        isLoginByEmail: false,
                      ),
                    );
              }
            },
          ),
        );
      },
    );
  }
}

class _SignupIllustration extends StatelessWidget {
  const _SignupIllustration();

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
              Icons.phone_rounded,
              color: Theme.of(context).primaryColor,
              size: 70,
            ),
            Positioned(
              bottom: 35,
              right: 35,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
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
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
