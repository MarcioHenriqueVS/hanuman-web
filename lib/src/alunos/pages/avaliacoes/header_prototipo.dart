import 'package:flutter/material.dart';
import '../../../flutter_flow/ff_button_options.dart';
import '../../../utils.dart';

class HeaderPrototipo extends StatelessWidget {
  final VoidCallback? onSave;
  final String title;
  final String subtitle;
  final String? button;
  final bool? icon;
  final double? maxWidth;
  final VoidCallback? onBack;
  final Icon? iconData;

  const HeaderPrototipo({
    super.key,
    this.onSave,
    required this.title,
    required this.subtitle,
    this.button,
    this.icon = true,
    this.maxWidth,
    this.onBack,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 1200),
          child: Row(
            mainAxisAlignment: button != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: onBack ?? () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SafeGoogleFont(
                          'Open Sans',
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: SafeGoogleFont(
                          'Open Sans',
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              button != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: FFButtonWidget(
                        onPressed: onSave,
                        text: button!,
                        icon: icon!
                            ? iconData != null ? Icon(
                                iconData!.icon,
                                size: 15,
                                color: Theme.of(context).colorScheme.onPrimary,
                            ) : Icon(
                                Icons.add_rounded,
                                size: 15,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )
                            : null,
                        options: FFButtonOptions(
                          height: 40,
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 0, 16, 0),
                          iconPadding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: Theme.of(context).primaryColor,
                          elevation: 3,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
