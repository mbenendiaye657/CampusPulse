import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/services/auth_services.dart';
import '../../../auth/presentation/pages/login.dart';
import '../providers/she_proveder.dart';
import '../widget/calendrier.dart';
import '../../domaine/entities/schedule_entity.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});
  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  String _firstName = '';
  String _level     = '';
  String _dept      = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final fn = await AuthService.getFirstName()  ?? '';
    final lv = await AuthService.getLevel()      ?? '';
    final dp = await AuthService.getDepartment() ?? '';
    if (mounted) setState(() { _firstName = fn; _level = lv; _dept = dp; });
  }

  int _currentWeek() {
    final now = DateTime.now();
    return ((now.difference(DateTime(now.year,1,1)).inDays) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    final selectedWeek = ref.watch(selectedWeekProvider);
    final scheduleState = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(children: [
          // ── Header ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A6B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(children: [
              Row(children: [
                // Bouton retour
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
                // Logo
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset('assets/images/uadb_logo.jpg', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.school, color: Color(0xFF1A3A6B), size: 22)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('$_firstName — $_level',
                        style: const TextStyle(color: Colors.white, fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text(_dept, style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ]),
                ),
                // Refresh
                GestureDetector(
                  onTap: () => ref.invalidate(scheduleProvider),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  ),
                ),
              ]),

              const SizedBox(height: 12),

              // Navigateur de semaine
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2))),
                child: Row(children: [
                  // Semaine précédente
                  GestureDetector(
                    onTap: () => ref.read(selectedWeekProvider.notifier).state = selectedWeek - 1,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 20),
                    ),
                  ),
                  Expanded(
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Semaine $selectedWeek',
                            style: const TextStyle(color: Colors.white, fontSize: 14,
                                fontWeight: FontWeight.bold)),
                        if (selectedWeek == _currentWeek()) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2DAB6F),
                              borderRadius: BorderRadius.circular(8)),
                            child: const Text('Actuelle',
                                style: TextStyle(color: Colors.white,
                                    fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ]),
                      Text(_weekDateRange(selectedWeek),
                          style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    ]),
                  ),
                  // Semaine suivante
                  GestureDetector(
                    onTap: () => ref.read(selectedWeekProvider.notifier).state = selectedWeek + 1,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ),
            ]),
          ),

          // ── Contenu ──────────────────────────────────────
          Expanded(
            child: scheduleState.when(
              loading: () => _buildShimmer(),
              error:   (e, _) => _buildError(e.toString()),
              data:    (schedules) => _buildContent(schedules),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildContent(List<ScheduleEntity> schedules) {
    return RefreshIndicator(
      color: const Color(0xFF1A3A6B),
      onRefresh: () async => ref.invalidate(scheduleProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Prochain cours
          if (schedules.isNotEmpty) _buildNextCourse(schedules),
          if (schedules.isNotEmpty) const SizedBox(height: 16),

          // Stats de la semaine
          _buildWeekStats(schedules),
          const SizedBox(height: 20),

          // Titre
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Emploi du temps', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A6B))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A6B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10)),
              child: Text('${schedules.length} cours',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1A3A6B),
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 12),

          // Calendrier Syncfusion
          if (schedules.isEmpty)
            _buildEmpty()
          else
            Container(
              height: 650,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SfCalendar(
                  view: CalendarView.week,
                  dataSource: ScheduleCalendarDataSource(schedules),
                  todayHighlightColor: const Color(0xFF1A3A6B),
                  backgroundColor: Colors.white,
                  cellBorderColor: Colors.grey.shade100,
                  showDatePickerButton: true,
                  showNavigationArrow: true,
                  appointmentTextStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  headerStyle: const CalendarHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A6B))),
                  viewHeaderStyle: ViewHeaderStyle(
                    backgroundColor: const Color(0xFF1A3A6B).withOpacity(0.05),
                    dayTextStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A6B)),
                    dateTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                        color: Color(0xFF1A3A6B))),
                  timeSlotViewSettings: const TimeSlotViewSettings(
                      startHour: 7, endHour: 20, timeIntervalHeight: 65),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // Prochain cours
  Widget _buildNextCourse(List<ScheduleEntity> schedules) {
    final now = DateTime.now();
    final upcoming = schedules.where((s) => s.startTime.isAfter(now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next    = upcoming.first;
    final diff    = next.startTime.difference(now);
    final diffStr = diff.inHours > 0
        ? 'Dans ${diff.inHours}h${diff.inMinutes % 60 > 0 ? "${diff.inMinutes % 60}min" : ""}'
        : 'Dans ${diff.inMinutes} min';

    final typeColors = {
      'CM': const Color(0xFF1A3A6B),
      'TD': const Color(0xFF2DAB6F),
      'TP': const Color(0xFFF5A623),
      'EXAM': const Color(0xFFE05252),
    };
    final color = typeColors[next.courseType] ?? const Color(0xFF1A3A6B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.75)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8)),
            child: Text('Prochain cours · $diffStr',
                style: const TextStyle(color: Colors.white, fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(next.courseName, style: const TextStyle(color: Colors.white, fontSize: 20,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.person_outline, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(next.teacher, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(width: 16),
          const Icon(Icons.room_outlined, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(next.room, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.access_time, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            '${_fmt(next.startTime)} – ${_fmt(next.endTime)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }

  // Stats semaine
  Widget _buildWeekStats(List<ScheduleEntity> schedules) {
    final cm   = schedules.where((s) => s.courseType == 'CM').length;
    final td   = schedules.where((s) => s.courseType == 'TD').length;
    final tp   = schedules.where((s) => s.courseType == 'TP').length;
    final exam = schedules.where((s) => s.courseType == 'EXAM').length;

    return Row(children: [
      Expanded(child: _miniStat('CM',   cm.toString(),   const Color(0xFF1A3A6B))),
      const SizedBox(width: 8),
      Expanded(child: _miniStat('TD',   td.toString(),   const Color(0xFF2DAB6F))),
      const SizedBox(width: 8),
      Expanded(child: _miniStat('TP',   tp.toString(),   const Color(0xFFF5A623))),
      const SizedBox(width: 8),
      Expanded(child: _miniStat('EXAM', exam.toString(), const Color(0xFFE05252))),
    ]);
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Aucun cours cette semaine',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
        ]),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: List.generate(4, (_) => Container(
          height: 70, margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ))),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.signal_wifi_off, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Impossible de charger l\'emploi du temps',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(msg, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(scheduleProvider),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3A6B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
    );
  }

  String _fmt(DateTime dt) {
    return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
  }

  String _weekDateRange(int week) {
    final now  = DateTime.now();
    final jan4 = DateTime(now.year, 1, 4);
    final monday = jan4.subtract(Duration(days: jan4.weekday - 1))
        .add(Duration(days: (week - 1) * 7));
    final friday = monday.add(const Duration(days: 4));
    final months = ['jan','fév','mar','avr','mai','juin',
                    'jul','aoû','sep','oct','nov','déc'];
    return '${monday.day} ${months[monday.month-1]} → ${friday.day} ${months[friday.month-1]}';
  }
}
