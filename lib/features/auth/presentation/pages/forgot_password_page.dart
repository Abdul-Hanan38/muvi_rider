import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:restart_tagxi/features/auth/presentation/pages/login_page.dart';

import '../../../../common/common.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/auth_bloc.dart';
import 'update_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const String routeName = '/forgotPasswordPage';
  final ForgotPasswordPageArguments arg;
  const ForgotPasswordPage({super.key, required this.arg});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
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
    return BlocProvider(
      create: (context) => AuthBloc()..add(GetDirectionEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitialState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadingState) {
            CustomLoader.loader(context);
          }
          if (state is AuthDataLoadedState) {
            final authBloc = context.read<AuthBloc>();
            CustomLoader.dismiss(context);
            authBloc.isOtpVerify = true;
            authBloc.add(
              SignInWithOTPEvent(
                isOtpVerify: true,
                isForgotPassword: true,
                dialCode: widget.arg.contryCode,
                mobileOrEmail: widget.arg.emailOrMobile,
                isLoginByEmail: widget.arg.isLoginByEmail,
              ),
            );
            timerCount(context, duration: 60);
          }
          if (state is AuthDataSuccessState) {
            CustomLoader.dismiss(context);
          }
          if (state is ForgotPasswordOTPVerifyState) {
            Navigator.pushNamed(context, UpdatePasswordPage.routeName,
                arguments: UpdatePasswordPageArguments(
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    emailOrMobile: widget.arg.emailOrMobile));
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
                    AppLocalizations.of(context)!.forgotPassword,
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
                            const _VerificationIllustration(),
                            const SizedBox(height: 24),
                            MyText(
                              text: AppLocalizations.of(context)!
                                  .enterOtpCodeText,
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
                                  horizontal: 16, vertical: 12),
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
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (!widget.arg.isLoginByEmail) ...[
                                          MyText(
                                            text: "${widget.arg.contryCode} ",
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
                                            text: widget.arg.emailOrMobile,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          LoginPage.routeName,
                                          (route) => false);
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
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            buildPinField(context),
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
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
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
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .codeValidText),
                                          TextSpan(
                                            text: AppLocalizations.of(context)!
                                                .codeValidTimeText,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                            buildButton(context),
                            const SizedBox(height: 24),
                            // Information secure annotation
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: Theme.of(context).hintColor,
                                  size: 15,
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
                            const SizedBox(height: 16),
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
        buttonName: AppLocalizations.of(context)!.confirm,
        borderRadius: 12,
        height: 52,
        textSize: 16,
        leading: const Icon(
          Icons.shield_outlined,
          color: Colors.white,
          size: 20,
        ),
        width: MediaQuery.sizeOf(context).width,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          context.read<AuthBloc>().add(
                ConfirmOrVerifyOTPEvent(
                    isUserExist: true,
                    isLoginByEmail: widget.arg.isLoginByEmail,
                    isOtpVerify: true,
                    isForgotPasswordVerify: true,
                    mobileOrEmail: widget.arg.emailOrMobile,
                    otp: context.read<AuthBloc>().otpController.text,
                    password: '',
                    firebaseVerificationId:
                        context.read<AuthBloc>().firebaseVerificationId,
                    loginAs: context.read<AuthBloc>().loginAs),
              );
        },
      ),
    );
  }

  Widget buildPinField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: AppLocalizations.of(context)!.enterOtp,
          textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
        ),
        const SizedBox(height: 10),
        PinCodeTextField(
          appContext: context,
          controller: context.read<AuthBloc>().otpController,
          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
          length: 6,
          autoFocus: true,
          obscureText: true,
          obscuringCharacter: '•',
          blinkWhenObscuring: true,
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
            activeColor:
                isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB),
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
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 4),
                MyText(
                  text: context.read<AuthBloc>().timerDuration != 0
                      ? '${AppLocalizations.of(context)!.resendOtp} in 00:${context.read<AuthBloc>().timerDuration < 10 ? '0' : ''}${context.read<AuthBloc>().timerDuration}'
                      : '${AppLocalizations.of(context)!.resendOtp} in 00:00',
                  textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
            InkWell(
              onTap: context.read<AuthBloc>().timerDuration != 0
                  ? null
                  : () {
                      context.read<AuthBloc>().add(
                            SignInWithOTPEvent(
                              isOtpVerify: true,
                              isForgotPassword: true,
                              dialCode: widget.arg.contryCode,
                              mobileOrEmail: widget.arg.emailOrMobile,
                              isLoginByEmail: widget.arg.isLoginByEmail,
                            ),
                          );
                      timerCount(context, duration: 60);
                    },
              child: MyText(
                text: AppLocalizations.of(context)!.resendOtp,
                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.read<AuthBloc>().timerDuration != 0
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).primaryColor,
                    ),
              ),
            ),
          ],
        ),
      ],
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
            Positioned(
              bottom: 15,
              child: Container(
                width: 70,
                height: 110,
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
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: phoneBorderColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 3,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: phoneBorderColor,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "*** ---",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.hintColor,
                        letterSpacing: 2,
                      ),
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
