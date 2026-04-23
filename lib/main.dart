import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const TMBApp());

class TMBApp extends StatelessWidget {
  const TMBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE040FB),
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF1A1A24),
        ),
      ),
      home: const TMBPage(),
    );
  }
}

class TMBPage extends StatefulWidget {
  const TMBPage({super.key});
  @override
  State<TMBPage> createState() => _TMBPageState();
}

class _TMBPageState extends State<TMBPage> with TickerProviderStateMixin {
  final idadeCtrl = TextEditingController();
  final pesoCtrl = TextEditingController();
  final alturaCtrl = TextEditingController();
  String genero = 'masculino';
  double fta = 1.2;
  double? resultado;
  bool hasError = false;

  late AnimationController _resultController;
  late Animation<double> _resultAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final niveis = const [
    {'label': 'Sedentário', 'sub': 'Sem exercícios', 'fta': 1.2},
    {'label': 'Levemente ativo', 'sub': '1–3x por semana', 'fta': 1.375},
    {'label': 'Moderadamente ativo', 'sub': '3–5x por semana', 'fta': 1.55},
    {'label': 'Altamente ativo', 'sub': '6–7x por semana', 'fta': 1.725},
    {'label': 'Extremamente ativo', 'sub': 'Atleta ou trabalho físico', 'fta': 1.9},
  ];

  @override
  void initState() {
    super.initState();
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _resultController.dispose();
    _pulseController.dispose();
    idadeCtrl.dispose();
    pesoCtrl.dispose();
    alturaCtrl.dispose();
    super.dispose();
  }

  void calcular() {
    final idade = double.tryParse(idadeCtrl.text);
    final peso = double.tryParse(pesoCtrl.text);
    final altura = double.tryParse(alturaCtrl.text);
    if (idade == null || peso == null || altura == null) {
      setState(() {
        hasError = true;
        resultado = null;
      });
      return;
    }
    final tmb = genero == 'masculino'
        ? fta * (66 + (13.7 * peso) + (5 * altura) - (6.8 * idade))
        : fta * (655 + (9.6 * peso) + (1.8 * altura) - (4.7 * idade));

    setState(() {
      hasError = false;
      resultado = tmb;
    });
    _resultController.forward(from: 0);
  }

  String get _activityLabel =>
      niveis.firstWhere((n) => n['fta'] == fta)['label'] as String;

  String get _activitySub =>
      niveis.firstWhere((n) => n['fta'] == fta)['sub'] as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CALCULADORA',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 4,
                      color: Color(0xFFE040FB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'de TMB',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Inputs
                _sectionLabel('DADOS FÍSICOS'),
                const SizedBox(height: 10),
                _glassCard(
                  child: Column(children: [
                    _darkField(idadeCtrl, 'Idade', 'anos', Icons.cake_outlined),
                    _divider(),
                    _darkField(pesoCtrl, 'Peso', 'kg', Icons.monitor_weight_outlined),
                    _divider(),
                    _darkField(alturaCtrl, 'Altura', 'cm', Icons.height),
                  ]),
                ),

                const SizedBox(height: 24),

                // Gênero
                _sectionLabel('GÊNERO'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _genderButton('masculino', 'Masculino', '♂')),
                  const SizedBox(width: 12),
                  Expanded(child: _genderButton('feminino', 'Feminino', '♀')),
                ]),

                const SizedBox(height: 24),

                // Atividade
                _sectionLabel('NÍVEL DE ATIVIDADE'),
                const SizedBox(height: 10),
                _glassCard(
                  child: Column(
                    children: niveis.map((n) {
                      final isSelected = fta == n['fta'];
                      return InkWell(
                        onTap: () => setState(() => fta = n['fta'] as double),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? const Color(0xFFE040FB).withOpacity(0.12)
                                : Colors.transparent,
                          ),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? const Color(0xFFE040FB)
                                    : Colors.white12,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFE040FB)
                                              .withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n['label'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white60,
                                    ),
                                  ),
                                  Text(
                                    n['sub'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? const Color(0xFFE040FB)
                                              .withOpacity(0.8)
                                          : Colors.white30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '×${n['fta']}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFFE040FB)
                                    : Colors.white20,
                              ),
                            ),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 32),

                // Botão calcular
                GestureDetector(
                  onTap: calcular,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    ),
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE040FB).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'CALCULAR AGORA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Erro
                if (hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.redAccent, size: 18),
                      SizedBox(width: 10),
                      Text(
                        'Preencha todos os campos corretamente.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ]),
                  ),
                ],

                // Resultado
                if (resultado != null) ...[
                  const SizedBox(height: 28),
                  ScaleTransition(
                    scale: _resultAnimation,
                    child: _resultCard(),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard() {
    final kcal = resultado!.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1030), Color(0xFF12101E)],
        ),
        border: Border.all(
          color: const Color(0xFFE040FB).withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: [
        const Text(
          'SUA TAXA METABÓLICA',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 3,
            color: Color(0xFFE040FB),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
          ).createShader(bounds),
          child: Text(
            kcal,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        const Text(
          'kcal / dia',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        _macroRow('Déficit (−20%)',
            '${(resultado! * 0.8).toStringAsFixed(0)} kcal'),
        const SizedBox(height: 8),
        _macroRow('Manutenção',
            '${resultado!.toStringAsFixed(0)} kcal'),
        const SizedBox(height: 8),
        _macroRow('Superávit (+20%)',
            '${(resultado! * 1.2).toStringAsFixed(0)} kcal'),
      ]),
    );
  }

  Widget _macroRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      );

  Widget _genderButton(String value, String label, String icon) {
    final isSelected = genero == value;
    return GestureDetector(
      onTap: () => setState(() => genero = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)])
              : null,
          color: isSelected ? null : const Color(0xFF1A1A24),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white12,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFE040FB).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon,
                style: TextStyle(
                  fontSize: 22,
                  color: isSelected ? Colors.white : Colors.white38,
                )),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isSelected ? Colors.white : Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 3,
          fontWeight: FontWeight.w600,
          color: Colors.white30,
        ),
      );

  Widget _glassCard({required Widget child}) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      );

  Widget _divider() =>
      const Divider(height: 1, color: Colors.white10, indent: 16, endIndent: 16);

  Widget _darkField(
    TextEditingController ctrl,
    String label,
    String unit,
    IconData icon,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Icon(icon, size: 18, color: const Color(0xFFE040FB)),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: const TextStyle(color: Colors.white12),
                suffixText: unit,
                suffixStyle: const TextStyle(
                    color: Colors.white30, fontSize: 13),
              ),
            ),
          ),
        ]),
      );
}