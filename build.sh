#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt
python manage.py collectstatic --noinput
python manage.py migrate --noinput

# Check if DB is empty
USER_COUNT=$(python manage.py shell -c "
from django.contrib.auth import get_user_model
print(get_user_model().objects.count())
" 2>/dev/null | grep -E '^[0-9]+$' || echo "0")

echo "User count: $USER_COUNT"

if [ "$USER_COUNT" = "0" ]; then
    echo "Empty DB — loading fixture..."
    python manage.py loaddata fixtures/initial_data.json
    echo "Done."
else
    echo "DB already populated."
fi
