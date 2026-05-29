# CampusPulse — Backend Django
**Université Alioune DIOP de Bambey — Masters SI/SR 2026**

---

## 🚀 Démarrage rapide (SQLite — sans XAMPP)

### Étape 1 — Installer Python
Télécharger Python 3.11+ sur https://python.org
⚠️ Cocher "Add to PATH" pendant l'installation

### Étape 2 — Ouvrir le terminal dans le dossier CampusPulse
```bash
cd C:\chemin\vers\CampusPulse
```

### Étape 3 — Créer l'environnement virtuel
```bash
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Mac/Linux
```

### Étape 4 — Installer les dépendances
```bash
pip install -r requirements.txt
```

### Étape 5 — Créer les tables de la base de données
```bash
python manage.py makemigrations
python manage.py migrate
```

### Étape 6 — Créer un superadmin (pour accéder à /admin)
```bash
python manage.py createsuperuser
```

### Étape 7 — Insérer les données de test
```bash
python create_test_data.py
```

### Étape 8 — Lancer le serveur
```bash
python manage.py runserver
```
✅ API disponible sur : http://127.0.0.1:8000/

---

## Endpoints API

| Méthode | URL | Auth | Description |
|---------|-----|------|-------------|
| POST | /api/auth/register/ | ❌ | Inscription |
| POST | /api/auth/login/ | ❌ | Connexion → JWT |
| POST | /api/auth/refresh/ | ❌ | Renouveler token |
| GET  | /api/auth/me/ | ✅ | Profil étudiant |
| GET  | /api/schedules/?week_number=21 | ✅ | Emploi du temps |
| GET  | /api/schedules/today/ | ✅ | Cours du jour |
| POST | /api/schedules/create/ | ✅ | Créer un cours |
| PUT  | /api/schedules/update/1/ | ✅ | Modifier un cours |
| DELETE | /api/schedules/delete/1/ | ✅ | Supprimer |

## Compte de test (après seed)
- Username : mamadou.diallo
- Password : Password123

## Admin Django
http://127.0.0.1:8000/admin/
