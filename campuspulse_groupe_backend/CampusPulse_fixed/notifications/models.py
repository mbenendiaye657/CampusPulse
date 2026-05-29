from django.db import models
from authentication.models import Student


class Notification(models.Model):

    """student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE
    )"""
    student = models.ForeignKey(
        Student,
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )
    title = models.CharField(max_length=255)
    
    message = models.TextField()

    is_read = models.BooleanField(default=False)

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.message