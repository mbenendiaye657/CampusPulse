import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_services.dart';
import '../../../../features/notifications/notification_service.dart';
import '../../../../features/notifications/notification_panel.dart';
import '../../../auth/presentation/pages/login.dart';
import 'she_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String _firstName  = '';
  String _lastName   = '';
  String _level      = '';
  String _department = '';
  bool   _showWelcome      = true;
  bool   _showNotifPanel   = false;

  final _notifService = NotificationService();

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    _loadUserInfo();
    // ✅ Démarrer le polling des notifications dès l'accueil
    _notifService.startPolling();
  }

  Future<void> _loadUserInfo() async {
    final fn = await AuthService.getFirstName()  ?? '';
    final ln = await AuthService.getLastName()   ?? '';
    final lv = await AuthService.getLevel()      ?? '';
    final dp = await AuthService.getDepartment() ?? '';
    setState(() {
      _firstName = fn; _lastName = ln;
      _level = lv;     _department = dp;
    });
    _animCtrl.forward();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showWelcome = false);
    });
  }

  @override
  void dispose() {
    _notifService.stopPolling();
    _animCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(children: [
              _buildHeader(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showWelcome ? _buildWelcomeBanner()
                                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainCard(context),
                          const SizedBox(height: 20),
                          const Text('Vue d\'ensemble',
                              style: TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3A6B))),
                          const SizedBox(height: 12),
                          _buildStatsRow(),
                          const SizedBox(height: 20),
                          const Text('Actions rapides',
                              style: TextStyle(fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A3A6B))),
                          const SizedBox(height: 12),
                          _buildQuickActions(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),

            // ── Overlay notification panel ────────────────
            if (_showNotifPanel)
              GestureDetector(
                onTap: () => setState(() => _showNotifPanel = false),
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),
            if (_showNotifPanel)
              Positioned(
                top: 75, right: 0, left: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: NotificationPanel(
                    onClose: () => setState(() => _showNotifPanel = false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3A6B),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(24),
          bottomRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(children: [
        Row(children: [
          // Logo UADB
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white, shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: ClipOval(
              child: Image.asset('assets/images/uadb_logo.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school, color: Color(0xFF1A3A6B), size: 28)),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_greeting()}, $_firstName !',
                  style: const TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('$_level — $_department',
                  style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
            ]),
          ),

          // ✅ Bouton cloche avec badge de notifications non lues
          StreamBuilder<List<NotificationItem>>(
            stream: _notifService.stream,
            initialData: const [],
            builder: (context, snapshot) {
              final unread = (snapshot.data ?? [])
                  .where((n) => !n.isRead).length;
              return GestureDetector(
                onTap: () => setState(() => _showNotifPanel = !_showNotifPanel),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: _showNotifPanel
                        ? Colors.white
                        : Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30)),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(
                      _showNotifPanel
                          ? Icons.close
                          : (unread > 0
                              ? Icons.notifications_active
                              : Icons.notifications_outlined),
                      color: _showNotifPanel
                          ? const Color(0xFF1A3A6B)
                          : Colors.white,
                      size: 20,
                    ),
                    if (unread > 0 && !_showNotifPanel)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          width: 14, height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE05252), shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              );
            },
          ),

          const SizedBox(width: 8),

          // Bouton déconnexion
          GestureDetector(
            onTap: () => _confirmLogout(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30)),
              child: const Icon(Icons.logout, color: Colors.white70, size: 18),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: Row(children: [
            const Icon(Icons.today_outlined, color: Colors.white70, size: 16),
            const SizedBox(width: 8),
            Text(_formattedDate(),
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      key: const ValueKey('welcome'),
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF2DAB6F), Color(0xFF1D8A57)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: const Color(0xFF2DAB6F).withOpacity(0.3),
          blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        const Text('👋', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salut $_firstName $_lastName !',
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            const Text('Bienvenue dans CampusPulse — voici ton emploi du temps',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ]),
        ),
        GestureDetector(
          onTap: () => setState(() => _showWelcome = false),
          child: const Icon(Icons.close, color: Colors.white70, size: 18)),
      ]),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A3A6B), Color(0xFF2D5AA0)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: const Color(0xFF1A3A6B).withOpacity(0.35),
          blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calendar_month, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CampusPulse', style: TextStyle(color: Colors.white,
                fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Votre agenda universitaire',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ]),
        const SizedBox(height: 18),
        const Text('Gérez votre emploi du temps,\nsuivez vos cours en temps réel.',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SchedulePage())),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Voir l\'emploi du temps',
              style: TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1A3A6B),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      Expanded(child: _statCard('Niveau', _level, Icons.school, Colors.blue)),
      const SizedBox(width: 10),
      Expanded(child: _statCard('Départ.',
          _department.length > 5 ? _department.substring(0,5) : _department,
          Icons.business, Colors.orange)),
      const SizedBox(width: 10),
      Expanded(child: _statCard('Semaine', _currentWeek().toString(),
          Icons.date_range, Colors.green)),
    ]);
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(children: [
      Expanded(child: _quickAction(
        context, Icons.calendar_today, 'Calendrier', const Color(0xFF1A3A6B),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SchedulePage())),
      )),
      const SizedBox(width: 12),
      Expanded(child: _quickAction(
        context, Icons.notifications_outlined, 'Notifications', Colors.orange,
        () => setState(() => _showNotifPanel = !_showNotifPanel),
      )),
    ]);
  }

  Widget _quickAction(BuildContext context, IconData icon, String title,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vous déconnecter ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              _notifService.stopPolling();
              await AuthService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (_) => false);
              }
            },
            child: const Text('Déconnecter',
                style: TextStyle(color: Color(0xFFE05252))),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    final days   = ['lundi','mardi','mercredi','jeudi','vendredi','samedi','dimanche'];
    final months = ['janvier','février','mars','avril','mai','juin',
                    'juillet','août','septembre','octobre','novembre','décembre'];
    return '${days[now.weekday-1]} ${now.day} ${months[now.month-1]} ${now.year}';
  }

  int _currentWeek() {
    final now = DateTime.now();
    return ((now.difference(DateTime(now.year,1,1)).inDays) / 7).ceil();
  }
}
