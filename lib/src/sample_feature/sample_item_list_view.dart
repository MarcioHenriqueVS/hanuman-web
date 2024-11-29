import 'package:flutter/material.dart';
import '../settings/settings_view.dart';

class SampleItemListView extends StatelessWidget {
  const SampleItemListView({super.key});

  static const routeName = '/';

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('AI Personal Trainer',
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            child: const Text(
              'Recursos',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          ),
          TextButton(
            child: const Text(
              'Preços',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          ),
          TextButton(
            child: const Text(
              'Contato',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < mobileBreakpoint;
          final isTablet = constraints.maxWidth < tabletBreakpoint;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                Container(
                  constraints: const BoxConstraints(
                      minHeight: 400), // Reduzido de 500 para 400
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Color.lerp(Theme.of(context).primaryColor, Colors.black,
                                0.3) ??
                            Theme.of(context).primaryColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Flex(
                      direction: isMobile ? Axis.vertical : Axis.horizontal,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Revolucione seus treinos com IA',
                                  style: TextStyle(
                                    fontSize: isMobile ? 32 : 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Prescreva treinos personalizados com auxílio de inteligência artificial e gerencie seus alunos de forma eficiente.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 20,
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Começar Agora'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!isMobile)
                          Expanded(
                            flex: 1,
                            child: Image.network(
                              'https://placehold.co/600x400',
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Features Section
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 64.0),
                  child: Column(
                    children: [
                      const Text(
                        'Recursos Principais',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureCard(
                            Icons.auto_awesome,
                            'IA Avançada',
                            'Prescrição inteligente de treinos baseada em dados',
                            isMobile,
                          ),
                          _buildFeatureCard(
                            Icons.people,
                            'Gestão de Alunos',
                            'Acompanhamento completo da evolução dos seus alunos',
                            isMobile,
                          ),
                          _buildFeatureCard(
                            Icons.analytics,
                            'Análise de Dados',
                            'Relatórios detalhados e métricas de performance',
                            isMobile,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Advanced AI Features Section
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 16.0 : 64.0),
                  child: Column(
                    children: [
                      const Text(
                        'Inteligência Artificial Avançada',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 32,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildAiFeatureCard(
                              'Geração Inteligente de Treinos',
                              'Nossa IA analisa perfil completo, histórico médico, objetivos e preferências do aluno para criar treinos personalizados e eficientes.',
                              Icons.fitness_center,
                              isMobile,
                              context),
                          _buildAiFeatureCard(
                              'Assistente Virtual 24/7',
                              'Chat integrado com IA para automatizar tarefas administrativas, cadastro de alunos, agendamentos e envio de treinos, com suporte a comandos de voz.',
                              Icons.chat,
                              isMobile,
                              context),
                          _buildAiFeatureCard(
                              'Adaptação Contínua',
                              'Sistema que ajusta automaticamente os treinos com base no progresso e feedback do aluno, garantindo resultados consistentes.',
                              Icons.auto_graph,
                              isMobile,
                              context),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pricing Section
                Padding(
                  // Trocado Container por Padding
                  padding: EdgeInsets.all(isMobile ? 16.0 : 64.0),
                  child: Column(
                    children: [
                      const Text(
                        'Planos',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 32,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildPricingCard(
                              'Básico',
                              'R\$ 99/mês',
                              [
                                'Até 30 alunos',
                                'Prescrição básica de treinos',
                                'Suporte por email'
                              ],
                              isMobile),
                          _buildPricingCard(
                              'Profissional',
                              'R\$ 199/mês',
                              [
                                'Até 100 alunos',
                                'IA avançada',
                                'Suporte prioritário'
                              ],
                              isMobile),
                          _buildPricingCard(
                              'Enterprise',
                              'Sob consulta',
                              [
                                'Alunos ilimitados',
                                'Recursos customizados',
                                'Suporte 24/7'
                              ],
                              isMobile),
                        ],
                      ),
                    ],
                  ),
                ),

                // Testimonials Section
                Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 64.0),
                  child: Column(
                    children: [
                      const Text(
                        'Depoimentos',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildTestimonialCard(
                            'Maria Silva',
                            'Personal Trainer',
                            'A plataforma revolucionou minha forma de trabalhar. Consigo atender mais alunos com qualidade.',
                            isMobile,
                          ),
                          _buildTestimonialCard(
                            'João Santos',
                            'Educador Físico',
                            'A IA ajuda muito na prescrição de treinos. Economizo muito tempo no planejamento.',
                            isMobile,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // FAQ Section
                Padding(
                  // Trocado Container por Padding
                  padding: EdgeInsets.all(isMobile ? 16.0 : 64.0),
                  child: Column(
                    children: [
                      const Text(
                        'Perguntas Frequentes',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFaqItem(
                        'Como funciona a IA?',
                        'Nossa IA analisa dados do aluno e objetivos para criar treinos personalizados.',
                        isMobile,
                      ),
                      _buildFaqItem(
                        'Posso exportar os dados?',
                        'Sim, oferecemos exportação em diversos formatos.',
                        isMobile,
                      ),
                      _buildFaqItem(
                        'Qual o suporte oferecido?',
                        'Oferecemos suporte por email, chat e telefone dependendo do plano.',
                        isMobile,
                      ),
                    ],
                  ),
                ),

                // Footer
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 64,
                        runSpacing: 32,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFooterSection(
                            'Contato',
                            [
                              'Email: contato@aitrainer.com',
                              'Tel: (11) 9999-9999'
                            ],
                          ),
                          _buildFooterSection(
                            'Links Úteis',
                            [
                              'Blog',
                              'Termos de Uso',
                              'Política de Privacidade'
                            ],
                          ),
                          _buildFooterSection(
                            'Redes Sociais',
                            ['Instagram', 'LinkedIn', 'YouTube'],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        '© 2024 AI Personal Trainer. Todos os direitos reservados.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, bool isMobile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: isMobile ? double.infinity : 300,
          child: Column(
            children: [
              Icon(icon, size: isMobile ? 36 : 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard(
      String title, String price, List<String> features, bool isMobile) {
    return Card(
      elevation: 2,
      child: Padding(
        // Removido Container com cor de fundo branca
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(price,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(feature),
                )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Começar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
      String name, String role, String text, bool isMobile) {
    return Card(
      elevation: 2,
      child: Padding(
        // Removido Container com cor de fundo branca
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text,
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(role, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isMobile) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        title:
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(item, style: const TextStyle(color: Colors.white70)),
            )),
      ],
    );
  }

  Widget _buildAiFeatureCard(String title, String description, IconData icon,
      bool isMobile, BuildContext context) {
    return Card(
      elevation: 3,
      child: Container(
        width: isMobile ? double.infinity : 320,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
