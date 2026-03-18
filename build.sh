#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput

# Load fixture only if no users exist yet (fresh DB)
USER_COUNT=$(python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
try:
    print(User.objects.count())
except:
    print(0)
")

echo "Current user count: $USER_COUNT"

if [ "$USER_COUNT" = "0" ]; then
    echo "Fresh database — loading fixture data..."
    python manage.py loaddata fixtures/initial_data.json
    echo "Fixture loaded successfully."
else
    echo "Database already has data — skipping fixture load."
fi
