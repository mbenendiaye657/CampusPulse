from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import register_student, get_profile

urlpatterns = [
    # POST /api/auth/register/  → inscription
    path('register/', register_student),
    # POST /api/auth/login/     → connexion → retourne access + refresh token
    path('login/',    TokenObtainPairView.as_view()),
    # POST /api/auth/refresh/   → renouveler le token
    path('refresh/',  TokenRefreshView.as_view()),
    # GET  /api/auth/me/        → profil étudiant connecté
    path('me/',       get_profile),
]
