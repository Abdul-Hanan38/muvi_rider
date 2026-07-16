import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/common/app_arguments.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/register_page.dart';

import '../../../../common/app_colors.dart';
import '../../../../core/model/user_detail_model.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../driverprofile/presentation/pages/driver_profile_pages.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../loading/application/loading_bloc.dart';
import '../../application/auth_bloc.dart';

class OtpPage extends StatefulWidget {
  static const String routeName = '/otpPage';
  final OtpPageArguments arg;

  const OtpPage({super.key, required this.arg});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with SingleTickerProviderStateMixin {
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
          } else if (state is GetCommonModuleSuccess) {
            CustomLoader.dismiss(context);
            final authBloc = context.read<AuthBloc>();
            authBloc.isOtpVerify = true;
            authBloc.add(
              SignInWithOTPEvent(
                isOtpVerify: true,
                isForgotPassword: false,
                mobileOrEmail: widget.arg.mobileOrEmail,
                dialCode: widget.arg.dialCode,
                isLoginByEmail: widget.arg.isLoginByEmail,
              ),
            );
            timerCount(context, duration: 60);
          } else if (state is GetCommonModuleFailure) {
            CustomLoader.dismiss(context);
          } else if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          } else if (state is LoginLoadingState) {
            CustomLoader.loader(context);
          } else if (state is LoginFailureState) {
            CustomLoader.dismiss(context);
          } else if (state is NewUserRegisterState) {
            if (mounted) {
              Navigator.pushNamed(context, RegisterPage.routeName,
                  arguments: RegisterPageArguments(
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    dialCode: widget.arg.dialCode,
                    contryCode: widget.arg.countryCode,
                    countryFlag: widget.arg.countryFlag,
                    emailOrMobile: widget.arg.mobileOrEmail,
                    countryList: widget.arg.countryList,
                    loginAs: widget.arg.type,
                    isRefferalEarnings: widget.arg.isRefferalEarnings,
                  ));
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
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final borderColor =
                isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
            final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;

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
                    AppLocalizations.of(context)!.verifyYourAccount,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          const _VerificationIllustration(),
                          const SizedBox(height: 24),
                          MyText(
                            text:
                                AppLocalizations.of(context)!.enterOtpCodeText,
                            textStyle: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColorDark,
                                  fontSize: 22,
                                ),
                          ),
                          const SizedBox(height: 6),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .sendVerificationCodeText,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Destination Info Card
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: borderColor, width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    widget.arg.isLoginByEmail
                                        ? Icons.email_outlined
                                        : Icons.phone_android_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (!widget.arg.isLoginByEmail) ...[
                                        MyText(
                                          text: "${widget.arg.dialCode} ",
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                        ),
                                      ],
                                      Expanded(
                                        child: MyText(
                                          text: widget.arg.mobileOrEmail,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: MyText(
                                    text: widget.arg.isLoginByEmail
                                        ? AppLocalizations.of(context)!
                                            .changeEmail
                                        : AppLocalizations.of(context)!
                                            .changeNumber,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          buildPinField(context, isDark),
                          // const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: Theme.of(context).hintColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  MyText(
                                    text: context
                                                .read<AuthBloc>()
                                                .timerDuration !=
                                            0
                                        ? '00:${context.read<AuthBloc>().timerDuration < 10 ? '0' : ''}${context.read<AuthBloc>().timerDuration}'
                                        : '00:00',
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 13,
                                        ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: context.read<AuthBloc>().timerDuration !=
                                        0
                                    ? null
                                    : () {
                                        final authBloc =
                                            context.read<AuthBloc>();
                                        authBloc.isOtpVerify = true;
                                        context.read<AuthBloc>().add(
                                              SignInWithOTPEvent(
                                                isOtpVerify: true,
                                                isForgotPassword: false,
                                                mobileOrEmail:
                                                    widget.arg.mobileOrEmail,
                                                dialCode: widget.arg.dialCode,
                                                isLoginByEmail:
                                                    widget.arg.isLoginByEmail,
                                              ),
                                            );
                                        timerCount(context, duration: 60);
                                      },
                                child: MyText(
                                  text: AppLocalizations.of(context)!.resendOtp,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: context
                                                    .read<AuthBloc>()
                                                    .timerDuration !=
                                                0
                                            ? Theme.of(context)
                                                .hintColor
                                                .withOpacity(0.5)
                                            : Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Code valid banner
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                      children: [
                                        TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .codeValidText),
                                        TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .codeValidTimeText,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          buildSendOtpButton(context),
                          const SizedBox(height: 24),
                          // Encrypted footnote
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Theme.of(context).hintColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .otpPageEncryptedText,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
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

  Widget buildPinField(BuildContext context, bool isDark) {
    return PinCodeTextField(
      appContext: context,
      controller: context.read<AuthBloc>().otpController,
      textStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColorDark,
          ),
      length: 6,
      autoFocus: true,
      obscureText: true,
      obscuringCharacter: '•',
      blinkWhenObscuring: false,
      animationType: AnimationType.fade,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 52,
        fieldWidth: 46,
        activeFillColor:
            isDark ? const Color(0xFF161B2E) : const Color(0xFFF9FAFB),
        inactiveFillColor:
            isDark ? const Color(0xFF161B2E) : const Color(0xFFF9FAFB),
        selectedFillColor:
            isDark ? const Color(0xFF161B2E) : const Color(0xFFF9FAFB),
        activeColor: isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB),
        inactiveColor:
            isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB),
        selectedColor: Theme.of(context).primaryColor,
        selectedBorderWidth: 1.5,
        inactiveBorderWidth: 1.2,
        activeBorderWidth: 1.2,
      ),
      cursorColor: Theme.of(context).primaryColor,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      enablePinAutofill: false,
      autoDisposeControllers: false,
      keyboardType: TextInputType.number,
      beforeTextPaste: (_) => false,
      onChanged: (_) => context.read<AuthBloc>().add(OTPOnChangeEvent()),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget buildSendOtpButton(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          borderRadius: 12,
          height: 52,
          leading: const Icon(
            Icons.verified_user_rounded,
            color: Colors.white,
            size: 20,
          ),
          width: MediaQuery.sizeOf(context).width,
          buttonName: AppLocalizations.of(context)!.loginVerifyText,
          textSize: 16,
          isLoader: context.read<AuthBloc>().isLoading,
          onTap: () {
            context.read<AuthBloc>().add(
                  ConfirmOrVerifyOTPEvent(
                    isUserExist: widget.arg.userExist,
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    isOtpVerify: context.read<AuthBloc>().isOtpVerify,
                    isForgotPasswordVerify: false,
                    mobileOrEmail: widget.arg.mobileOrEmail,
                    otp: context.read<AuthBloc>().otpController.text,
                    password: context.read<AuthBloc>().passwordController.text,
                    firebaseVerificationId:
                        context.read<AuthBloc>().firebaseVerificationId,
                    loginAs: context.read<AuthBloc>().loginAs,
                  ),
                );
          },
        );
      },
    );
  }
}

class _VerificationIllustration extends StatelessWidget {
  const _VerificationIllustration();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final circleColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF);
    final phoneBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final phoneBorderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFBFDBFE);
    final bubbleColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Center(
      child: SizedBox(
        width: 180,
        height: 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
            ),
            // Floating background bubbles/dots to mimic mock-up details
            Positioned(
              top: 30,
              left: 30,
              child: Icon(Icons.add,
                  size: 10, color: theme.primaryColor.withOpacity(0.4)),
            ),
            Positioned(
              bottom: 40,
              right: 25,
              child: Icon(Icons.add,
                  size: 12, color: theme.primaryColor.withOpacity(0.4)),
            ),
            // Smartphone Drawing
            Container(
              width: 58,
              height: 106,
              decoration: BoxDecoration(
                color: phoneBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: phoneBorderColor, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Speaker dot
                  Positioned(
                    top: 6,
                    child: Container(
                      width: 12,
                      height: 2,
                      decoration: BoxDecoration(
                        color: phoneBorderColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Screen border or placeholder
                  Positioned(
                    top: 14,
                    bottom: 6,
                    left: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: circleColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.phone_android_rounded,
                          size: 24,
                          color: theme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Overlapping Floating lock dialogue box
            Positioned(
              top: 35,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Blue Keyhole Lock icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Masked code dots
                    Row(
                      children: List.generate(6, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: index < 3
                                ? AppColors.primary
                                : const Color(0xFF9CA3AF),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
