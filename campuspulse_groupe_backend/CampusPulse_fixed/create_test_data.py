"""
Script de données de test pour CampusPulse Django
Lancer : python manage.py shell < create_test_data.py
OU      : python create_test_data.py (depuis le dossier CampusPulse)
"""
import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from authentication.models import Student
from schedules.models import Schedule

# ── Étudiant test ─────────────────────────────────────────────────────────────
student, created = Student.objects.get_or_create(
    username='mamadou.diallo',
    defaults={
        'email':      'mamadou.diallo@uadb.sn',
        'first_name': 'Mamadou',
        'last_name':  'Diallo',
        'codeperm':   'UADB2024001',
        'level':      'M1',
        'department': 'TIC',
    }
)
if created:
    student.set_password('Password123')
    student.save()
    print(f'✅ Étudiant créé : {student.username}')
else:
    print(f'ℹ️  Étudiant existant : {student.username}')

# ── Cours semaine courante ─────────────────────────────────────────────────────
from datetime import date
week = date.today().isocalendar()[1]
year = date.today().year

courses_data = [
    # LUNDI
    dict(day='Monday',    course='Architecture des Systèmes Distribués', teacher='Dr. Ibrahima Gaye',    room='Amphi A',      start_time='08:00', end_time='10:00', course_type='CM'),
    dict(day='Monday',    course='Développement Mobile Flutter',          teacher='M. Moussa Diallo',      room='Salle Info 1', start_time='10:30', end_time='12:30', course_type='TP'),
    # MARDI
    dict(day='Tuesday',   course='Base de données avancées',              teacher='Dr. Fatou Ndiaye',      room='Salle B12',    start_time='08:00', end_time='10:00', course_type='TD'),
    dict(day='Tuesday',   course='Réseaux & Protocoles',                  teacher='Dr. Cheikh Sow',        room='Amphi B',      start_time='14:00', end_time='16:00', course_type='CM'),
    # MERCREDI
    dict(day='Wednesday', course='Intelligence Artificielle',             teacher='Dr. Aminata Sarr',      room='Salle Info 2', start_time='09:00', end_time='11:00', course_type='CM'),
    dict(day='Wednesday', course='Sécurité des Systèmes',                 teacher='Dr. Omar Ba',           room='Salle B08',    start_time='14:00', end_time='16:00', course_type='TD'),
    # JEUDI
    dict(day='Thursday',  course='Développement Mobile Flutter',          teacher='M. Moussa Diallo',      room='Salle Info 1', start_time='10:00', end_time='12:00', course_type='TD'),
    dict(day='Thursday',  course='Gestion de Projet SI',                  teacher='M. Seydou Fall',        room='Salle B05',    start_time='14:00', end_time='16:00', course_type='CM'),
    # VENDREDI
    dict(day='Friday',    course='Soutenance Projet Final',               teacher='Commission pédagogique',room='Salle de conf.',start_time='08:00', end_time='12:00', course_type='EXAM'),
]

created_count = 0
for c in courses_data:
    _, created = Schedule.objects.get_or_create(
        level='M1', department='TIC',
        day=c['day'], course=c['course'],
        week_number=week, year=year,
        defaults={**c, 'level': 'M1', 'department': 'TIC',
                  'week_number': week, 'year': year}
    )
    if created:
        created_count += 1

print(f'✅ {created_count} cours créés pour la semaine {week}/{year}')
print(f'\n📋 Identifiants de test :')
print(f'   Username : mamadou.diallo')
print(f'   Password : Password123')
print(f'   Level    : M1 | Département : TIC')
print(f'\n🚀 Lancer le serveur : python manage.py runserver')
