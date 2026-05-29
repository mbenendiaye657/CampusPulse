from django.db import migrations, models

class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name='Schedule',
            fields=[
                ('id',          models.BigAutoField(auto_created=True, primary_key=True)),
                ('level',       models.CharField(max_length=2,
                    choices=[('L1','Licence 1'),('L2','Licence 2'),('L3','Licence 3'),
                             ('M1','Master 1'),('M2','Master 2')])),
                ('department',  models.CharField(max_length=100, default='TIC')),
                ('course',      models.CharField(max_length=150)),
                ('teacher',     models.CharField(max_length=100)),
                ('room',        models.CharField(max_length=50)),
                ('day',         models.CharField(max_length=20,
                    choices=[('Monday','Lundi'),('Tuesday','Mardi'),('Wednesday','Mercredi'),
                             ('Thursday','Jeudi'),('Friday','Vendredi'),('Saturday','Samedi')])),
                ('start_time',  models.TimeField()),
                ('end_time',    models.TimeField()),
                ('week_number', models.IntegerField(default=1)),
                ('year',        models.IntegerField(default=2026)),
                ('course_type', models.CharField(max_length=4,
                    choices=[('CM','Cours Magistral'),('TD','Travaux Dirigés'),
                             ('TP','Travaux Pratiques'),('EXAM','Examen')], default='CM')),
                ('created_at',  models.DateTimeField(auto_now_add=True)),
            ],
            options={'verbose_name': 'Cours', 'verbose_name_plural': 'Cours',
                     'ordering': ['day', 'start_time']},
        ),
    ]
