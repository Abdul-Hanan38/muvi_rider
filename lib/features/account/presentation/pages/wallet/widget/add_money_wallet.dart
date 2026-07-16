// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_tagxi/core/utils/custom_text.dart';
import 'package:restart_tagxi/l10n/app_localizations.dart';

import '../../../../../../common/app_colors.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../application/acc_bloc.dart';
import 'payment_gatewaylist_widget.dart';

class AddMoneyWalletWidget extends StatefulWidget {
  final BuildContext cont;
  final String minWalletAmount;
  const AddMoneyWalletWidget(
      {super.key, required this.cont, required this.minWalletAmount});

  @override
  State<AddMoneyWalletWidget> createState() => _AddMoneyWalletWidgetState();
}

class _AddMoneyWalletWidgetState extends State<AddMoneyWalletWidget> {
  /// Cursor position within the displayed amount string.
  int _cursorOffset = 0;

  AccBloc get _acc => widget.cont.read<AccBloc>();

  @override
  void initState() {
    super.initState();
    _acc.walletAmountController.addListener(_onControllerChange);
  }

  /// Keeps [_cursorOffset] in sync whenever the controller's selection changes
  /// (e.g. after a keypad press updates [TextEditingValue.selection]).
  void _onControllerChange() {
    if (!mounted) return;
    final ctrl = _acc.walletAmountController;
    final sel = ctrl.selection;
    final end = ctrl.text.length;
    final offset = (sel.isValid && sel.baseOffset >= 0)
        ? sel.baseOffset.clamp(0, end)
        : end;
    if (offset != _cursorOffset) setState(() => _cursorOffset = offset);
  }

  /// Called when the user taps the amount text area.
  /// Uses [TextPainter] to map the tap's x-position to a character offset,
  /// then updates both [_cursorOffset] and the controller's selection so the
  /// keypad handlers insert/delete at the correct position.
  void _handleAmountTap(TapDownDetails details, String text, TextStyle style) {
    if (text.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = tp
        .getPositionForOffset(Offset(details.localPosition.dx, 0))
        .offset
        .clamp(0, text.length);
    _acc.walletAmountController.selection =
        TextSelection.collapsed(offset: offset);
    // _onControllerChange() will call setState and update _cursorOffset.
  }

  @override
  void dispose() {
    _acc.walletAmountController.removeListener(_onControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final primaryBlue = isDark ? AppColors.secondary : AppColors.primary;

    return BlocProvider.value(
        value: widget.cont.read<AccBloc>(),
        child: BlocBuilder<AccBloc, AccState>(
          builder: (context, state) {
            final acc = context.read<AccBloc>();
            return Scaffold(
              backgroundColor: pageBg,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: SafeArea(
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PositionedDirectional(
                          start: 0,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_forward
                                  : Icons.arrow_back,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              size: 20,
                            ),
                          ),
                        ),
                        MyText(
                          text: AppLocalizations.of(context)!.addMoney,
                          textStyle: TextStyle(
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      MyText(
                        text: AppLocalizations.of(context)!.enterAmountAddText,
                        textStyle: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Amount Display Card
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: cardBorder, width: 1),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Currency symbol circular badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A8A)
                                        .withValues(alpha: 0.3)
                                    : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                userData!.currencySymbol,
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Large amount display — BlinkingCursor tracks _cursorOffset
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: acc.walletAmountController,
                              builder: (_, value, __) {
                                final rawText = value.text;
                                final text = rawText.isEmpty ? '0' : rawText;
                                final safeOffset =
                                    _cursorOffset.clamp(0, text.length);
                                final beforeCursor =
                                    text.substring(0, safeOffset);
                                final afterCursor = text.substring(safeOffset);
                                const amountStyle = TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -1,
                                );
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            acc.walletResponse
                                                    ?.currencySymbol ??
                                                '₹',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: titleColor,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Tappable area: maps tap x → cursor offset
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTapDown: (details) =>
                                                _handleAmountTap(
                                              details,
                                              text,
                                              amountStyle.copyWith(
                                                  color: titleColor),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Text before cursor
                                                Text(
                                                  beforeCursor,
                                                  style: amountStyle.copyWith(
                                                      color: titleColor),
                                                ),
                                                // Blinking cursor indicator
                                                BlinkingCursor(
                                                  color: primaryBlue,
                                                  height: 38,
                                                  width: 2.5,
                                                ),
                                                // Text after cursor
                                                Text(
                                                  afterCursor,
                                                  style: amountStyle.copyWith(
                                                      color: titleColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ], // closes card Column children
                        ), // closes card Column
                      ), // closes card Container
                      const SizedBox(height: 32),
                      // Next Button
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: acc.walletAmountController,
                        builder: (_, value, __) {
                          final bool hasAmount =
                              value.text.isNotEmpty && value.text != '0';
                          return SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: hasAmount
                                  ? () {
                                      if (acc.walletAmountController.text
                                              .isNotEmpty &&
                                          acc.addMoney != null) {
                                        final confirmPayment =
                                            widget.cont.read<AccBloc>();
                                        final list = widget.cont
                                            .read<AccBloc>()
                                            .walletPaymentGatways;
                                        final currency =
                                            acc.walletResponse!.currencySymbol;
                                        final money = acc.addMoney.toString();
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          useSafeArea: true,
                                          backgroundColor: pageBg,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(24)),
                                          ),
                                          builder: (_) {
                                            return FractionallySizedBox(
                                              heightFactor: 1.0,
                                              child: BlocProvider.value(
                                                value: confirmPayment,
                                                child: PaymentGatewaylistWidget(
                                                  cont: context,
                                                  currencySymbol: currency,
                                                  amount: money,
                                                  walletPaymentGatways: list,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: isDark
                                    ? AppColors.secondary
                                    : AppColors.primary,
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF6FF),
                                disabledForegroundColor:
                                    textSecondary.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: MyText(
                                text: AppLocalizations.of(context)!.next,
                                textStyle: TextStyle(
                                  color: hasAmount
                                      ? Colors.white
                                      : textSecondary.withValues(alpha: 0.5),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // Keypad
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final row in const [
                            ['1', '2', '3'],
                            ['4', '5', '6'],
                            ['7', '8', '9'],
                            ['.', '0']
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (final key in row)
                                    _KeyButton(
                                      label: key,
                                      onTap: () {
                                        final ctrl = acc.walletAmountController;
                                        final current = ctrl.text;
                                        final sel = ctrl.selection;
                                        // Resolve cursor position
                                        final pos = (sel.baseOffset >= 0 &&
                                                sel.baseOffset <=
                                                    current.length)
                                            ? sel.baseOffset
                                            : current.length;

                                        // Handle decimal point
                                        if (key == '.') {
                                          if (!current.contains('.')) {
                                            final insert = current.isEmpty
                                                ? '0.'
                                                : (current.substring(0, pos) +
                                                    '.' +
                                                    current.substring(pos));
                                            ctrl.value = TextEditingValue(
                                              text: insert,
                                              selection:
                                                  TextSelection.collapsed(
                                                      offset: current.isEmpty
                                                          ? 2
                                                          : pos + 1),
                                            );
                                            acc.addMoney =
                                                double.tryParse(insert);
                                          }
                                          return;
                                        }

                                        // Handle regular digits
                                        final String next;
                                        final int newPos;
                                        if (current == '0' && pos == 1) {
                                          // Replace leading zero
                                          next = key;
                                          newPos = 1;
                                        } else {
                                          next = current.substring(0, pos) +
                                              key +
                                              current.substring(pos);
                                          newPos = pos + 1;
                                        }
                                        ctrl.value = TextEditingValue(
                                          text: next,
                                          selection: TextSelection.collapsed(
                                              offset: newPos),
                                        );
                                        acc.addMoney = double.tryParse(next);
                                      },
                                    ),
                                  if (row.length == 2)
                                    _KeyButton(
                                      icon: Icons.backspace_outlined,
                                      onTap: () {
                                        final ctrl = acc.walletAmountController;
                                        final current = ctrl.text;
                                        if (current.isEmpty) return;
                                        final sel = ctrl.selection;
                                        final pos = (sel.baseOffset > 0 &&
                                                sel.baseOffset <=
                                                    current.length)
                                            ? sel.baseOffset
                                            : current.length;
                                        if (pos == 0) return;
                                        final next =
                                            current.substring(0, pos - 1) +
                                                current.substring(pos);
                                        ctrl.value = TextEditingValue(
                                          text: next,
                                          selection: TextSelection.collapsed(
                                              offset: pos - 1),
                                        );
                                        acc.addMoney = double.tryParse(
                                            next.isEmpty ? '0' : next);
                                      },
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}

// Simple keypad button used above
class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  const _KeyButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.6)
        : const Color(0xFFF8FAFC);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: size.width * 0.26,
        height: size.width * 0.16,
        decoration: BoxDecoration(
          color: btnBg,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(
                icon,
                color: isDark ? Colors.white : AppColors.primary,
                size: 20,
              )
            : Text(
                label ?? '',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ─── Blinking cursor widget ──────────────────────────────────────────────────

class BlinkingCursor extends StatefulWidget {
  final Color color;
  final double height;
  final double width;

  const BlinkingCursor({
    super.key,
    required this.color,
    this.height = 36,
    this.width = 2,
  });

  @override
  State<BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.width / 2),
        ),
      ),
    );
  }
}
