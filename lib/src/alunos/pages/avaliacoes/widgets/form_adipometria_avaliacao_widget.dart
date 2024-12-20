import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils.dart';
import 'measurement_text_field.dart';

class FormAdipometriaAvaliacaoWidget extends StatelessWidget {
  final TextEditingController pantu;
  final TextEditingController coxa;
  final TextEditingController abdominal;
  final TextEditingController supraEspinal;
  final TextEditingController supraIliaca;
  final TextEditingController axilarMedia;
  final TextEditingController toracica;
  final TextEditingController subescapular;
  final TextEditingController tricipital;
  final TextEditingController bicipital;
  final GlobalKey<FormState> formAvaliacaoKey;
  const FormAdipometriaAvaliacaoWidget(
      {super.key,
      required this.pantu,
      required this.coxa,
      required this.abdominal,
      required this.supraEspinal,
      required this.supraIliaca,
      required this.axilarMedia,
      required this.toracica,
      required this.subescapular,
      required this.tricipital,
      required this.bicipital,
      required this.formAvaliacaoKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formAvaliacaoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dobras Cutâneas (mm)',
            style: SafeGoogleFont(
              'Open Sans',
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: pantu,
                  label: 'Panturrilha (mm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: coxa,
                  label: 'Coxa (mm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: abdominal,
                  label: 'Abdominal (mm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: supraEspinal,
                  label: 'Supraespinal (mm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: supraIliaca,
                  label: 'Suprailíaca (mm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: axilarMedia,
                  label: 'Axilar Média (mm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: toracica,
                  label: 'Torácica (mm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: subescapular,
                  label: 'Subescapular (mm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: tricipital,
                  label: 'Tricipital (mm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: bicipital,
                  label: 'Bicipital (mm)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController? controller,
    required String label,
  }) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);

      return TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
          CommaToPointInputFormatter(),
        ],
        style: SafeGoogleFont(
          'Open Sans',
          textStyle:
              TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: SafeGoogleFont(
            'Open Sans',
            textStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.primaryColor),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }
}
