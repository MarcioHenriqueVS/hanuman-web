import 'package:flutter/material.dart';
import '../../../flutter_flow/ff_button_options.dart';
import '../../../utils.dart';

class HeaderPrototipo extends StatelessWidget {
  final VoidCallback? onSave;
  final String title;
  final String subtitle;
  final String? button;
  const HeaderPrototipo({
    super.key,
    this.onSave,
    required this.title,
    required this.subtitle,
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            mainAxisAlignment: button != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SafeGoogleFont(
                          'Outfit',
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: SafeGoogleFont(
                          'Readex Pro',
                          textStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              button != null ? FFButtonWidget(
                onPressed: onSave,
                text: button!,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 15,
                ),
                options: FFButtonOptions(
                  height: 40,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  color: Colors.green,
                  textStyle: SafeGoogleFont(
                    'Readex Pro',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  elevation: 3,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ) : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
