from django.db import models

DAYS = [
    ('Monday',    'Lundi'),
    ('Tuesday',   'Mardi'),
    ('Wednesday', 'Mercredi'),
    ('Thursday',  'Jeudi'),
    ('Friday',    'Vendredi'),
    ('Saturday',  'Samedi'),
]

LEVEL_CHOICES = [
    ('L1', 'Licence 1'), ('L2', 'Licence 2'), ('L3', 'Licence 3'),
    ('M1', 'Master 1'),  ('M2', 'Master 2'),
]

TYPE_CHOICES = [
    ('CM', 'Cours Magistral'),
    ('TD', 'Travaux Dirigés'),
    ('TP', 'Travaux Pratiques'),
    ('EXAM', 'Examen'),
]

class Schedule(models.Model):
    """
    Un cours dans l'emploi du temps.
    Filtré par level + department pour chaque étudiant.
    """
    level       = models.CharField(max_length=2,  choices=LEVEL_CHOICES)
    department  = models.CharField(max_length=100, default='TIC')
    course      = models.CharField(max_length=150, verbose_name="Intitulé du cours")
    teacher     = models.CharField(max_length=100, verbose_name="Professeur")
    room        = models.CharField(max_length=50,  verbose_name="Salle")
    day         = models.CharField(max_length=20,  choices=DAYS)
    start_time  = models.TimeField(verbose_name="Heure début")
    end_time    = models.TimeField(verbose_name="Heure fin")
    week_number = models.IntegerField(default=1,   verbose_name="Numéro semaine")
    year        = models.IntegerField(default=2026)
    course_type = models.CharField(max_length=4,   choices=TYPE_CHOICES, default='CM')
    created_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name        = "Cours"
        verbose_name_plural = "Cours"
        ordering            = ['day', 'start_time']

    def save(self, *args, **kwargs):
        # ✅ FIX : import local pour éviter l'import circulaire
        if self.pk:
            try:
                old = Schedule.objects.get(pk=self.pk)
                if old.room != self.room:
                    from notifications.models import Notification
                    Notification.objects.create(
                        title="Changement de salle",
                        message=f"Le cours '{self.course}' a changé de salle : {old.room} → {self.room}"
                    )
            except Schedule.DoesNotExist:
                pass
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.level} {self.department} — {self.course} ({self.day})"
