from django.db import models
from authentication.models import Student


class Grade(models.Model):

    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE
    )

    subject = models.CharField(max_length=100)

    score = models.FloatField()

    semester = models.CharField(max_length=50)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.subject