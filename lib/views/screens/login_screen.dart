import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Tela 02 — Login com HMAC-SHA256 — RF03, RF04
class LoginScreen extends StatefulWidget {
  final AuthViewModel viewModel;

  const LoginScreen({super.key, required this.viewModel});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _senhaOculta = true;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (!mounted) return;

    if (widget.viewModel.state == AuthState.success) {
      Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
    } else if (widget.viewModel.state == AuthState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.viewModel.errorMessage),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      widget.viewModel.clearError();
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.viewModel.login(_emailCtrl.text.trim(), _senhaCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Logo
                const Icon(
                  Icons.wifi_tethering,
                  color: AppTheme.primaryColor,
                  size: 64,
                ),
                const SizedBox(height: 12),
                const Text(
                  'ISP Conecta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Área do Técnico',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Formulário
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Acesse sua conta',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Campo E-mail
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'E-mail institucional',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o e-mail';
                              }
                              if (!v.contains('@')) {
                                return 'E-mail inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Campo Senha
                          TextFormField(
                            controller: _senhaCtrl,
                            obscureText: _senhaOculta,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon:
                                  const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _senhaOculta
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                    () => _senhaOculta = !_senhaOculta),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Informe a senha';
                              }
                              if (v.length < 4) {
                                return 'Senha muito curta';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botão de login
                          ListenableBuilder(
                            listenable: widget.viewModel,
                            builder: (_, __) {
                              return ElevatedButton(
                                onPressed: widget.viewModel.isLoading
                                    ? null
                                    : _submit,
                                child: widget.viewModel.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('ENTRAR'),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'Senha protegida com HMAC-SHA256',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
