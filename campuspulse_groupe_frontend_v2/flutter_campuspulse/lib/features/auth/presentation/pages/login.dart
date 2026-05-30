import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_services.dart';
import '../../../schedule/presentation/page/home_page.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool _isLoading     = false;
  bool _obscure       = true;
  final _dio          = Dio();

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Obtenir le token JWT
      final loginRes = await _dio.post(
        'http://127.0.0.1:8000/api/auth/login/',
        data: {
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text,
        },
      );
      final accessToken = loginRes.data['access'] as String;
      await AuthService.saveToken(accessToken);

      // 2. Récupérer le profil étudiant
      final profileRes = await _dio.get(
        'http://127.0.0.1:8000/api/auth/me/',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final student = profileRes.data as Map<String, dynamic>;
      await AuthService.saveUserInfo(
        username:   student['username']   as String? ?? '',
        firstName:  student['first_name'] as String? ?? '',
        lastName:   student['last_name']  as String? ?? '',
        level:      student['level']      as String? ?? '',
        department: student['department'] as String? ?? '',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );

    } on DioException catch (e) {
      final msg = e.response?.data?['detail']?.toString() ?? 'Identifiants incorrects';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text(msg),
          backgroundColor: const Color(0xFFE05252),
          behavior:        SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A6B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header UADB ──────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/uadb_logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.school, color: Color(0xFF1A3A6B), size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('CampusPulse',
                        style: TextStyle(color: Colors.white, fontSize: 28,
                            fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('Université Alioune DIOP de Bambey',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                      child: const Text('Masters SI / SR — 2026',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
              ),

              // ── Formulaire ───────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                    ),
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.55),
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Connexion',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3A6B))),
                          const SizedBox(height: 6),
                          Text('Entrez vos identifiants universitaires',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          const SizedBox(height: 28),

                          // Username
                          _label('Nom d\'utilisateur (matricule)'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _usernameCtrl,
                            decoration: _inputDeco(
                                hint: 'mamadou.diallo', icon: Icons.person_outline),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Champ obligatoire' : null,
                          ),
                          const SizedBox(height: 18),

                          // Mot de passe
                          _label('Mot de passe'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            onFieldSubmitted: (_) => _login(),
                            decoration: _inputDeco(
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscure ? Icons.visibility_outlined
                                           : Icons.visibility_off_outlined,
                                  color: Colors.grey[400], size: 20),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Mot de passe obligatoire' : null,
                          ),
                          const SizedBox(height: 32),

                          // Bouton connexion
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A3A6B),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5))
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.login, size: 20),
                                        SizedBox(width: 8),
                                        Text('Se connecter',
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Lien inscription
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const RegisterPage())),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Pas encore de compte ? ',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: 'S\'inscrire',
                                      style: TextStyle(
                                          color: Color(0xFF1A3A6B),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Info compte test
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F4FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD0DCFF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(children: [
                                  Icon(Icons.info_outline, size: 16, color: Color(0xFF1A3A6B)),
                                  SizedBox(width: 6),
                                  Text('Compte de test',
                                      style: TextStyle(fontWeight: FontWeight.w600,
                                          fontSize: 13, color: Color(0xFF1A3A6B))),
                                ]),
                                const SizedBox(height: 6),
                                _infoRow('Username', 'mamadou.diallo'),
                                _infoRow('Password', 'Password123'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,
          color: Color(0xFF374151)));

  InputDecoration _inputDeco({required String hint, required IconData icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        suffixIcon: suffix,
        filled: true, fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE05252))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(top: 3),
    child: Row(children: [
      Text('$label : ', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      SelectableText(value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
              color: Color(0xFF1A3A6B))),
    ]),
  );
}
