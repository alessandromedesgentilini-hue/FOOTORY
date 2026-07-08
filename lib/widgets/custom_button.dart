// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

enum CustomButtonStyle { primary, secondary, outline, ghost, destructive }

enum CustomButtonSize { sm, md, lg }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.label,
    this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.style = CustomButtonStyle.primary,
    this.size = CustomButtonSize.md,
    this.fullWidth = false,
    this.loading = false,
    this.radius,
    this.padding,
  }) : assert(label != null || child != null,
            'Forneça `label` ou `child` para o CustomButton.');

  final String? label;
  final Widget? child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;

  final CustomButtonStyle style;
  final CustomButtonSize size;
  final bool fullWidth;
  final bool loading;

  final BorderRadius? radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final disabled = onPressed == null || loading;

    // ----- sizing -----
    final (h, padH, padV, gap, font) = switch (size) {
      CustomButtonSize.sm => (
          36.0,
          12.0,
          8.0,
          6.0,
          theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)
        ),
      CustomButtonSize.md => (
          44.0,
          16.0,
          12.0,
          8.0,
          theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)
        ),
      CustomButtonSize.lg => (
          52.0,
          20.0,
          14.0,
          10.0,
          theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
        ),
    };

    // ----- colors / borders -----
    Color bg;
    Color fg;
    Color bd;
    double elevation;

    switch (style) {
      case CustomButtonStyle.primary:
        bg = scheme.primary;
        fg = scheme.onPrimary;
        bd = Colors.transparent;
        elevation = 1.0;
        break;
      case CustomButtonStyle.secondary:
        bg = scheme.secondaryContainer;
        fg = scheme.onSecondaryContainer;
        bd = Colors.transparent;
        elevation = 0.0;
        break;
      case CustomButtonStyle.outline:
        bg = Colors.transparent;
        fg = scheme.primary;
        bd = scheme.outline;
        elevation = 0.0;
        break;
      case CustomButtonStyle.ghost:
        bg = Colors.transparent;
        fg = scheme.primary;
        bd = Colors.transparent;
        elevation = 0.0;
        break;
      case CustomButtonStyle.destructive:
        bg = scheme.error;
        fg = scheme.onError;
        bd = Colors.transparent;
        elevation = 0.0;
        break;
    }

    if (disabled) {
      final base =
          style == CustomButtonStyle.outline || style == CustomButtonStyle.ghost
              ? scheme.onSurface
              : scheme.onPrimary;
      fg = base.withOpacity(0.5);
      if (bg != Colors.transparent) {
        bg = bg.withOpacity(0.60);
      }
      if (bd != Colors.transparent) {
        bd = bd.withOpacity(0.40);
      }
      elevation = 0.0;
    }

    final content = _buildContent(
      context,
      gap: gap,
      textStyle:
          font ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      color: fg,
    );

    final r = radius ?? BorderRadius.circular(14);

    final button = Material(
      color: bg,
      elevation: elevation,
      borderRadius: r,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: r,
        splashColor: fg.withOpacity(0.08),
        highlightColor: fg.withOpacity(0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: h,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: padH, vertical: padV),
          decoration: BoxDecoration(
            borderRadius: r,
            border: bd == Colors.transparent ? null : Border.all(color: bd),
          ),
          child: Center(child: content),
        ),
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: h),
      child:
          fullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required double gap,
    required TextStyle textStyle,
    required Color color,
  }) {
    final effectiveChild = loading
        ? SizedBox(
            width: textStyle.fontSize != null ? textStyle.fontSize! * 0.9 : 14,
            height: textStyle.fontSize != null ? textStyle.fontSize! * 0.9 : 14,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color)),
          )
        : (child ?? Text(label!, style: textStyle.copyWith(color: color)));

    final parts = <Widget>[
      if (leading != null && !loading)
        IconTheme.merge(
          data:
              IconThemeData(size: (textStyle.fontSize ?? 14) + 2, color: color),
          child: leading!,
        ),
      effectiveChild,
      if (trailing != null && !loading)
        IconTheme.merge(
          data:
              IconThemeData(size: (textStyle.fontSize ?? 14) + 2, color: color),
          child: trailing!,
        ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: _intersperse(parts, SizedBox(width: gap)),
    );
  }

  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    if (items.isEmpty) return items;
    final out = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(separator);
    }
    return out;
  }
}

/* ----------------- Exemplo de uso -----------------

CustomButton(
  label: 'Salvar',
  leading: const Icon(Icons.save),
  style: CustomButtonStyle.primary,
  size: CustomButtonSize.md,
  fullWidth: true,
  onPressed: () {},
)

CustomButton(
  label: 'Excluir',
  style: CustomButtonStyle.destructive,
  loading: false,
  onPressed: () {},
)

CustomButton(
  child: Row(children:[Icon(Icons.share), const SizedBox(width:8), const Text('Share')]),
  style: CustomButtonStyle.outline,
  onPressed: () {},
)

--------------------------------------------------- */
