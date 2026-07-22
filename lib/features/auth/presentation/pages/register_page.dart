import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/common.dart';
import '../../../../core/model/user_detail_model.dart';
import '../../../../core/utils/custom_button.dart';
import '../../../../core/utils/custom_loader.dart';
import '../../../../core/utils/custom_snack_bar.dart';
import '../../../../core/utils/custom_text.dart';
import '../../../../core/utils/custom_textfield.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home/presentation/pages/home_page/page/home_page.dart';
import '../../../loading/application/loading_bloc.dart';
import '../../application/auth_bloc.dart';
import '../widgets/select_country_widget.dart';
import 'apply_refferal_page.dart';

class RegisterPage extends StatelessWidget {
  static const String routeName = '/registerPage';
  final RegisterPageArguments arg;
  const RegisterPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AuthBloc()
        ..add(GetDirectionEvent())
        ..add(RegisterPageInitEvent(arg: arg)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
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
          if (state is LoginSuccessState) {
            if (userData != null) {
              context.read<LoaderBloc>().add(UpdateUserLocationEvent());
            }
            if (arg.isRefferalEarnings == "1") {
              Navigator.pushNamedAndRemoveUntil(
                  context, ApplyRefferalPage.routeName, (route) => false);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomePage.routeName, (route) => false,
                  arguments: HomePageArguments(isFromHistory: true, from: '0'));
            }
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final borderColor =
                isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
            final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Theme.of(context).primaryColorDark),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.register,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            child: Form(
                              key: context.read<AuthBloc>().formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  // Create Account Header Row
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E293B)
                                              : const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: AppColors.primary,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .signupCreateAccountText,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColorDark,
                                                    fontSize: 20,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            MyText(
                                              text: AppLocalizations.of(
                                                      context)!
                                                  .signupCreateAccountSubText,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Profile Picture Section
                                  Center(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2,
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
                                                BorderRadius.circular(50),
                                            child: context
                                                    .read<AuthBloc>()
                                                    .profileImage
                                                    .isNotEmpty
                                                ? Image.file(
                                                    File(context
                                                        .read<AuthBloc>()
                                                        .profileImage),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AppImages.defaultProfile,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.defaultProfile,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            _showImageSourceSheet(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.15),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                              height: 32,
                                              width: 32,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Center(
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .addProfilePhoto,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 13,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Personal Information Card Container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: fillColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: borderColor, width: 1.2),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .personalInformation,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                        ),
                                        const SizedBox(height: 20),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .fullName,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        buildUserNameField(context, size),
                                        const SizedBox(height: 20),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .mobileNumber,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        buildMobileField(context, size),
                                        const SizedBox(height: 20),
                                        // 🚀 Email Title Updated from Optional to Standard Required Field
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .email,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        buildEmailField(context, size),
                                        const SizedBox(height: 20),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .gender,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        buildDropDownGenderField(context),
                                        const SizedBox(height: 20),
                                        MyText(
                                          text: AppLocalizations.of(context)!
                                              .password,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColorDark,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        buildPasswordField(context, size),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: buildButton(context),
                      ),
                    ],
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
        buttonName: AppLocalizations.of(context)!.register,
        borderRadius: 12,
        height: 52,
        textSize: 16,
        width: MediaQuery.sizeOf(context).width,
        isLoader: context.read<AuthBloc>().isLoading,
        onTap: () {
          final authBloc = context.read<AuthBloc>();

          //  Check if Profile Picture is uploaded
          if (authBloc.profileImage.isEmpty) {
            showToast(message: AppLocalizations.of(context)!.pleaseSelectImage);
            return;
          }

          if (authBloc.formKey.currentState!.validate() &&
              !authBloc.isLoading) {
            authBloc.add(RegisterUserEvent(
                userName: authBloc.rUserNameController.text,
                mobileNumber: authBloc.rMobileController.text,
                emailAddress: authBloc.rEmailController.text,
                password: authBloc.rPasswordController.text,
                countryCode: authBloc.countryCode,
                gender: authBloc.selectedGender,
                loginAs: arg.loginAs,
                profileImage: authBloc.profileImage));
          }
        },
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).splashColor,
      builder: (_) => Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 1,
                  spreadRadius: 1)
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.camera,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.camera));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                size: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              title: MyText(
                text: AppLocalizations.of(context)!.gallery,
                textStyle: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Theme.of(context).primaryColorDark),
              ),
              onTap: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(ImageUpdateEvent(source: ImageSource.gallery));
              },
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.08,
            )
          ],
        ),
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
      filled: true,
      borderRadius: 12,
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
      hintText: AppLocalizations.of(context)!.enterYourPassword,
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

  Widget buildEmailField(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return CustomTextField(
      controller: context.read<AuthBloc>().rEmailController,
      enabled: !context.read<AuthBloc>().isLoginByEmail,
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
      hintText: AppLocalizations.of(context)!.enterYourEmail,
      prefixIcon: Icon(
        Icons.email_outlined,
        color: Theme.of(context).hintColor,
        size: 20,
      ),
      // 🚀 Updated Validator to enforce compulsory email entry & format check
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.enterYourEmail;
        } else if (!AppValidation.emailValidate(value.trim())) {
          return AppLocalizations.of(context)!.enterValidEmail;
        } else {
          return null;
        }
      },
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
                    countries: arg.countryList, cont: context);
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

  Widget buildUserNameField(BuildContext context, Size size) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    return CustomTextField(
      controller: context.read<AuthBloc>().rUserNameController,
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
      hintText: AppLocalizations.of(context)!.signupEnterYourFullName,
      prefixIcon: Icon(
        Icons.person_outline_rounded,
        color: Theme.of(context).hintColor,
        size: 20,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterUserName;
        } else {
          return null;
        }
      },
    );
  }

  Widget buildDropDownGenderField(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFE5E7EB);
    final fillColor = isDark ? const Color(0xFF161B2E) : Colors.white;

    List<String> showGenderList = [
      AppLocalizations.of(context)!.male,
      AppLocalizations.of(context)!.female,
      AppLocalizations.of(context)!.preferNotSay,
    ];
    return DropdownButtonFormField(
      isExpanded: true,
      hint: Text(
        AppLocalizations.of(context)!.selectGender,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(fontSize: 14, color: Theme.of(context).hintColor),
      ),
      style: Theme.of(context).textTheme.bodyMedium!,
      dropdownColor: theme.scaffoldBackgroundColor,
      icon: const Icon(Icons.keyboard_arrow_down_outlined,
          color: Color(0xFF6B7280)),
      iconSize: 20,
      elevation: 10,
      onChanged: (newValue) {
        int index = showGenderList.indexOf(newValue.toString());
        if (index != -1) {
          String codedValue = context.read<AuthBloc>().genderList[index];
          context.read<AuthBloc>().selectedGender = codedValue;
        }
      },
      items: showGenderList.map<DropdownMenuItem>((value) {
        return DropdownMenuItem(
          value: value,
          alignment: AlignmentDirectional.centerStart,
          child: MyText(text: value),
        );
      }).toList(),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: Theme.of(context).hintColor,
          size: 20,
        ),
        filled: true,
        fillColor: fillColor,
        errorStyle: TextStyle(
          color: AppColors.red.withAlpha((0.8 * 255).toInt()),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: AppColors.errorLight.withAlpha((0.8 * 255).toInt()),
              width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.errorLight.withAlpha((0.5 * 255).toInt()),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (context.read<AuthBloc>().selectedGender.isEmpty) {
          return AppLocalizations.of(context)!.enterRequiredField;
        } else {
          return null;
        }
      },
    );
  }
}
