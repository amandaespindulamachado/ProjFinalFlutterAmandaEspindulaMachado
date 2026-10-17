import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../widgets/chamado_card.dart';

/// Tela 03 — Home: listagem offline-first com GPS — RF06, RF07, RF08
class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;
  final AuthViewModel authViewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _verificarConectividade();
    widget.viewModel.carregarChamados();
  }

  Future<void> _verificarConectividade() async {
    final result = await Connectivity().checkConnectivity();
    final online = !result.contains(ConnectivityResult.none);
    setState(() => _isOnline = online);
    widget.viewModel.setOnline(online);

    // Ouve mudanças de conectividade
    Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;
      final isOn = !results.contains(ConnectivityResult.none);
      setState(() => _isOnline = isOn);
      widget.viewModel.setOnline(isOn);
    });
  }

  Future<void> _logout() async {
    await widget.authViewModel.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppConstants.routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ISP Conecta — Chamados'),
        actions: [
          // Indicador de status online/offline — RF08
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Icon(
                  _isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 18,
                  color: _isOnline ? Colors.greenAccent : AppTheme.offlineColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'historico') {
                Navigator.of(context)
                    .pushNamed(AppConstants.routeHistorico);
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'historico',
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 8),
                    Text('Histórico'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.state == HomeState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(widget.viewModel.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: widget.viewModel.carregarChamados,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final chamados = widget.viewModel.chamados;

          if (chamados.isEmpty) {
            return RefreshIndicator(
              onRefresh: widget.viewModel.carregarChamados,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 64, color: Colors.green),
                        SizedBox(height: 12),
                        Text(
                          'Nenhum chamado em aberto.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Puxe para atualizar.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: widget.viewModel.carregarChamados,
            child: Column(
              children: [
                // Banner offline
                if (!_isOnline)
                  Container(
                    color: AppTheme.offlineColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Modo Offline — dados do banco local',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                // Info GPS
                if (widget.viewModel.posicaoAtual != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.gps_fixed,
                            size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${chamados.length} chamado(s) — ordenados por proximidade',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                // Lista com lazy loading — RF06
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: chamados.length,
                    itemBuilder: (context, index) {
                      final item = chamados[index];
                      return ChamadoCard(
                        item: item,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppConstants.routeAtendimento,
                          arguments: item.chamado,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
