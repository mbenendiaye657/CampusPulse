from django.contrib.auth.models import AbstractUser
from django.db import models

LEVEL_CHOICES = [
    ('L1', 'Licence 1'),
    ('L2', 'Licence 2'),
    ('L3', 'Licence 3'),
    ('M1', 'Master 1'),
    ('M2', 'Master 2'),
]

class Student(AbstractUser):
    """
    Modèle étudiant — étend AbstractUser de Django.
    username = matricule étudiant (ex: UADB2024001)
    """
    codeperm   = models.CharField(max_length=20, unique=True, verbose_name="Numéro permanent")
    level      = models.CharField(max_length=2, choices=LEVEL_CHOICES, verbose_name="Niveau")
    department = models.CharField(max_length=100, verbose_name="Département")
    photo      = models.ImageField(upload_to='students/', null=True, blank=True)

    class Meta:
        verbose_name        = "Étudiant"
        verbose_name_plural = "Étudiants"

    def __str__(self):
        return f"{self.get_full_name()} ({self.username}) — {self.level} {self.department}"
