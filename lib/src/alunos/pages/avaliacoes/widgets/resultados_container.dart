import 'package:flutter/material.dart';
import '../../../../utils.dart';

class ResultadosContainer extends StatelessWidget {
  final double? imc;
  final String? classificacaoImc;
  final double? bf;
  final double? massaMagra;
  final double? massaGorda;
  final double? pesoIdeal;
  final double? rce;
  final String? classificacaoRce;
  const ResultadosContainer(
      {super.key,
      required this.imc,
      required this.classificacaoImc,
      required this.bf,
      required this.massaMagra,
      required this.massaGorda,
      required this.pesoIdeal,
      required this.rce,
      required this.classificacaoRce});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 1200;
    final theme = Theme.of(context);

    return Container(
      width: isSmallScreen ? MediaQuery.of(context).size.width * 0.39 : 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultados',
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
            _buildResultCard(
              context,
              'IMC',
              imc?.toStringAsFixed(1) ?? '0.0',
              classificacaoImc != null ? ' (${classificacaoImc!})' : ' - ',
              theme.primaryColor,
              'kg/m²',
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              'Percentual de Gordura',
              bf?.toStringAsFixed(1) ?? '0.0',
              '',
              theme.primaryColor,
              '%',
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              'Massa Magra',
              massaMagra?.toStringAsFixed(1) ?? '0.0',
              '',
              theme.colorScheme.secondary,
              'kg',
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              'Massa Gorda',
              massaGorda?.toStringAsFixed(1) ?? '0.0',
              '',
              theme.primaryColor,
              'kg',
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              'Peso Ideal',
              pesoIdeal?.toStringAsFixed(1) ?? '0.0',
              '',
              theme.colorScheme.secondary,
              'kg',
            ),
            const SizedBox(height: 16),
            _buildResultCard(
              context,
              'RCE',
              rce?.toStringAsFixed(1) ?? '0.0',
              classificacaoRce != null ? ' (${classificacaoRce!})' : ' - ',
              theme.primaryColor,
              '',
            ),
            const SizedBox(height: 24),
            // Container(
            //   padding: EdgeInsets.all(16),
            //   decoration: BoxDecoration(
            //     color: Colors.blue.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(8),
            //     border: Border.all(color: Colors.blue.withOpacity(0.3)),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         'Recomendações',
            //         style: SafeGoogleFont(
            //           'Open Sans',
            //           textStyle: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.blue,
            //           ),
            //         ),
            //       ),
            //       const SizedBox(height: 8),
            //       Text(
            //         'Seus índices estão dentro do esperado. Mantenha o foco nos treinos e na alimentação balanceada.',
            //         style: SafeGoogleFont(
            //           'Open Sans',
            //           textStyle: const TextStyle(
            //             color: Colors.white70,
            //             height: 1.5,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, String title, String value,
      String status, Color statusColor, String unit) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: SafeGoogleFont(
                  'Open Sans',
                  textStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              if (status.trim().isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: SafeGoogleFont(
                      'Open Sans',
                      textStyle: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: SafeGoogleFont(
                  'Open Sans',
                  textStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: SafeGoogleFont(
                    'Open Sans',
                    textStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
