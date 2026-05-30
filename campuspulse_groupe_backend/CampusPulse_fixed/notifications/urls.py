from django.urls import path
from .views import (
    get_notifications, 
    create_notification, 
    update_notification, 
    delete_notification,
    mark_as_read # Nouveau
)

urlpatterns = [
    # Récupérer la liste
    path('', get_notifications),
    
    # Création
    path('create/', create_notification),
    
    # Marquer comme lu (C'est cette ligne que Flutter appelle !)
    path('<int:pk>/read/', mark_as_read),
    
    # Autres actions
    path('update/<int:pk>/', update_notification),
    path('delete/<int:pk>/', delete_notification),
]