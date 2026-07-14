from django.http import JsonResponse
from django.urls import path
from django.db import connection


def index(_request):
    return JsonResponse({"service": "django-app", "status": "ok"})


def health(_request):
    return JsonResponse({"status": "healthy"})


def ready(_request):
    try:
        connection.ensure_connection()
        return JsonResponse({"status": "ready", "database": "connected"})
    except Exception:
        return JsonResponse({"status": "not ready", "database": "error"}, status=503)


urlpatterns = [path("", index), path("health/", health), path("ready/", ready)]
