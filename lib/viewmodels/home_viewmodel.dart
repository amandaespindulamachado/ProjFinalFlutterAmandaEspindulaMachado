import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/chamado_model.dart';
import '../data/repositories/chamado_repository.dart';
import '../core/utils/distance_util.dart';

/// Item de chamado com distância calculada — RF07
class ChamadoComDistancia {
  final ChamadoModel chamado;
  final double distanciaKm;

  const ChamadoComDistancia({
    required this.chamado,
    required this.distanciaKm,
  });
}

enum HomeState { idle, loading, loaded, error }

/// ViewModel da tela Home — RF06, RF07, RF08
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({ChamadoRepository? chamadoRepository})
      : _repository = chamadoRepository ?? ChamadoRepository();

  final ChamadoRepository _repository;

  HomeState _state = HomeState.idle;
  String _errorMessage = '';
  List<ChamadoComDistancia> _chamados = [];
  Position? _posicaoAtual;
  bool _isOnline = false;

  HomeState get state => _state;
  String get errorMessage => _errorMessage;
  List<ChamadoComDistancia> get chamados => _chamados;
  bool get isOnline => _isOnline;
  bool get isLoading => _state == HomeState.loading;
  Position? get posicaoAtual => _posicaoAtual;

  /// Carrega chamados do SQLite e ordena por proximidade — RF06, RF07
  Future<void> carregarChamados() async {
    _setState(HomeState.loading);
    try {
      // Captura GPS — RF07
      _posicaoAtual = await _obterLocalizacao();

      final lista = await _repository.getChamadosAbertosLocais();

      // Calcula distância e ordena usando operadores matemáticos (Haversine)
      _chamados = lista.map((c) {
        final dist = _posicaoAtual != null
            ? DistanceUtil.calculateKm(
                lat1: _posicaoAtual!.latitude,
                lon1: _posicaoAtual!.longitude,
                lat2: c.latitude,
                lon2: c.longitude,
              )
            : double.maxFinite;
        return ChamadoComDistancia(chamado: c, distanciaKm: dist);
      }).toList();

      // Ordena do mais próximo ao mais distante (RF07)
      _chamados.sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));

      _setState(HomeState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(HomeState.error);
    }
  }

  /// Atualiza status de conectividade
  void setOnline(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  Future<Position?> _obterLocalizacao() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  void _setState(HomeState s) {
    _state = s;
    notifyListeners();
  }
}
