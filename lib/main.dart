import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/atendimento_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/chamado_repository.dart';
import 'viewmodels/atendimento_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/historico_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'views/screens/atendimento_screen.dart';
import 'views/screens/detalhe_atendimento_screen.dart';
import 'views/screens/historico_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IspTechApp());
}

class IspTechApp extends StatelessWidget {
  const IspTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instâncias compartilhadas dos repositórios (injeção manual)
    final authRepo = AuthRepository();
    final chamadoRepo = ChamadoRepository();
    final atendimentoRepo = AtendimentoRepository();

    // ViewModels
    final authVM = AuthViewModel(
      authRepository: authRepo,
      chamadoRepository: chamadoRepo,
    );
    final homeVM = HomeViewModel(chamadoRepository: chamadoRepo);
    final atendimentoVM = AtendimentoViewModel(
      atendimentoRepository: atendimentoRepo,
      chamadoRepository: chamadoRepo,
    );
    final historicoVM = HistoricoViewModel(
      atendimentoRepository: atendimentoRepo,
      authRepository: authRepo,
    );

    return MaterialApp(
      title: 'ISP Conecta',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppConstants.routeSplash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppConstants.routeSplash:
            return MaterialPageRoute(
              builder: (_) => SplashScreen(viewModel: authVM),
            );

          case AppConstants.routeLogin:
            return MaterialPageRoute(
              builder: (_) => LoginScreen(viewModel: authVM),
            );

          case AppConstants.routeHome:
            // Recarrega chamados ao entrar na Home
            homeVM.carregarChamados();
            return MaterialPageRoute(
              builder: (_) => HomeScreen(
                viewModel: homeVM,
                authViewModel: authVM,
              ),
            );

          case AppConstants.routeAtendimento:
            return MaterialPageRoute(
              builder: (_) => AtendimentoScreen(viewModel: atendimentoVM),
              settings: settings,
            );

          case AppConstants.routeHistorico:
            // Recarrega histórico ao entrar na tela
            historicoVM.carregarHistorico();
            return MaterialPageRoute(
              builder: (_) => HistoricoScreen(viewModel: historicoVM),
            );

          case AppConstants.routeDetalheAtendimento:
            return MaterialPageRoute(
              builder: (_) => const DetalheAtendimentoScreen(),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => SplashScreen(viewModel: authVM),
            );
        }
      },
    );
  }
}
