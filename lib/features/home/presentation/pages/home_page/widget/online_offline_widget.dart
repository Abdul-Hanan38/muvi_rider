import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/model/user_detail_model.dart';
import '../../../../../../core/utils/custom_dialoges.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../application/home_bloc.dart';

class OnlineOfflineWidget extends StatelessWidget {
  final BuildContext cont;
  const OnlineOfflineWidget({super.key, required this.cont});

  @override
  Widget build(BuildContext context) {
    MediaQuery.sizeOf(context);
    return BlocProvider.value(
      value: cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return PremiumOnlineOfflineSwitch(
            value: userData!.active,
            onChanged: (value) {
              if (value == false) {
                userData!.active = false;
                context.read<HomeBloc>().add(UpdateEvent());

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext ctx) {
                    return CustomDoubleButtonDialoge(
                      title: AppLocalizations.of(context)!.confirmation,
                      content:
                          AppLocalizations.of(context)!.offlineConfirmation,
                      yesBtnName: AppLocalizations.of(context)!.confirm,
                      noBtnName: AppLocalizations.of(context)!.cancel,
                      yesBtnFunc: () {
                        context
                            .read<HomeBloc>()
                            .add(ChangeOnlineOfflineEvent());
                        Navigator.pop(ctx);
                      },
                      noBtnFunc: () {
                        userData!.active = true;
                        context.read<HomeBloc>().add(UpdateEvent());
                        Navigator.pop(ctx);
                      },
                    );
                  },
                );
              } else {
                userData!.active = value;
                context.read<HomeBloc>().add(ChangeOnlineOfflineEvent());
              }
            },
          );
        },
      ),
    );
  }
}

class PremiumOnlineOfflineSwitch extends StatefulWidget {
  final bool value;
  final Function(bool) onChanged;

  const PremiumOnlineOfflineSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<PremiumOnlineOfflineSwitch> createState() =>
      _PremiumOnlineOfflineSwitchState();
}

class _PremiumOnlineOfflineSwitchState
    extends State<PremiumOnlineOfflineSwitch> {
  late bool _currentValue;
  double _dragPosition = 0;

  final double _width = 130;
  final double _height = 40;
  final double _padding = 1;

  double get _thumbSize => _height - (_padding * 2.2);
  double get _maxDrag => _width - _thumbSize - (_padding * 6);

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _dragPosition = _currentValue ? 1 : 0;
  }

  @override
  void didUpdateWidget(covariant PremiumOnlineOfflineSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _currentValue = widget.value;
    _dragPosition = _currentValue ? 1 : 0;
  }

  void _updateState(bool newValue) {
    setState(() {
      _currentValue = newValue;
      _dragPosition = newValue ? 1 : 0;
    });
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isOnline = _dragPosition > 0.5;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      /// ✅ TAP OPTION ADDED
      onTap: () {
        _updateState(!_currentValue);
      },

      /// DRAG FOLLOW
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragPosition += details.delta.dx / _maxDrag;
          _dragPosition = _dragPosition.clamp(0.0, 1.0);
        });
      },

      /// SNAP
      onHorizontalDragEnd: (_) {
        final shouldBeOnline = _dragPosition > 0.5;
        _updateState(shouldBeOnline);
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        height: _height,
        width: _width,
        padding: EdgeInsets.symmetric(horizontal: _padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_height / 2),
          gradient: isOnline
              ? LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.75),
                  ],
                )
              : LinearGradient(
                  colors: [
                    primary,
                    primary.withOpacity(0.9),
                  ],
                ),
          border: isOnline
              ? Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// 🔥 TEXT (Animation ONLY Offline → Online)
            Align(
              alignment:
                  isOnline ? Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _thumbSize * 0.4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    // Animate ONLY when going Offline -> Online
                    if (_currentValue) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    }

                    // No animation for Online -> Offline
                    return child;
                  },
                  child: Text(
                    isOnline
                        ? AppLocalizations.of(context)?.onlineCaps ?? "ONLINE"
                        : AppLocalizations.of(context)?.offlineCaps ??
                            "OFFLINE",
                    key: ValueKey(isOnline),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: isOnline ? Colors.green : Colors.white,
                        ),
                  ),
                ),
              ),
            ),

            /// 🔥 THUMB
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.elasticOut,
              left: _padding + (_maxDrag * _dragPosition),
              top: _padding,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green.shade600 : Colors.white,
                  borderRadius: BorderRadius.circular(_thumbSize / 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Icon(
                  isOnline
                      ? Icons.done_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: isOnline ? Colors.white : primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
