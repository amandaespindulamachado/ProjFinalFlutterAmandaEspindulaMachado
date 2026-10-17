import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/historico_viewmodel.dart';
import '../widgets/atendimento_card.dart';

/// Tela 05 — Histórico de atendimentos com filtro e sync — RF13-RF16
class HistoricoScreen extends StatefulWidget {
  final HistoricoViewModel viewModel;

  const HistoricoScreen({super.key, required this.viewModel});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.carregarHistorico();
    widget.viewModel.addListener(_onViewModelChanged);
    _searchCtrl.addListener(() {
      widget.viewModel.filtrar(_searchCtrl.text);
    });
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (widget.viewModel.mensagemSync.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.mensagemSync),
          backgroundColor: AppTheme.successColor,
        ),
      );
      widget.viewModel.clearMensagem();
    }

    if (widget.viewModel.state == HistoricoState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Atendimentos'),
        actions: [
          // Botão de sincronização — RF13
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (_, __) {
              if (widget.viewModel.state == HistoricoState.syncing) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_sync),
                    tooltip: 'Sincronizar pendentes',
                    onPressed: widget.viewModel.sincronizar,
                  ),
                  // Badge de pendentes
                  if (widget.viewModel.hasPendentes)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppTheme.warningColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.viewModel.totalPendentes}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa em tempo real — RF15
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Filtrar por ID da OS ou código do cliente...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          widget.viewModel.filtrar('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Lista — RF14, RF15
          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, _) {
                if (widget.viewModel.state == HistoricoState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lista = widget.viewModel.atendimentos;

                if (lista.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          _searchCtrl.text.isNotEmpty
                              ? 'Nenhum resultado para "${_searchCtrl.text}"'
                              : 'Nenhum atendimento registrado ainda.',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: widget.viewModel.carregarHistorico,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final atendimento = lista[index];
                      return AtendimentoCard(
                        atendimento: atendimento,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppConstants.routeDetalheAtendimento,
                          arguments: atendimento,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
