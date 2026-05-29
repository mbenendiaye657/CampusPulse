from django.db import models
from authentication.models import Student

import qrcode

from io import BytesIO

from django.core.files import File


class PassNumerique(models.Model):

    student = models.OneToOneField(
        Student,
        on_delete=models.CASCADE
    )

    card_number = models.CharField(
        max_length=50,
        unique=True
    )

    qr_code = models.ImageField(
        upload_to='qrcodes/',
        null=True,
        blank=True
    )

    issue_date = models.DateField(auto_now_add=True)

    expiry_date = models.DateField()

    is_active = models.BooleanField(default=True)

    def __str__(self):
        return self.card_number

    def save(self, *args, **kwargs):

        qr_data = f"{self.student.username} - {self.card_number}"

        qr_image = qrcode.make(qr_data)

        buffer = BytesIO()

        qr_image.save(buffer, format='PNG')

        filename = f'{self.card_number}.png'

        self.qr_code.save(
            filename,
            File(buffer),
            save=False
        )

        super().save(*args, **kwargs)