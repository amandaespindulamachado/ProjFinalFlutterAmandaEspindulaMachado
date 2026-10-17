import 'package:flutter/material.dart';
import '../../data/models/atendimento_model.dart';
import 'sync_badge.dart';

/// Card de atendimento exibido no histórico — RF14
class AtendimentoCard extends StatelessWidget {
  final AtendimentoModel atendimento;
  final VoidCallback onTap;

  const AtendimentoCard({
    super.key,
    required this.atendimento,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: ID + Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'OS #${atendimento.chamadoId} — Cód. ${atendimento.codigoCliente}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SyncBadge(sincronizado: !atendimento.isPendente),
                ],
              ),
              const SizedBox(height: 8),

              // Categoria técnica
              Row(
                children: [
                  const Icon(Icons.build, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    atendimento.categoriaTecnica,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Descrição resumida
              Text(
                atendimento.descricaoProcedimento,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              // Data + seta
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    atendimento.dataConclusao,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
