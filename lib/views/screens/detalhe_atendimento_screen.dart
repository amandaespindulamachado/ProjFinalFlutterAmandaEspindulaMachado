import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/atendimento_model.dart';
import '../widgets/sync_badge.dart';

/// Tela de detalhe do atendimento com exibição de fotos — RF16
class DetalheAtendimentoScreen extends StatelessWidget {
  const DetalheAtendimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final atendimento =
        ModalRoute.of(context)!.settings.arguments as AtendimentoModel;

    return Scaffold(
      appBar: AppBar(
        title: Text('OS #${atendimento.chamadoId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SyncBadge(sincronizado: !atendimento.isPendente),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            _sectionTitle('Informações da OS'),
            _infoCard([
              _row(Icons.tag, 'ID da OS', '#${atendimento.chamadoId}'),
              _row(Icons.person_outline, 'Código do cliente',
                  atendimento.codigoCliente),
              _row(Icons.calendar_today, 'Data de conclusão',
                  atendimento.dataConclusao),
            ]),

            const SizedBox(height: 20),

            // Parecer técnico
            _sectionTitle('Parecer Técnico'),
            _infoCard([
              _row(Icons.build_outlined, 'Categoria',
                  atendimento.categoriaTecnica),
            ]),
            const SizedBox(height: 8),

            // Descrição completa do procedimento
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição do procedimento',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    atendimento.descricaoProcedimento,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Foto comprobatória — RF16
            _sectionTitle('Foto do serviço'),
            _buildFoto(context, atendimento),

            const SizedBox(height: 20),

            // Status de sincronização
            _sectionTitle('Status de envio'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: atendimento.isPendente
            ? AppTheme.warningColor.withValues(alpha: 0.08)
            : AppTheme.successColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: atendimento.isPendente
                      ? AppTheme.warningColor
                      : AppTheme.successColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    atendimento.isPendente
                        ? Icons.cloud_upload_outlined
                        : Icons.cloud_done,
                    color: atendimento.isPendente
                        ? AppTheme.warningColor
                        : AppTheme.successColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      atendimento.isPendente
                          ? 'Pendente de envio. Abra o histórico e toque em sincronizar quando tiver sinal.'
                          : 'Sincronizado com sucesso na nuvem.',
                      style: TextStyle(
                        color: atendimento.isPendente
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Renderiza foto local (Image.file) ou remota (Image.network) — RF16
  Widget _buildFoto(BuildContext context, AtendimentoModel atendimento) {
    // Foto local ainda não sincronizada
    if (atendimento.fotoCaminho != null &&
        File(atendimento.fotoCaminho!).existsSync()) {
      return _fotoContainer(
        child: Image.file(
          File(atendimento.fotoCaminho!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _semFoto(),
        ),
      );
    }

    // Foto remota já sincronizada — RF16
    if (atendimento.fotoUrl != null && atendimento.fotoUrl!.isNotEmpty) {
      return _fotoContainer(
        child: Image.network(
          atendimento.fotoUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (_, __, ___) => _semFoto(),
        ),
      );
    }

    return _fotoContainer(child: _semFoto());
  }

  Widget _fotoContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 240,
        width: double.infinity,
        color: Colors.grey[100],
        child: child,
      ),
    );
  }

  Widget _semFoto() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_not_supported_outlined,
            size: 48, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text('Sem foto registrada',
            style: TextStyle(color: Colors.grey[400])),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: rows),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
