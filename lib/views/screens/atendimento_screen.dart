import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/chamado_model.dart';
import '../../viewmodels/atendimento_viewmodel.dart';

/// Tela 04 — Atendimento: formulário de conclusão de OS — RF09-RF12
class AtendimentoScreen extends StatefulWidget {
  final AtendimentoViewModel viewModel;

  const AtendimentoScreen({super.key, required this.viewModel});

  @override
  State<AtendimentoScreen> createState() => _AtendimentoScreenState();
}

class _AtendimentoScreenState extends State<AtendimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoCtrl = TextEditingController();
  String? _categoriaSelecionada;
  DateTime _dataConclusao = DateTime.now();
  ChamadoModel? _chamado;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onStateChanged);
    // Recebe chamado dos arguments ao inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ChamadoModel) {
        widget.viewModel.setChamado(args);
        setState(() => _chamado = args);
      }
    });
  }

  void _onStateChanged() {
    if (!mounted) return;
    if (widget.viewModel.state == AtendimentoState.saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atendimento registrado localmente! Pendente de sync.'),
          backgroundColor: AppTheme.successColor,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
      widget.viewModel.reset();
    } else if (widget.viewModel.state == AtendimentoState.error) {
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
    widget.viewModel.removeListener(_onStateChanged);
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataConclusao,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataConclusao = picked);
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto com câmera'),
              onTap: () {
                Navigator.pop(ctx);
                widget.viewModel.capturarFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.pop(ctx);
                widget.viewModel.capturarFoto(ImageSource.gallery);
              },
            ),
            if (widget.viewModel.fotoSelecionada != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.viewModel.removerFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrija os campos em vermelho antes de continuar.'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }
    if (_chamado == null) return;

    await widget.viewModel.concluirAtendimento(
      chamadoId: _chamado!.id,
      codigoCliente: _chamado!.codigoCliente,
      categoriaTecnica: _categoriaSelecionada!,
      descricaoProcedimento: _descricaoCtrl.text.trim(),
      dataConclusao: _dataConclusao.toIso8601String().substring(0, 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atendimento')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (_chamado == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCabecalhoOS(),
                const SizedBox(height: 20),
                _buildFormulario(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCabecalhoOS() {
    return Card(
      color: AppTheme.primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.primaryColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment,
                    color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'OS #${_chamado!.id} — ${_chamado!.codigoCliente}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _infoRow(Icons.person, _chamado!.nomeCliente),
            _infoRow(Icons.category, _chamado!.categoria),
            _infoRow(Icons.description, _chamado!.resumoProblema),
            _infoRow(Icons.location_on, _chamado!.enderecoCompleto),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parecer Técnico',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Dropdown de categoria — RF09, RF10
          DropdownButtonFormField<String>(
            value: _categoriaSelecionada,
            decoration: const InputDecoration(
              labelText: 'Categoria do Parecer *',
              prefixIcon: Icon(Icons.build_outlined),
            ),
            items: AppConstants.categoriasTecnicas
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _categoriaSelecionada = v),
            validator: (v) =>
                v == null ? 'Selecione a categoria técnica' : null,
          ),
          const SizedBox(height: 16),

          // Descrição multilinhas — RF09, RF10
          TextFormField(
            controller: _descricaoCtrl,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Descrição do procedimento realizado *',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Icon(Icons.notes),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Descreva o procedimento realizado';
              }
              // Validação: mínimo 10 caracteres — RF10
              if (v.trim().length < 10) {
                return 'Descrição deve ter no mínimo 10 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Data de conclusão — RF09
          InkWell(
            onTap: _selecionarData,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data de conclusão',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                '${_dataConclusao.day.toString().padLeft(2, '0')}/'
                '${_dataConclusao.month.toString().padLeft(2, '0')}/'
                '${_dataConclusao.year}',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Foto — RF09, RF11
          const Text(
            'Foto comprobatória',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (_, __) {
              final foto = widget.viewModel.fotoSelecionada;
              return GestureDetector(
                onTap: _mostrarOpcoesFoto,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: foto != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(foto, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: GestureDetector(
                                onTap: widget.viewModel.removerFoto,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Toque para adicionar foto',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Botão confirmar — RF12
          ListenableBuilder(
            listenable: widget.viewModel,
            builder: (_, __) => ElevatedButton.icon(
              onPressed:
                  widget.viewModel.isLoading ? null : _submit,
              icon: widget.viewModel.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: const Text('CONCLUIR ATENDIMENTO'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
