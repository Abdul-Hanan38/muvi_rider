import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/features/account/application/acc_bloc.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings/page/faq_page.dart';
import 'package:restart_tagxi/features/account/presentation/pages/settings/page/map_settings.dart';
import 'package:restart_tagxi/features/language/presentation/page/choose_language_page.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../widgets/menu_options.dart';
import 'terms_privacy_policy_view_page.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settingsPage';
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(AccGetDirectionEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) async {
          if (state is DeleteAccountSuccess) {
            Navigator.pushNamedAndRemoveUntil(
                context, ChooseLanguagePage.routeName, (route) => false,
                arguments: ChangeLanguageArguments(from: 0));
            await AppSharedPreference.setLoginStatus(false);
            await AppSharedPreference.setToken('');
          } else if (state is DeleteAccountFailureState) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final scaffoldBgColor =
                isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC);
            return Scaffold(
              backgroundColor: scaffoldBgColor,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.settings,
                automaticallyImplyLeading: true,
                titleFontSize: 18,
                showBorder: false,
                backgroundColor: scaffoldBgColor,
                textColor: isDark ? Colors.white : const Color(0xFF1F2937),
                leadingColor: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverGap(size.height * 0.03),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    sliver: SliverSection(
                      child: MenuSectionCard(
                        children: [
                          MenuOptions(
                            icon: Icons.palette_outlined,
                            iconColor: const Color(0xFF6366F1),
                            iconbackground: isDark
                                ? const Color(0xFF312E81).withOpacity(0.3)
                                : const Color(0xFFEEF2FF),
                            label: AppLocalizations.of(context)!.theme,
                            subtitle:
                                AppLocalizations.of(context)!.themeLableText,
                            showTheme: true,
                            onTap: () {},
                          ),
                          customDivider(context),
                          if (userData!.enableMapAppearanceChange == '1') ...[
                            MenuOptions(
                              icon: Icons.map_outlined,
                              iconColor: const Color(0xFF10B981),
                              iconbackground: isDark
                                  ? const Color(0xFF064E3B).withOpacity(0.3)
                                  : const Color(0xFFECFDF5),
                              label:
                                  AppLocalizations.of(context)!.mapAppearance,
                              subtitle:
                                  AppLocalizations.of(context)!.mapLableText,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  MapSettingsPage.routeName,
                                );
                              },
                            ),
                            customDivider(context),
                          ],
                          if (userData!.role != 'owner') ...[
                            MenuOptions(
                              icon: Icons.help_outline_rounded,
                              iconColor: const Color(0xFF3B82F6),
                              iconbackground: isDark
                                  ? const Color(0xFF1E3A8A).withOpacity(0.3)
                                  : const Color(0xFFEFF6FF),
                              label: AppLocalizations.of(context)!.faq,
                              subtitle:
                                  AppLocalizations.of(context)!.faqLableText,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  FaqPage.routeName,
                                );
                              },
                            ),
                            customDivider(context),
                          ],
                          MenuOptions(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            iconbackground: isDark
                                ? const Color(0xFF4C1D95).withOpacity(0.3)
                                : const Color(0xFFF5F3FF),
                            label: AppLocalizations.of(context)!.privacy,
                            subtitle: AppLocalizations.of(context)!
                                .privacyPolicyLableText,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                TermsPrivacyPolicyViewPage.routeName,
                                arguments: TermsAndPrivacyPolicyArguments(
                                    isPrivacyPolicy: true),
                              );
                            },
                          ),
                          customDivider(context),
                          MenuOptions(
                            icon: Icons.delete_outline_rounded,
                            iconColor: const Color(0xFFEF4444),
                            iconbackground: isDark
                                ? const Color(0xFF7F1D1D).withOpacity(0.3)
                                : const Color(0xFFFEF2F2),
                            label: AppLocalizations.of(context)!.deleteAccount,
                            subtitle: AppLocalizations.of(context)!
                                .deleteAccountLableText,
                            textColor: const Color(0xFFEF4444),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext _) {
                                  return BlocProvider.value(
                                    value: BlocProvider.of<AccBloc>(context),
                                    child: CustomSingleButtonDialoge(
                                      title: userData!.isDeletedAt.isEmpty
                                          ? '${AppLocalizations.of(context)!.deleteAccount} ?'
                                          : AppLocalizations.of(context)!
                                              .deleteAccount,
                                      content: userData!.isDeletedAt.isEmpty
                                          ? AppLocalizations.of(context)!
                                              .deleteText
                                          : userData!.isDeletedAt,
                                      btnName: userData!.isDeletedAt.isEmpty
                                          ? AppLocalizations.of(context)!
                                              .deleteAccount
                                          : AppLocalizations.of(context)!.ok,
                                      btnColor: AppColors.errorLight,
                                      isLoader:
                                          context.read<AccBloc>().isLoading,
                                      onTap: () {
                                        if (userData!.isDeletedAt.isEmpty) {
                                          context
                                              .read<AccBloc>()
                                              .add(DeleteAccountEvent());
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverGap(30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class MenuSectionCard extends StatelessWidget {
  final List<Widget> children;

  const MenuSectionCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF131C2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorderColor, width: 1),
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
      child: Column(children: children),
    );
  }
}

Widget customDivider(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Divider(
    height: 1,
    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    indent: 70,
    endIndent: 16,
  );
}

class SliverSection extends StatelessWidget {
  final Widget child;
  const SliverSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: child);
  }
}

class SliverGap extends StatelessWidget {
  final double height;
  const SliverGap(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: SizedBox(height: height));
  }
}
