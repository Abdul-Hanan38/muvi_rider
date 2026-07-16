// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:restart_tagxi/core/utils/custom_snack_bar.dart';
import '../../../../../../common/common.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../core/utils/custom_loader.dart';
import '../../../../../../core/utils/custom_text.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/acc_bloc.dart';
import 'add_card_details.dart';

class CardListWidget extends StatelessWidget {
  static const String routeName = '/cardListWidget';
  final PaymentMethodArguments arg;
  const CardListWidget({super.key, required this.arg});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => AccBloc()
        ..add(AccGetDirectionEvent())
        ..add(PaymentAuthenticationEvent(arg: arg))
        ..add(CardListEvent()),
      child: BlocListener<AccBloc, AccState>(
        listener: (context, state) {
          if (state is AccDataLoadingStartState) {
            CustomLoader.loader(context);
          } else if (state is AccDataLoadingStopState) {
            CustomLoader.dismiss(context);
          } else if (state is SaveCardSuccessState) {
            Navigator.pop(context);
            context.read<AccBloc>().add(CardListEvent());
          }
        },
        child: BlocBuilder<AccBloc, AccState>(builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final scaffoldBg =
              isDark ? const Color(0xFF080F19) : const Color(0xFFF8FAFC);
          final cardBg = isDark ? const Color(0xFF0D1623) : Colors.white;
          final cardBorder = isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE2E8F0);
          final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
          final subtitleColor =
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
          final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;
          final isRtl = context.read<AccBloc>().textDirection == 'rtl';

          return Scaffold(
            backgroundColor: scaffoldBg,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: SafeArea(
                child: Container(
                  color: scaffoldBg,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PositionedDirectional(
                        start: 0,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(12),
                          child: Icon(
                            isRtl ? Icons.arrow_forward : Icons.arrow_back,
                            color: titleColor,
                            size: 22,
                          ),
                        ),
                      ),
                      MyText(
                        text: AppLocalizations.of(context)!.savedCards,
                        textStyle: TextStyle(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.05,
                0,
                size.width * 0.05,
                size.width * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero illustration
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF162032)
                            : const Color(0xFFEEF2FF),
                      ),
                      child: Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: primaryBlue,
                              size: 70,
                            ),
                            Positioned(
                              right: -8,
                              bottom: -4,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0D1623)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cardBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.shield_rounded,
                                  color: primaryBlue,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title and subtitle
                  MyText(
                    text: AppLocalizations.of(context)!.selectCards,
                    textStyle: TextStyle(
                      color: titleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  MyText(
                    text: AppLocalizations.of(context)!.selectCardText,
                    textStyle: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Add Card Button
                  InkWell(
                    onTap: () {
                      context.read<AccBloc>().isLoading = false;
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) {
                          return BlocProvider.value(
                            value: context.read<AccBloc>(),
                            child: addCardDetails(context, size),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryBlue,
                          width: 1.5,
                        ),
                        color: isDark
                            ? primaryBlue.withValues(alpha: 0.06)
                            : const Color(0xFFEFF6FF),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 24,
                            width: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: primaryBlue, width: 1.5),
                            ),
                            child: Icon(
                              Icons.add,
                              color: primaryBlue,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          MyText(
                            text: AppLocalizations.of(context)!.addCard,
                            textStyle: TextStyle(
                              color: primaryBlue,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // "Your Saved Cards" header
                  MyText(
                    text: AppLocalizations.of(context)!.yourSavedCardsText,
                    textStyle: TextStyle(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (context.read<AccBloc>().savedCardsList.isNotEmpty) ...[
                    // Cards list container
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder, width: 1),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      child: ListView.separated(
                        itemCount:
                            context.read<AccBloc>().savedCardsList.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final card = context
                              .read<AccBloc>()
                              .savedCardsList
                              .elementAt(index);
                          final isFirst = index == 0;
                          final isLast = index ==
                              context.read<AccBloc>().savedCardsList.length - 1;

                          return ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: isFirst
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              topRight: isFirst
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomLeft: isLast
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              bottomRight: isLast
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  // Card brand logo
                                  SizedBox(
                                    width: 52,
                                    child: _buildCardLogo(
                                        card.cardType, size, isDark),
                                  ),
                                  const SizedBox(width: 12),

                                  // Masked number + expiry
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text:
                                              '•••• ••• •••• ${card.lastNumber}',
                                          textStyle: TextStyle(
                                            color: titleColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (card.validThrough.isNotEmpty)
                                          MyText(
                                            text:
                                                'Expires ${card.validThrough}',
                                            textStyle: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Active badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF064E3B)
                                          : const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: MyText(
                                      text:
                                          AppLocalizations.of(context)!.active,
                                      textStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFF15803D),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // 3-dot delete action
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (cont) {
                                          return CustomDoubleButtonDialoge(
                                            title: AppLocalizations.of(context)!
                                                .delete,
                                            content:
                                                AppLocalizations.of(context)!
                                                    .deleteCardText,
                                            yesBtnName:
                                                AppLocalizations.of(context)!
                                                    .yes,
                                            noBtnName:
                                                AppLocalizations.of(context)!
                                                    .no,
                                            yesBtnFunc: () {
                                              Navigator.pop(cont);
                                              context.read<AccBloc>().add(
                                                  DeleteCardEvent(
                                                      cardId: card.id));
                                            },
                                          );
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 1,
                            thickness: 1,
                            color: cardBorder,
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Empty state container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder, width: 1),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 32, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF162032)
                                    : const Color(0xFFEFF6FF),
                              ),
                              child: Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.credit_card_rounded,
                                      color: primaryBlue,
                                      size: 50,
                                    ),
                                    Positioned(
                                      right: -2,
                                      bottom: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: primaryBlue,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: cardBg,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          MyText(
                            text: AppLocalizations.of(context)!.noSaveCardsText,
                            textStyle: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          MyText(
                            text: AppLocalizations.of(context)!
                                .saveCardMAnagePaymentsSecurelyText,
                            textAlign: TextAlign.center,
                            textStyle: TextStyle(
                              color: subtitleColor,
                              fontSize: 13,
                              height: 1.4,
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Security info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF162032)
                          : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorder, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFDCE8FF),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            color: primaryBlue,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .saveCardInforSecure,
                                textStyle: TextStyle(
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              MyText(
                                text: AppLocalizations.of(context)!
                                    .saveCardEncryptionText,
                                textStyle: TextStyle(
                                  color: subtitleColor,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCardLogo(String cardType, Size size, bool isDark) {
    final type = cardType.toLowerCase();
    Widget img;
    if (type.contains('visa')) {
      img = Image.asset(AppImages.visa,
          height: size.width * 0.06, fit: BoxFit.contain);
    } else if (type.contains('eftpos')) {
      img = Image.asset(AppImages.eftpos,
          height: size.width * 0.06, fit: BoxFit.contain);
    } else if (type.contains('american')) {
      img = Image.asset(AppImages.americanExpress,
          height: size.width * 0.06, fit: BoxFit.contain);
    } else if (type.contains('jcb')) {
      img = Image.asset(AppImages.jcb,
          height: size.width * 0.06, fit: BoxFit.contain);
    } else if (type.contains('discover') || type.contains('dinners')) {
      img = Image.asset(AppImages.discover,
          height: size.width * 0.06, fit: BoxFit.contain);
    } else {
      img = Image.asset(AppImages.master,
          height: size.width * 0.06, fit: BoxFit.contain);
    }

    if (!isDark) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: img,
      );
    }
    return img;
  }
}

class AddCardDetailsSheet extends StatefulWidget {
  final Size size;
  const AddCardDetailsSheet({super.key, required this.size});

  @override
  State<AddCardDetailsSheet> createState() => _AddCardDetailsSheetState();
}

class _AddCardDetailsSheetState extends State<AddCardDetailsSheet> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _postcodeController = TextEditingController();

  String _cardBrand = 'unknown';

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _cardNumberController.removeListener(_onCardNumberChanged);
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final brand = _detectCardBrand(_cardNumberController.text);
    if (brand != _cardBrand) {
      setState(() {
        _cardBrand = brand;
      });
    }
  }

  String _detectCardBrand(String number) {
    final cleanNum = number.replaceAll(' ', '');
    if (cleanNum.startsWith('4')) {
      return 'visa';
    } else if (cleanNum.startsWith(RegExp(r'^5[1-5]')) ||
        cleanNum.startsWith(RegExp(r'^2[2-7]'))) {
      return 'mastercard';
    } else if (cleanNum.startsWith('34') || cleanNum.startsWith('37')) {
      return 'americanExpress';
    } else if (cleanNum.startsWith('35')) {
      return 'jcb';
    } else if (cleanNum.startsWith(RegExp(r'^6011')) ||
        cleanNum.startsWith('65')) {
      return 'discover';
    }
    return 'unknown';
  }

  Widget _buildInputCardLogo(String cardType) {
    final type = cardType.toLowerCase();
    if (type.contains('visa')) {
      return Image.asset(AppImages.visa, height: 18, fit: BoxFit.contain);
    } else if (type.contains('american')) {
      return Image.asset(AppImages.americanExpress,
          height: 18, fit: BoxFit.contain);
    } else if (type.contains('jcb')) {
      return Image.asset(AppImages.jcb, height: 18, fit: BoxFit.contain);
    } else if (type.contains('discover')) {
      return Image.asset(AppImages.discover, height: 18, fit: BoxFit.contain);
    } else if (type.contains('mastercard')) {
      return Image.asset(AppImages.master, height: 18, fit: BoxFit.contain);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildInputField({
    required String label,
    required Widget child,
    required bool isDark,
    required Color fieldBorder,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111A2E) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fieldBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            text: label,
            textStyle: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccBloc, AccState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF0D1623) : Colors.white;
        final fieldBorder = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFE2E8F0);
        final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
        final subtitleColor =
            isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        final primaryBlue =
            isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B2EC2);

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: AppLocalizations.of(context)!.enterCardDetails,
                          textStyle: TextStyle(
                            color: titleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: fieldBorder, width: 1.5),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: subtitleColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card Number Field
                    _buildInputField(
                      label: 'Card Number',
                      isDark: isDark,
                      fieldBorder: fieldBorder,
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card_rounded,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CardNumberInputFormatter(),
                              ],
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '1234 5678 9012 3456',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_cardBrand != 'unknown') ...[
                            const SizedBox(width: 8),
                            _buildInputCardLogo(_cardBrand),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Expiry Date & CVC side-by-side
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Expiry Date',
                            isDark: isDark,
                            fieldBorder: fieldBorder,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      CardExpiryInputFormatter(),
                                    ],
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'MM / YY',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF475569)
                                            : const Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            label: 'CVC',
                            isDark: isDark,
                            fieldBorder: fieldBorder,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _cvcController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '123',
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF475569)
                                            : const Color(0xFF94A3B8),
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.help_outline_rounded,
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Country dropdown
                    _buildInputField(
                      label: 'Country',
                      isDark: isDark,
                      fieldBorder: fieldBorder,
                      child: Row(
                        children: [
                          Icon(
                            Icons.public_rounded,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MyText(
                              text: 'India',
                              textStyle: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Postcode Field
                    _buildInputField(
                      label: 'Postcode',
                      isDark: isDark,
                      fieldBorder: fieldBorder,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _postcodeController,
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter postcode',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Card Button
                    InkWell(
                      onTap: () async {
                        final cardNumber =
                            _cardNumberController.text.replaceAll(' ', '');
                        final expiry = _expiryController.text;
                        final cvc = _cvcController.text.trim();
                        final postcode = _postcodeController.text.trim();

                        if (cardNumber.length < 15 || cardNumber.length > 16) {
                          showToast(
                              message: 'Please enter a valid card number');
                          return;
                        }

                        final expiryParts = expiry.split('/');
                        if (expiryParts.length != 2) {
                          showToast(
                              message: 'Please enter a valid expiry date');
                          return;
                        }

                        final monthText = expiryParts[0].trim();
                        final yearText = expiryParts[1].trim();
                        final expMonth = int.tryParse(monthText);
                        final expYear = int.tryParse(yearText);

                        if (expMonth == null || expMonth < 1 || expMonth > 12) {
                          showToast(
                              message: 'Please enter a valid expiry month');
                          return;
                        }

                        if (expYear == null ||
                            expYear < 0 ||
                            yearText.length != 2) {
                          showToast(
                              message: 'Please enter a valid expiry year');
                          return;
                        }

                        if (cvc.length < 3 || cvc.length > 4) {
                          showToast(message: 'Please enter a valid CVC');
                          return;
                        }

                        if (postcode.isEmpty) {
                          showToast(message: 'Please enter your postcode');
                          return;
                        }

                        final fullYear = expYear + 2000;

                        try {
                          final cardDetails = CardDetails(
                            number: cardNumber,
                            expirationMonth: expMonth,
                            expirationYear: fullYear,
                            cvc: cvc,
                          );
                          final accBloc = context.read<AccBloc>();
                          await Stripe.instance
                              .dangerouslyUpdateCardDetails(cardDetails);

                          if (!context.mounted) return;

                          // Satisfy AccBloc/UI checks that details are complete
                          accBloc.cardDetails =
                              const CardFieldInputDetails(complete: true);

                          // Call submit event
                          accBloc.add(AddCardDetailsEvent(context: context));
                        } catch (e) {
                          showToast(message: e.toString());
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          color: context.read<AccBloc>().isLoading
                              ? primaryBlue.withValues(alpha: 0.6)
                              : primaryBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: context.read<AccBloc>().isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : MyText(
                                text: AppLocalizations.of(context)!.saveCard,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Security footnote
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: subtitleColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        MyText(
                          text: 'Your card information is secure and encrypted',
                          textStyle: TextStyle(
                            color: subtitleColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanText = newValue.text.replaceAll(' ', '');
    if (cleanText.length > 16) {
      return oldValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != cleanText.length) {
        buffer.write(' ');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    if (newText.length > 7) {
      return oldValue;
    }
    final cleanText = newText.replaceAll('/', '').replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanText.length; i++) {
      buffer.write(cleanText[i]);
      if (i == 1 && cleanText.length > 2) {
        buffer.write(' / ');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
