#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput

# Check user count (strip the auto-import noise from output)
USER_COUNT=$(python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
try:
    print(User.objects.count())
except:
    print(0)
" 2>/dev/null | tail -1)

echo "Current user count: $USER_COUNT"

if [ "$USER_COUNT" -lt "10" ]; then
    echo "Not enough data — flushing and reloading fixture..."
    python manage.py flush --noinput
    python manage.py loaddata fixtures/initial_data.json
    echo "Fixture loaded successfully."
else
    echo "Database already seeded — skipping."
fi
