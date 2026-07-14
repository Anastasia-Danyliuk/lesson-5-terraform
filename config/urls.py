from django.http import JsonResponse
from django.urls import path


def index(_request):
    return JsonResponse({"service": "django-app", "status": "ok"})


def health(_request):
    return JsonResponse({"status": "healthy"})


urlpatterns = [path("", index), path("health/", health)]
