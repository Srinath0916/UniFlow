#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput

# Load initial data (users, students, teachers, etc.) — skips if already loaded
python manage.py loaddata fixtures/initial_data.json || echo "Fixture load skipped (data may already exist)"
