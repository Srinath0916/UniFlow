from django.core.management.base import BaseCommand
from django.core.management import call_command
from django.db.models.signals import post_save, post_delete


class Command(BaseCommand):
    help = 'Load initial data with signals disabled'

    def handle(self, *args, **options):
        from info import models
        
        # Disconnect all signals temporarily
        post_save.disconnect(models.create_marks, sender=models.Student)
        post_save.disconnect(models.create_marks, sender=models.Assign)
        post_save.disconnect(models.create_marks_class, sender=models.Assign)
        post_save.disconnect(models.create_attendance, sender=models.AssignTime)
        post_delete.disconnect(models.delete_marks, sender=models.Assign)
        
        self.stdout.write('Signals disabled — loading fixture...')
        
        try:
            call_command('loaddata', 'fixtures/initial_data.json', verbosity=2)
            self.stdout.write(self.style.SUCCESS('Fixture loaded successfully'))
        finally:
            # Reconnect signals
            post_save.connect(models.create_marks, sender=models.Student)
            post_save.connect(models.create_marks, sender=models.Assign)
            post_save.connect(models.create_marks_class, sender=models.Assign)
            post_save.connect(models.create_attendance, sender=models.AssignTime)
            post_delete.connect(models.delete_marks, sender=models.Assign)
            self.stdout.write('Signals reconnected')
