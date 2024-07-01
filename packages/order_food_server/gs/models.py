# myapp/models.py
from django.db import models


class Data(models.Model):
    name = models.CharField(max_length=100)
    value = models.IntegerField()

    def __str__(self):
        return self.name
