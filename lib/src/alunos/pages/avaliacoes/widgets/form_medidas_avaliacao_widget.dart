import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../utils.dart';
import '../../../antropometria/widgets/measurement_text_field.dart';

class FormMedidasAvaliacaoWidget extends StatelessWidget {
  final TextEditingController pantDir;
  final TextEditingController pantEsq;
  final TextEditingController coxaDir;
  final TextEditingController coxaEsq;
  final TextEditingController bracoDir;
  final TextEditingController bracoEsq;
  final TextEditingController antebracoDir;
  final TextEditingController antebracoEsq;
  final TextEditingController cintura;
  final TextEditingController quadril;
  final TextEditingController torax;
  final TextEditingController cinturaEscapular;
  final TextEditingController abdome;
  final GlobalKey<FormState> formMedidasAvaliacaoKey; // Renomeado aqui

  const FormMedidasAvaliacaoWidget(
      {super.key,
      required this.pantDir,
      required this.pantEsq,
      required this.coxaDir,
      required this.coxaEsq,
      required this.bracoDir,
      required this.bracoEsq,
      required this.antebracoDir,
      required this.antebracoEsq,
      required this.cintura,
      required this.quadril,
      required this.torax,
      required this.cinturaEscapular,
      required this.abdome,
      required this.formMedidasAvaliacaoKey}); // Renomeado aqui

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formMedidasAvaliacaoKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Circunferências (cm)',
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
                  controller: pantDir,
                  label: 'Panturrilha Direita (cm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: pantEsq,
                  label: 'Panturrilha Esquerda (cm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: coxaDir,
                  label: 'Coxa Direita (cm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: coxaEsq,
                  label: 'Coxa Esquerda (cm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: bracoDir,
                  label: 'Braço Direito (cm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: bracoEsq,
                  label: 'Braço Esquerdo (cm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: antebracoDir,
                  label: 'Antebraço Direito (cm)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: antebracoEsq,
                  label: 'Antebraço Esquerdo (cm)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: cintura,
                  label: 'Cintura',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: quadril,
                  label: 'Quadril',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  controller: torax,
                  label: 'Tórax',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  controller: cinturaEscapular,
                  label: 'Cintura Escapular',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField(
            controller: abdome,
            label: 'Abdome',
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
