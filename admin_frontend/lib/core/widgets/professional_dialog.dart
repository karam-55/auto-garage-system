import 'package:flutter/material.dart';

class ProfessionalDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;
  final bool isLoading;
  final double? width;
  final double? maxHeight;

  const ProfessionalDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
    this.isLoading = false,
    this.width,
    this.maxHeight,
  });

  @override
  State<ProfessionalDialog> createState() => _ProfessionalDialogState();
}

class _ProfessionalDialogState extends State<ProfessionalDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialogWidth = widget.width ?? (MediaQuery.of(context).size.width * 0.5);
    final maxWidth = dialogWidth > 800 ? 800.0 : dialogWidth;
    final minWidth = dialogWidth < 400 ? 400.0 : dialogWidth;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: minWidth,
                  maxWidth: maxWidth,
                  maxHeight: widget.maxHeight ?? MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: widget.content,
                      ),
                    ),
                    if (widget.actions != null || widget.onConfirm != null || widget.onCancel != null)
                      _buildFooter(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: widget.onCancel ?? () => Navigator.pop(context),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.actions != null) ...widget.actions!,
          if (widget.actions == null) ...[
            if (widget.onCancel != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onCancel,
                  child: Text(widget.cancelText ?? 'إلغاء'),
                ),
              ),
            if (widget.onConfirm != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(widget.confirmText ?? 'تأكيد'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// Helper function to show professional dialog
Future<T?> showProfessionalDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  List<Widget>? actions,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  String? confirmText,
  String? cancelText,
  bool isLoading = false,
  double? width,
  double? maxHeight,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (context) => ProfessionalDialog(
      title: title,
      content: content,
      actions: actions,
      onConfirm: onConfirm,
      onCancel: onCancel ?? () => Navigator.pop(context),
      confirmText: confirmText,
      cancelText: cancelText,
      isLoading: isLoading,
      width: width,
      maxHeight: maxHeight,
    ),
  );
}
