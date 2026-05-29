import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey       = GlobalKey<FormState>();
  final _usernameCtrl  = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl  = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _codePermCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  bool _obscure1 = true, _obscure2 = true, _isLoading = false;
  String _level = 'M1', _dept = 'TIC';
  final _dio = Dio();

  static const _levels = ['L1','L2','L3','M1','M2'];
  static const _depts  = ['TIC','Mathématiques','Physique','Chimie','Gestion','Droit','Lettres'];

  @override
  void dispose() {
    for (final c in [_usernameCtrl,_firstNameCtrl,_lastNameCtrl,
                     _emailCtrl,_codePermCtrl,_passwordCtrl,_confirmCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _dio.post(
        'http://127.0.0.1:8000/api/auth/register/',
        data: {
          'username':   _usernameCtrl.text.trim(),
          'email':      _emailCtrl.text.trim(),
          'first_name': _firstNameCtrl.text.trim(),
          'last_name':  _lastNameCtrl.text.trim(),
          'password':   _passwordCtrl.text,
          'codeperm':   _codePermCtrl.text.trim().toUpperCase(),
          'level':      _level,
          'department': _dept,
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Compte créé ! Connectez-vous.'),
        backgroundColor: Color(0xFF2DAB6F),
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginPage()));
    } on DioException catch (e) {
      final errors = e.response?.data;
      final msg = errors is Map ? errors.values.first.toString() : 'Erreur inscription';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: const Color(0xFFE05252),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A6B),
      body: SafeArea(
        child: Column(
          children: [
            // Header compact
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30)),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(child: Image.asset('assets/images/uadb_logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.school, color: Color(0xFF1A3A6B), size: 20))),
                ),
                const SizedBox(width: 10),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CampusPulse', style: TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Créer un compte', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inscription', style: TextStyle(fontSize: 22,
                            fontWeight: FontWeight.bold, color: Color(0xFF1A3A6B))),
                        const SizedBox(height: 4),
                        Text('Remplissez vos informations universitaires',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        const SizedBox(height: 22),

                        _lbl('Nom d\'utilisateur'), const SizedBox(height:6),
                        _field(_usernameCtrl, 'Ex: mamadou.diallo', Icons.person_outline,
                            v: (v) => v!.isEmpty ? 'Obligatoire' : null),
                        const SizedBox(height:14),

                        Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_lbl('Prénom'), const SizedBox(height:6),
                              _field(_firstNameCtrl,'Mamadou', Icons.person_outline,
                                  v: (v) => v!.isEmpty ? 'Obligatoire' : null)])),
                          const SizedBox(width:12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_lbl('Nom'), const SizedBox(height:6),
                              _field(_lastNameCtrl,'Diallo', Icons.person_outline,
                                  v: (v) => v!.isEmpty ? 'Obligatoire' : null)])),
                        ]),
                        const SizedBox(height:14),

                        _lbl('Email'), const SizedBox(height:6),
                        _field(_emailCtrl,'exemple@uadb.sn', Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            v: (v) => !v!.contains('@') ? 'Email invalide' : null),
                        const SizedBox(height:14),

                        _lbl('Code permanent (matricule)'), const SizedBox(height:6),
                        _field(_codePermCtrl,'UADB2024001', Icons.badge_outlined,
                            v: (v) => v!.isEmpty ? 'Obligatoire' : null),
                        const SizedBox(height:14),

                        Row(children: [
                          Expanded(flex:2, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_lbl('Département'), const SizedBox(height:6),
                              _dropdown(_dept, _depts, (v) => setState(() => _dept = v!))])),
                          const SizedBox(width:12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_lbl('Niveau'), const SizedBox(height:6),
                              _dropdown(_level, _levels, (v) => setState(() => _level = v!))])),
                        ]),
                        const SizedBox(height:14),

                        _lbl('Mot de passe'), const SizedBox(height:6),
                        _field(_passwordCtrl,'••••••••', Icons.lock_outline,
                            obscure: _obscure1,
                            toggle: () => setState(() => _obscure1 = !_obscure1),
                            v: (v) => v!.length < 8 ? 'Min. 8 caractères' : null),
                        const SizedBox(height:14),

                        _lbl('Confirmer le mot de passe'), const SizedBox(height:6),
                        _field(_confirmCtrl,'••••••••', Icons.lock_outline,
                            obscure: _obscure2,
                            toggle: () => setState(() => _obscure2 = !_obscure2),
                            v: (v) => v != _passwordCtrl.text ? 'Mots de passe différents' : null),
                        const SizedBox(height:28),

                        SizedBox(width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A3A6B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                : const Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: [Icon(Icons.person_add, size:20), SizedBox(width:8),
                                      Text("S'inscrire", style: TextStyle(fontSize:16,
                                          fontWeight: FontWeight.w600))]),
                          ),
                        ),
                        const SizedBox(height:16),
                        Center(child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => const LoginPage())),
                          child: RichText(text: const TextSpan(
                            text: 'Déjà un compte ? ',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [TextSpan(text: 'Se connecter',
                              style: TextStyle(color: Color(0xFF1A3A6B),
                                  fontWeight: FontWeight.w600))],
                          )),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lbl(String t) => Text(t, style: const TextStyle(fontWeight: FontWeight.w600,
      fontSize: 13, color: Color(0xFF374151)));

  Widget _field(TextEditingController ctrl, String hint, IconData icon, {
    String? Function(String?)? v, bool obscure=false, VoidCallback? toggle,
    TextInputType keyboardType=TextInputType.text}) =>
      TextFormField(controller: ctrl, obscureText: obscure, keyboardType: keyboardType,
        validator: v,
        decoration: InputDecoration(
          hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 18),
          suffixIcon: toggle != null ? IconButton(
            icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[400], size: 18), onPressed: toggle) : null,
          filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE05252))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ));

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChange) =>
      DropdownButtonFormField<String>(
        value: value, onChanged: onChange, isExpanded: true,
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A3A6B), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        items: items.map((e) => DropdownMenuItem(value: e,
            child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
      );
}
