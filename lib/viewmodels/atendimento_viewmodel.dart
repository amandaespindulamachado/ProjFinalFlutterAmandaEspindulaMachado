import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/models/atendimento_model.dart';
import '../data/models/chamado_model.dart';
import '../data/repositories/atendimento_repository.dart';
import '../data/repositories/chamado_repository.dart';
import '../core/constants/app_constants.dart';

enum AtendimentoState { idle, saving, saved, error }

/// ViewModel da tela de Atendimento — RF09-RF12
class AtendimentoViewModel extends ChangeNotifier {
  AtendimentoViewModel({
    AtendimentoRepository? atendimentoRepository,
    ChamadoRepository? chamadoRepository,
  })  : _atendimentos = atendimentoRepository ?? AtendimentoRepository(),
        _chamados = chamadoRepository ?? ChamadoRepository();

  final AtendimentoRepository _atendimentos;
  final ChamadoRepository _chamados;

  AtendimentoState _state = AtendimentoState.idle;
  String _errorMessage = '';
  File? _fotoSelecionada;
  ChamadoModel? _chamadoAtual;

  AtendimentoState get state => _state;
  String get errorMessage => _errorMessage;
  File? get fotoSelecionada => _fotoSelecionada;
  ChamadoModel? get chamadoAtual => _chamadoAtual;
  bool get isLoading => _state == AtendimentoState.saving;

  void setChamado(ChamadoModel chamado) {
    _chamadoAtual = chamado;
    notifyListeners();
  }

  /// Captura foto da câmera ou galeria — RF11
  Future<void> capturarFoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 75, // compressão — RF11
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;

      // Salva foto no diretório do app com nome único — RF11
      final appDir = await getApplicationDocumentsDirectory();
      final fotosDir = Directory(p.join(appDir.path, 'fotos_os'));
      if (!fotosDir.existsSync()) fotosDir.createSync(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destino = File(p.join(fotosDir.path, 'os_$timestamp.jpg'));
      await File(picked.path).copy(destino.path);

      _fotoSelecionada = destino;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erro ao capturar foto: $e';
      notifyListeners();
    }
  }

  void removerFoto() {
    _fotoSelecionada = null;
    notifyListeners();
  }

  /// Salva atendimento localmente (offline-first) — RF12
  Future<bool> concluirAtendimento({
    required int chamadoId,
    required String codigoCliente,
    required String categoriaTecnica,
    required String descricaoProcedimento,
    required String dataConclusao,
  }) async {
    _setState(AtendimentoState.saving);
    try {
      final atendimento = AtendimentoModel(
        chamadoId: chamadoId,
        codigoCliente: codigoCliente,
        categoriaTecnica: categoriaTecnica,
        descricaoProcedimento: descricaoProcedimento,
        dataConclusao: dataConclusao,
        fotoCaminho: _fotoSelecionada?.path,
        sincronizado: AppConstants.sincronizadoPendente,
      );

      await _atendimentos.salvarLocalmente(atendimento);
      // Atualiza chamado para 'atendido', removendo da lista da Home — RF12
      await _chamados.marcarComoAtendido(chamadoId);

      _fotoSelecionada = null;
      _setState(AtendimentoState.saved);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setState(AtendimentoState.error);
      return false;
    }
  }

  void reset() {
    _state = AtendimentoState.idle;
    _fotoSelecionada = null;
    _chamadoAtual = null;
    _errorMessage = '';
    notifyListeners();
  }

  void _setState(AtendimentoState s) {
    _state = s;
    notifyListeners();
  }
}
