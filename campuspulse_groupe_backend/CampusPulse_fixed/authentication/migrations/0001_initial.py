from django.db import migrations, models
import django.contrib.auth.models
import django.contrib.auth.validators
import django.utils.timezone

class Migration(migrations.Migration):
    initial = True
    dependencies = [
        ('auth', '0012_alter_user_first_name_max_length'),
    ]
    operations = [
        migrations.CreateModel(
            name='Student',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True)),
                ('password', models.CharField(max_length=128, verbose_name='password')),
                ('last_login', models.DateTimeField(blank=True, null=True)),
                ('is_superuser', models.BooleanField(default=False)),
                ('username', models.CharField(max_length=150, unique=True,
                    validators=[django.contrib.auth.validators.UnicodeUsernameValidator()])),
                ('first_name', models.CharField(blank=True, max_length=150)),
                ('last_name',  models.CharField(blank=True, max_length=150)),
                ('email',      models.EmailField(blank=True, max_length=254)),
                ('is_staff',   models.BooleanField(default=False)),
                ('is_active',  models.BooleanField(default=True)),
                ('date_joined', models.DateTimeField(default=django.utils.timezone.now)),
                ('codeperm',   models.CharField(max_length=20, unique=True)),
                ('level',      models.CharField(max_length=2,
                    choices=[('L1','Licence 1'),('L2','Licence 2'),('L3','Licence 3'),
                             ('M1','Master 1'),('M2','Master 2')], default='M1')),
                ('department', models.CharField(max_length=100, default='TIC')),
                ('photo',      models.ImageField(blank=True, null=True, upload_to='students/')),
                ('groups',     models.ManyToManyField(blank=True, to='auth.group')),
                ('user_permissions', models.ManyToManyField(blank=True, to='auth.permission')),
            ],
            options={'verbose_name': 'Étudiant', 'verbose_name_plural': 'Étudiants'},
            managers=[('objects', django.contrib.auth.models.UserManager())],
        ),
    ]
