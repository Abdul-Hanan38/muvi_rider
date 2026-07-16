import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_appbar.dart';
import 'package:restart_tagxi/core/utils/custom_button.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/features/account/domain/models/contact_model.dart';
import 'package:restart_tagxi/features/account/presentation/pages/sos/widget/pick_contact.dart';
import 'package:restart_tagxi/features/account/presentation/pages/sos/widget/sos_card_shimmer.dart';
import 'package:restart_tagxi/features/auth/application/auth_bloc.dart';
import 'package:restart_tagxi/features/auth/presentation/widgets/select_country_widget.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';
import '../../../../../../common/common.dart';
import '../../../../application/acc_bloc.dart';

class SosPage extends StatelessWidget {
  static const String routeName = '/sosPage';
  final SOSPageArguments arg;

  const SosPage({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create: (context) => AccBloc()..add(SosInitEvent(arg: arg)),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is SelectContactDetailsState) {
            final accBloc = context.read<AccBloc>();
            showModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: true,
              useRootNavigator: true,
              isScrollControlled: true,
              builder: (_) {
                return BlocProvider.value(
                  value: accBloc,
                  child: const PickContact(),
                );
              },
            );
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final accBloc = context.watch<AccBloc>();
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final pageBg =
              isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
          final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
          final cardBorder =
              isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
          final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
          final textSecondary =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Scaffold(
              backgroundColor: pageBg,
              appBar: CustomAppBar(
                title: AppLocalizations.of(context)!.sosText,
                automaticallyImplyLeading: true,
                showBorder: false,
                onBackTap: () {
                  Navigator.pop(context, accBloc.sosdata);
                },
                actions: [
                  if (accBloc.sosdata.isNotEmpty && !accBloc.isSosLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.add_moderator_outlined,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                        size: 24,
                      ),
                    ),
                ],
              ),
              body: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (accBloc.isSosLoading)
                        Expanded(
                          child: ListView.builder(
                            itemCount: 6,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return SosShimmerLoading(size: size);
                            },
                          ),
                        )
                      else if (accBloc.sosdata.isEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  // Shield plus icon on top of illustration
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFEFF6FF),
                                    ),
                                    child: Icon(
                                      Icons.add_moderator_outlined,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Main illustration of man
                                  Image.asset(
                                    AppImages.sosNoDataImage,
                                    width: size.width * 0.75,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 32),
                                  // Group icon
                                  Container(
                                    height: 64,
                                    width: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF131B2E)
                                          : const Color(0xFFEFF6FF),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.group_outlined,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Title
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .sosNoContactsAdded,
                                    textStyle: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Subtext
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: MyText(
                                      text: AppLocalizations.of(context)!
                                          .sosSubTextAdded,
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        color: textSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                // Heading & contact count badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .sosEmergenctContactsText,
                                      textStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFEFF6FF),
                                      ),
                                      child: Text(
                                        "${accBloc.sosdata.length} ${accBloc.sosdata.length == 1 ? AppLocalizations.of(context)!.sosContactText : AppLocalizations.of(context)!.sosContactsText}",
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.secondary
                                              : AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                MyText(
                                  text: AppLocalizations.of(context)!
                                      .sosEmergenctSubText,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Contacts List
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: accBloc.sosdata.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = accBloc.sosdata[index];
                                    final nameLetter = (item.name != null &&
                                            item.name!.isNotEmpty)
                                        ? item.name![0].toUpperCase()
                                        : 'S';
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: cardBorder,
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Circular icon/avatar
                                          Container(
                                            height: 44,
                                            width: 44,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFEFF6FF),
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              nameLetter,
                                              style: TextStyle(
                                                color: isDark
                                                    ? AppColors.secondary
                                                    : AppColors.primary,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          // Name and Number
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText(
                                                  text: item.name ?? '',
                                                  textStyle: TextStyle(
                                                    color: textPrimary,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                MyText(
                                                  text: item.number ?? '',
                                                  textStyle: TextStyle(
                                                    color: textSecondary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Delete Button
                                          IconButton(
                                            onPressed: () {
                                              accBloc.add(SosLoadingEvent());
                                              accBloc.add(DeleteContactEvent(
                                                  id: item.id));
                                            },
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              color: Colors.red,
                                              size: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: accBloc.isSosLoading
                  ? null
                  : (accBloc.sosdata.isEmpty
                      ? SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Solid blue: Add from contacts
                                CustomButton(
                                  width: size.width,
                                  buttonName: AppLocalizations.of(context)!
                                      .sosAddFromContacts,
                                  leading: const Icon(
                                    Icons.person_add_alt_1_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  textSize: 16,
                                  isLoader: accBloc.isLoading,
                                  onTap: () {
                                    context.read<AccBloc>().selectedContact =
                                        ContactsModel(name: '', number: '');
                                    context
                                        .read<AccBloc>()
                                        .add(SelectContactDetailsEvent());
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Outlined: Add manually
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: isDark
                                          ? const Color(0xFF131B2E)
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      showAddManuallyBottomSheet(context);
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: isDark
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                      size: 20,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.addManually,
                                      style: TextStyle(
                                        color: isDark
                                            ? AppColors.secondary
                                            : AppColors.primary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Solid blue: Add a Contact
                                CustomButton(
                                  width: size.width,
                                  buttonName:
                                      AppLocalizations.of(context)!.addAContact,
                                  leading: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  textSize: 16,
                                  isLoader: accBloc.isLoading,
                                  onTap: () {
                                    context.read<AccBloc>().selectedContact =
                                        ContactsModel(name: '', number: '');
                                    context
                                        .read<AccBloc>()
                                        .add(SelectContactDetailsEvent());
                                  },
                                ),
                                const SizedBox(height: 12),
                                // Outlined: Add manually
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: isDark
                                          ? const Color(0xFF131B2E)
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      showAddManuallyBottomSheet(context);
                                    },
                                    icon: Icon(
                                      Icons.person_outline_rounded,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : const Color(0xFF0F2C82),
                                      size: 20,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(context)!.addManually,
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF60A5FA)
                                            : const Color(0xFF0F2C82),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Information Kept Secure Footer
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shield_outlined,
                                      size: 16,
                                      color: textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .sosInformationSecureText,
                                      textStyle: TextStyle(
                                        color: textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )));
        }),
      ),
    );
  }

  void showAddManuallyBottomSheet(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final accBloc = context.read<AccBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
        final fieldBg =
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
        final fieldBorder =
            isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
        final labelColor =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final valueColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final accentBlue = isDark ? AppColors.secondary : AppColors.primary;

        return BlocProvider(
          create: (_) => AuthBloc()
            ..add(GetDirectionEvent())
            ..add(CountryGetEvent())
            ..add(GetCommonModuleEvent()),
          child: Builder(
            builder: (bottomContext) {
              String? nameError;
              String? phoneError;

              return StatefulBuilder(
                builder: (ctx, setState) {
                  // ─── Shared decorated field builder ───────────────────────
                  Widget buildField({
                    required TextEditingController controller,
                    required String label,
                    required String hint,
                    required IconData icon,
                    TextInputType keyboardType = TextInputType.text,
                    String? error,
                    Widget? prefix,
                  }) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: labelColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: fieldBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: error != null
                                  ? Colors.redAccent
                                  : fieldBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (prefix != null) ...[
                                prefix,
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: fieldBorder,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.only(left: 14),
                                  child:
                                      Icon(icon, size: 20, color: accentBlue),
                                ),
                              Expanded(
                                child: TextField(
                                  controller: controller,
                                  keyboardType: keyboardType,
                                  style: TextStyle(
                                    color: valueColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: hint,
                                    hintStyle: TextStyle(
                                      color: labelColor.withOpacity(0.6),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 13, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(
                                  error,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }

                  return ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Container(
                      height: MediaQuery.of(sheetContext).size.height,
                      color: sheetBg,
                      child: Column(
                        children: [
                          // ── Drag Handle ──────────────────────────────────
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),

                          // ── Header Row ───────────────────────────────────
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              child: Row(
                                children: [
                                  // Close button
                                  GestureDetector(
                                    onTap: () => Navigator.pop(sheetContext),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E293B)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18,
                                        color: isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)!.addAContact,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: valueColor,
                                      ),
                                    ),
                                  ),
                                  // Person avatar icon
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          accentBlue,
                                          accentBlue.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Divider ──────────────────────────────────────
                          const SizedBox(height: 16),
                          Divider(
                            color: fieldBorder,
                            height: 1,
                            thickness: 1,
                          ),

                          // ── Form Fields ──────────────────────────────────
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.fromLTRB(
                                  20,
                                  24,
                                  20,
                                  MediaQuery.of(sheetContext)
                                          .viewInsets
                                          .bottom +
                                      16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Subtitle
                                  Text(
                                    AppLocalizations.of(context)!
                                        .sosFillContactDetailsBelow,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: labelColor,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // First Name
                                  buildField(
                                    controller: firstNameController,
                                    label:
                                        AppLocalizations.of(context)!.firstName,
                                    hint: "e.g. John",
                                    icon: Icons.person_outline_rounded,
                                    error: nameError,
                                  ),
                                  const SizedBox(height: 20),

                                  // Last Name
                                  buildField(
                                    controller: lastNameController,
                                    label:
                                        AppLocalizations.of(context)!.lastName,
                                    hint: "e.g. Doe",
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 20),

                                  // Phone label
                                  Text(
                                    AppLocalizations.of(context)!.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: labelColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Phone Row (country code + number field)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: fieldBg,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: phoneError != null
                                            ? Colors.redAccent
                                            : fieldBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // Country Code Picker
                                        BlocBuilder<AuthBloc, AuthState>(
                                          builder: (ctx, state) {
                                            final auth = ctx.read<AuthBloc>();
                                            return GestureDetector(
                                              onTap: () {
                                                final countries =
                                                    auth.countries;
                                                if (countries.isNotEmpty) {
                                                  showModalBottomSheet(
                                                    context: bottomContext,
                                                    isScrollControlled: true,
                                                    backgroundColor: Theme.of(
                                                            bottomContext)
                                                        .scaffoldBackgroundColor,
                                                    builder: (_) =>
                                                        SelectCountryWidget(
                                                      cont: bottomContext,
                                                      countries: countries,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 16),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.phone_outlined,
                                                      size: 18,
                                                      color: accentBlue,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      auth.dialCode,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: valueColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      size: 18,
                                                      color: labelColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Vertical separator
                                        Container(
                                          width: 1,
                                          height: 24,
                                          color: fieldBorder,
                                        ),
                                        // Phone Number input
                                        Expanded(
                                          child: TextField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            style: TextStyle(
                                              color: valueColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              hintText:
                                                  AppLocalizations.of(context)!
                                                      .phoneNumber,
                                              hintStyle: TextStyle(
                                                color:
                                                    labelColor.withOpacity(0.6),
                                                fontSize: 15,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (phoneError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 6, left: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              size: 13,
                                              color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            phoneError!,
                                            style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  const SizedBox(height: 32),

                                  // ── Security note ─────────────────────
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.shield_outlined,
                                          size: 18,
                                          color: accentBlue,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .sosContactDetailsPrivateAndSecure,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : AppColors.secondary,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Submit Button ─────────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                            decoration: BoxDecoration(
                              color: sheetBg,
                              border: Border(
                                top: BorderSide(
                                  color: fieldBorder,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: SafeArea(
                              top: false,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentBlue,
                                            accentBlue.withOpacity(0.75),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: accentBlue.withOpacity(0.35),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          final firstName =
                                              firstNameController.text.trim();
                                          final lastName =
                                              lastNameController.text.trim();
                                          final name =
                                              '$firstName $lastName'.trim();
                                          final rawNumber =
                                              phoneController.text.trim();

                                          setState(() {
                                            nameError = null;
                                            phoneError = null;
                                          });

                                          if (name.isEmpty) {
                                            setState(() {
                                              nameError =
                                                  AppLocalizations.of(context)!
                                                      .nameRequired;
                                            });
                                            return;
                                          }

                                          final localNumber =
                                              rawNumber.replaceAll(
                                                  RegExp(r'[^0-9]'), '');
                                          if (localNumber.isEmpty) {
                                            setState(() {
                                              phoneError =
                                                  AppLocalizations.of(context)!
                                                      .phoneNumberRequired;
                                            });
                                            return;
                                          }

                                          // Prefix with selected country dial code
                                          final auth =
                                              bottomContext.read<AuthBloc>();
                                          String dialCode = auth.dialCode;
                                          if (!dialCode.startsWith('+')) {
                                            dialCode = '+$dialCode';
                                          }
                                          final number =
                                              '$dialCode$localNumber';

                                          accBloc.add(SosLoadingEvent());
                                          accBloc.add(AddContactEvent(
                                              name: name, number: number));
                                          Navigator.pop(sheetContext);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.person_add_alt_1_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .addAContact,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
