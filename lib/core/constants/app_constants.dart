// Constantes globais da aplicação ISP Conecta
class AppConstants {
  AppConstants._();

  // --- API ---
  static const String baseUrl = 'https://oquetemnomeucosmetico.com.br/api';
  static const String loginEndpoint = '/login';
  static const String chamadosEndpoint = '/chamados';
  static const String atendimentoEndpoint = '/atendimento';
  static const String historicoEndpoint = '/historico';

  // --- Segurança ---
  /// Chave secreta compartilhada da turma para HMAC-SHA256
  static const String hmacSecret = 'ISP_TECH_SENAI_2026_xK9#mQ2\$vL8!zP4';

  // --- Secure Storage Keys ---
  static const String tokenKey = 'bearer_token';
  static const String userEmailKey = 'user_email';

  // --- SQLite ---
  static const String dbName = 'isp_tech.db';
  static const int dbVersion = 1;
  static const String tableChamados = 'chamados';
  static const String tableAtendimentos = 'atendimentos';

  // --- Categorias Técnicas ---
  static const List<String> categoriasTecnicas = [
    'Fibra Óptica',
    'Cabo Metálico',
    'Wireless',
    'Roteador',
    'ONU/ONT',
    'Switch',
    'Configuração',
    'Outro',
  ];

  // --- Status ---
  static const String statusAberto = 'aberto';
  static const String statusAtendido = 'atendido';
  static const int sincronizadoPendente = 0;
  static const int sincronizadoOk = 1;

  // --- Rotas nomeadas ---
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeAtendimento = '/atendimento';
  static const String routeHistorico = '/historico';
  static const String routeDetalheAtendimento = '/historico/detalhe';
}
