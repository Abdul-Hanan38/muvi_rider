import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../../../../../../common/app_colors.dart';
import '../../../../../../../core/model/user_detail_model.dart';
import '../../../../../../../core/utils/custom_button.dart';
import '../../../../../../../core/utils/custom_text.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../application/home_bloc.dart';

class SignatureGetWidget extends StatefulWidget {
  final BuildContext cont;

  const SignatureGetWidget({
    super.key,
    required this.cont,
  });

  @override
  State<SignatureGetWidget> createState() => _SignatureGetWidgetState();
}

class _SignatureGetWidgetState extends State<SignatureGetWidget> {
  SignatureController? _controller;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      _controller = SignatureController(
        penStrokeWidth: 3,
        penColor: isDark ? Colors.white : Colors.black87,
        exportBackgroundColor: Colors.transparent,
        onDrawStart: () => debugPrint('onDrawStart called!'),
        onDrawEnd: () => debugPrint('onDrawEnd called!'),
      );
      _controller!.addListener(_onSignatureChange);
      _isInitialized = true;
    }
  }

  void _onSignatureChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onSignatureChange);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBgColor =
        isDark ? const Color(0xFF0F1322) : const Color(0xFFF8F9FC);
    final cardBgColor = isDark ? const Color(0xFF161B2E) : Colors.white;
    final cardBorderColor =
        isDark ? const Color(0xFF232A45) : const Color(0xFFF1F5F9);

    if (_controller == null) {
      return const SizedBox();
    }
    final controller = _controller!;

    return BlocProvider.value(
      value: widget.cont.read<HomeBloc>(),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return SizedBox(
            width: size.width,
            height: size.height,
            child: Scaffold(
              backgroundColor: scaffoldBgColor,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: scaffoldBgColor,
                elevation: 0,
                centerTitle: true,
                title: MyText(
                  text: AppLocalizations.of(context)!.getUserSignature,
                  textStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    context.read<HomeBloc>().add(ShowSignatureEvent());
                  },
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Header row with Icon and instruction
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEFF6FF),
                              ),
                              child: const Icon(
                                Icons.draw_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .drawSignature,
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  MyText(
                                    text: AppLocalizations.of(context)!
                                        .onrideSignatureSubText,
                                    textStyle: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Dotted Draw Signature Card Container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cardBorderColor,
                              width: 1.0,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: DottedBorder(
                            color: const Color(0xFF6366F1).withOpacity(0.5),
                            strokeWidth: 1.5,
                            dashPattern: const [6, 4],
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(16),
                            child: Container(
                              width: double.infinity,
                              height: 260,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  Signature(
                                    key: const Key('signature'),
                                    controller: controller,
                                    height: 260,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  if (controller.isEmpty)
                                    IgnorePointer(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.gesture,
                                              size: 48,
                                              color: isDark
                                                  ? Colors.white24
                                                  : Colors.black12,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: 32,
                                                  height: 1,
                                                  color: isDark
                                                      ? Colors.white12
                                                      : Colors.black12,
                                                ),
                                                const SizedBox(width: 8),
                                                MyText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .signHereText,
                                                  textStyle: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Colors.white30
                                                        : Colors.black26,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  width: 32,
                                                  height: 1,
                                                  color: isDark
                                                      ? Colors.white12
                                                      : Colors.black12,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Your Signature is Secure Badge Box
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A2238)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF232A45)
                                  : const Color(0xFFDBEAFE),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                height: 32,
                                width: 32,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                                child: const Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .signatureSecureText,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    MyText(
                                      text: AppLocalizations.of(context)!
                                          .signatireConfirmText,
                                      textStyle: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? Colors.white60
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bottom action buttons: Confirm & Clear
                        CustomButton(
                          width: size.width,
                          height: 52,
                          borderRadius: 30,
                          buttonColor: const Color(0xFF0038FF),
                          buttonName:
                              AppLocalizations.of(context)!.confirmSignature,
                          textSize: 18,
                          onTap: () async =>
                              _exportSignatureAndUpdateProof(context),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            controller.clear();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: size.width,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF0038FF),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF0038FF),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.clear,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0038FF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _exportSignatureAndUpdateProof(
    BuildContext context,
  ) async {
    if (_controller == null || _controller!.isEmpty) {
      return;
    }

    final Uint8List? data =
        await _controller!.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    }

    Directory tempDirectory = await getTemporaryDirectory();
    var directoryPath = tempDirectory.path;
    var temporarySignImgName = DateTime.now();
    var signatureImage = File('$directoryPath/$temporarySignImgName.png');

    signatureImage.writeAsBytesSync(data);
    if (context.mounted) {
      context.read<HomeBloc>().signatureImage = signatureImage.path;
      context.read<HomeBloc>().add(UploadProofEvent(
          image: context.read<HomeBloc>().signatureImage!,
          isBefore: false,
          id: userData!.onTripRequest!.id));
    }
  }
}
