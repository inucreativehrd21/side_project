from .base import *

# 서버 IP 또는 도메인으로 변경
ALLOWED_HOSTS = ['your-server-ip-or-domain']
DEBUG = False

# 프로덕션에서는 정적 파일을 collectstatic으로 모음
STATICFILES_DIRS = []
STATIC_ROOT = BASE_DIR / 'staticfiles'
