import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pybo', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name='question',
            name='author',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='author_question',
                to=settings.AUTH_USER_MODEL,
                default=1,
            ),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='answer',
            name='author',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='author_answer',
                to=settings.AUTH_USER_MODEL,
                default=1,
            ),
            preserve_default=False,
        ),
    ]
