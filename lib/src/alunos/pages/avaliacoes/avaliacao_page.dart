import 'dart:convert';

import 'package:flutter/material.dart';
import '../../antropometria/models/avaliacao_model.dart';
import '../../../utils.dart';
import '../../models/aluno_model.dart';
import 'edit_ava_page.dart';

class AvaliacaoPage extends StatefulWidget {
  final AvaliacaoModel avaliacao;
  final AlunoModel aluno;
  const AvaliacaoPage(
      {super.key, required this.avaliacao, required this.aluno});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  AvaliacaoModel? newAvaliacao;
  @override
  void initState() {
    newAvaliacao = widget.avaliacao;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildReportHeader(),
                  Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainMetrics(),
                        const Divider(height: 48),
                        _buildBodyComposition(),
                        const Divider(height: 48),
                        _buildMeasurements(),
                        const Divider(height: 48),
                        _buildSkinFolds(),
                        const Divider(height: 48),
                        _buildAdditionalMeasurements(),
                        if (newAvaliacao!.fotos?.isNotEmpty ?? false) ...[
                          const Divider(height: 48),
                          _buildPhotosSection(),
                        ],
                        if (newAvaliacao!.obs?.isNotEmpty ?? false) ...[
                          const Divider(height: 48),
                          _buildObservations(),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[800]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(newAvaliacao),
              ),
              Text(
                'RELATÓRIO DE AVALIAÇÃO FÍSICA',
                style: SafeGoogleFont(
                  'Open Sans',
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              //baixar
              IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () {
                  //TODO: Implementar download do relatório
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            newAvaliacao!.titulo,
            style: SafeGoogleFont(
              'Open Sans',
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data da avaliação: ${newAvaliacao!.timestamp}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditarAvaliacaoPage(
                        aluno: widget.aluno,
                        avaliacao: newAvaliacao!,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      newAvaliacao = result;
                    });
                  }
                },
                child: Text(
                  'Editar',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas Principais',
          style: _sectionTitleStyle(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'IMC',
                '${newAvaliacao!.imc?.toStringAsFixed(2) ?? "-"}',
                newAvaliacao!.classificacaoImc ?? 'Não classificado',
                Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMetricCard(
                'Gordura Corporal',
                '${newAvaliacao!.bf?.toStringAsFixed(2) ?? "-"}%',
                'Percentual de gordura',
                Icons.percent_outlined,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMetricCard(
                'RCE',
                '${newAvaliacao!.rce?.toStringAsFixed(2) ?? "-"}',
                newAvaliacao!.classificacaoRce ?? 'Não classificado',
                Icons.accessibility_new_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return SafeGoogleFont(
      'Open Sans',
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle()),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyComposition() {
    return _buildSection(
      'Composição Corporal',
      [
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _buildDataRow('Peso', newAvaliacao!.peso?.toStringAsFixed(2), 'kg'),
            _buildDataRow(
                'Altura', newAvaliacao!.altura?.toStringAsFixed(2), 'm'),
            _buildDataRow(
                'Massa Magra', newAvaliacao!.mm?.toStringAsFixed(2), 'kg'),
            _buildDataRow(
                'Massa Gorda', newAvaliacao!.mg?.toStringAsFixed(2), 'kg'),
            _buildDataRow('Peso Ideal',
                newAvaliacao!.pesoIdeal?.toStringAsFixed(2), 'kg'),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurements() {
    return _buildSection(
      'Medidas dos Membros',
      [
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _buildDataRow('Braço Esquerdo',
                newAvaliacao!.bracoEsq?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Braço Direito',
                newAvaliacao!.bracoDir?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Antebraço Esquerdo',
                newAvaliacao!.antebracoEsq?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Antebraço Direito',
                newAvaliacao!.antebracoDir?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Panturrilha Esquerda',
                newAvaliacao!.pantEsq?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Panturrilha Direita',
                newAvaliacao!.pantDir?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Coxa Esquerda',
                newAvaliacao!.coxaEsq?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Coxa Direita',
                newAvaliacao!.coxaDir?.toStringAsFixed(2), 'cm'),
          ],
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String? value, String unit) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value != null ? '$value $unit' : '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinFolds() {
    return _buildSection(
      'Dobras Cutâneas',
      [
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _buildDataRow(
                'Abdominal', newAvaliacao!.abdominal?.toStringAsFixed(2), 'mm'),
            _buildDataRow('Suprailíaca',
                newAvaliacao!.suprailiaca?.toStringAsFixed(2), 'mm'),
            _buildDataRow('Supraespinal',
                newAvaliacao!.supraespinal?.toStringAsFixed(2), 'mm'),
            _buildDataRow(
                'Torácica', newAvaliacao!.toracica?.toStringAsFixed(2), 'mm'),
            _buildDataRow(
                'Biciptal', newAvaliacao!.biciptal?.toStringAsFixed(2), 'mm'),
            _buildDataRow(
                'Triciptal', newAvaliacao!.triciptal?.toStringAsFixed(2), 'mm'),
            _buildDataRow('Axilar Média',
                newAvaliacao!.axilarMedia?.toStringAsFixed(2), 'mm'),
            _buildDataRow('Subescapular',
                newAvaliacao!.subescapular?.toStringAsFixed(2), 'mm'),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalMeasurements() {
    return _buildSection(
      'Medidas Corporais Adicionais',
      [
        Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            _buildDataRow(
                'Cintura', newAvaliacao!.cintura?.toStringAsFixed(2), 'cm'),
            _buildDataRow(
                'Abdome', newAvaliacao!.abdome?.toStringAsFixed(2), 'cm'),
            _buildDataRow(
                'Quadril', newAvaliacao!.quadril?.toStringAsFixed(2), 'cm'),
            _buildDataRow(
                'Tórax', newAvaliacao!.torax?.toStringAsFixed(2), 'cm'),
            _buildDataRow('Cintura Escapular',
                newAvaliacao!.cintEscapular?.toStringAsFixed(2), 'cm'),
            if (newAvaliacao!.formula != null)
              _buildDataRow('Fórmula Utilizada', newAvaliacao!.formula, ''),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return _buildSection(
      'Registros Fotográficos',
      [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: newAvaliacao!.fotos?.map((imageData) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                      image: DecorationImage(
                        image: _getImageProvider(imageData),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList() ??
              [],
        ),
      ],
    );
  }

  ImageProvider _getImageProvider(String imageData) {
    // Verifica se a string começa com 'data:image' ou 'http'/'https'
    if (imageData.startsWith('data:image') ||
        imageData.startsWith('data:application')) {
      return MemoryImage(Uri.parse(imageData).data!.contentAsBytes());
    } else if (imageData.startsWith('http')) {
      return NetworkImage(imageData);
    } else {
      // Caso a string seja apenas base64 sem o prefixo data:image
      try {
        return MemoryImage(base64Decode(imageData));
      } catch (e) {
        // Em caso de erro, retorna uma imagem de placeholder
        return const AssetImage('assets/images/placeholder.png');
      }
    }
  }

  Widget _buildObservations() {
    return _buildSection(
      'Observações',
      [
        Text(
          newAvaliacao!.obs ?? '',
          style: SafeGoogleFont(
            'Open Sans',
            textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
