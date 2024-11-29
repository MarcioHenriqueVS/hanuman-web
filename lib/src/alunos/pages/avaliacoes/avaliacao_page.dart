import 'package:flutter/material.dart';
import '../../antropometria/models/avaliacao_model.dart';
import '../../../utils.dart';

class AvaliacaoPage extends StatefulWidget {
  final AvaliacaoModel avaliacao;

  const AvaliacaoPage({super.key, required this.avaliacao});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
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
                        if (widget.avaliacao.fotos?.isNotEmpty ?? false) ...[
                          const Divider(height: 48),
                          _buildPhotosSection(),
                        ],
                        if (widget.avaliacao.obs?.isNotEmpty ?? false) ...[
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              Text(
                'RELATÓRIO DE AVALIAÇÃO FÍSICA',
                style: SafeGoogleFont(
                  'Outfit',
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.avaliacao.titulo,
            style: SafeGoogleFont(
              'Outfit',
              textStyle: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data da avaliação: ${widget.avaliacao.timestamp}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
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
                '${widget.avaliacao.imc?.toStringAsFixed(2) ?? "-"}',
                widget.avaliacao.classificacaoImc ?? 'Não classificado',
                Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMetricCard(
                'Gordura Corporal',
                '${widget.avaliacao.bf?.toStringAsFixed(2) ?? "-"}%',
                'Percentual de gordura',
                Icons.percent_outlined,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildMetricCard(
                'RCE',
                '${widget.avaliacao.rce?.toStringAsFixed(2) ?? "-"}',
                widget.avaliacao.classificacaoRce ?? 'Não classificado',
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
      'Outfit',
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
        _buildDataRow('Peso', widget.avaliacao.peso?.toStringAsFixed(2), 'kg'),
        _buildDataRow(
            'Altura', widget.avaliacao.altura?.toStringAsFixed(2), 'm'),
        _buildDataRow(
            'Massa Magra', widget.avaliacao.mm?.toStringAsFixed(2), 'kg'),
        _buildDataRow(
            'Massa Gorda', widget.avaliacao.mg?.toStringAsFixed(2), 'kg'),
      ],
    );
  }

  Widget _buildMeasurements() {
    return _buildSection(
      'Medidas Corporais',
      [
        _buildDataRow('Braço Esquerdo',
            widget.avaliacao.bracoEsq?.toStringAsFixed(2), 'cm'),
        _buildDataRow('Braço Direito',
            widget.avaliacao.bracoDir?.toStringAsFixed(2), 'cm'),
        _buildDataRow(
            'Cintura', widget.avaliacao.cintura?.toStringAsFixed(2), 'cm'),
        _buildDataRow(
            'Quadril', widget.avaliacao.quadril?.toStringAsFixed(2), 'cm'),
        _buildDataRow('Coxa Esquerda',
            widget.avaliacao.coxaEsq?.toStringAsFixed(2), 'cm'),
        _buildDataRow(
            'Coxa Direita', widget.avaliacao.coxaDir?.toStringAsFixed(2), 'cm'),
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
          children: widget.avaliacao.fotos?.map((url) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                      image: DecorationImage(
                        image: NetworkImage(url),
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

  Widget _buildObservations() {
    return _buildSection(
      'Observações',
      [
        Text(
          widget.avaliacao.obs ?? '',
          style: SafeGoogleFont(
            'Readex Pro',
            textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
