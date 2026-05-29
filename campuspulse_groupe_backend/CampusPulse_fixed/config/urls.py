from django.contrib import admin
from django.urls import path, include

from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [

    path('admin/', admin.site.urls),

    path('api/auth/', include('authentication.urls')),

    path('api/schedules/', include('schedules.urls')),

    path('api/grades/', include('grades.urls')),

    path('api/events/', include('events.urls')),

    path('api/notifications/', include('notifications.urls')),

    path('api/pass/', include('PassNumerique.urls')),

]

urlpatterns += static(
    settings.MEDIA_URL,
    document_root=settings.MEDIA_ROOT
)


