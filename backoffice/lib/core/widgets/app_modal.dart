import 'package:flutter/material.dart';

class AppModalConfig {
  final String title;
  final String? subtitle;
  final List<Widget> fields;
  final String submitLabel;
  final bool destructive;
  final ValueNotifier<bool> loading;
  final VoidCallback onSubmit;
  final Widget? extra;

  const AppModalConfig({
    required this.title,
    this.subtitle,
    required this.fields,
    required this.submitLabel,
    this.destructive = false,
    required this.loading,
    required this.onSubmit,
    this.extra,
  });
}

class AppModal extends StatefulWidget {
  final AppModalConfig config;

  const AppModal({super.key, required this.config});

  static Future<T?> show<T>(BuildContext context, AppModalConfig config) {
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0x40A8A8AE),
      builder: (_) => AppModal(config: config),
    );
  }

  @override
  State<AppModal> createState() => _AppModalState();
}

class _AppModalState extends State<AppModal> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Cubic(0.16, 1.0, 0.3, 1.0)),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: LayoutBuilder(
          builder: (_, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Center(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  width: isMobile ? constraints.maxWidth - 32 : 560,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.03,
                                  height: 1.2,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              if (c.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  c.subtitle!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF787774),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          child: Divider(height: 1, color: Color(0xFFEAEAEA)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: c.fields,
                          ),
                        ),
                        if (c.extra != null) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: c.extra!,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          child: Divider(height: 1, color: Color(0xFFEAEAEA)),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF787774),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                ),
                                child: const Text('Cancel', style: TextStyle(fontSize: 14)),
                              ),
                              const SizedBox(width: 8),
                              _SubmitBtn(
                                label: c.submitLabel,
                                destructive: c.destructive,
                                loading: c.loading,
                                onPressed: c.onSubmit,
                              ),
                            ],
                          ),
                        ),
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
}

class _SubmitBtn extends StatelessWidget {
  final String label;
  final bool destructive;
  final ValueNotifier<bool> loading;
  final VoidCallback onPressed;

  const _SubmitBtn({
    required this.label,
    required this.destructive,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loading,
      builder: (_, isLoading, __) => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: destructive ? const Color(0xFF9F2F2D) : const Color(0xFF111111),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEAEAEA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: isLoading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class ModalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final bool autofocus;

  const ModalField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.06,
            color: Color(0xFF787774),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEAEAEA)),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            autofocus: autofocus,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA8A8AE),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Color(0xFF111111)),
          ),
        ),
      ],
    );
  }
}

class ConfirmContent extends StatelessWidget {
  final String message;

  const ConfirmContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF5C5C63),
        height: 1.6,
      ),
    );
  }
}
