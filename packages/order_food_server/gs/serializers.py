# gs/serializers.py
from email.policy import default
from rest_framework import serializers


class GoogleSheetDataSerializer(serializers.Serializer):
    # Define the fields based on the structure of your Google Sheets data
    # For example, if each record has 'name' and 'value' fields:
    name = serializers.CharField(
        max_length=100, allow_blank=True, required=False, allow_null=True)
    value = serializers.CharField(
        max_length=1000, allow_blank=True, required=False, allow_null=True)
    quantity = serializers.IntegerField(
        default=0, required=False, allow_null=True)
    unitPrice = serializers.IntegerField(
        required=False, allow_null=True)


class ListMemberDataSerializer(serializers.Serializer):
    # Define the fields based on the structure of your Google Sheets data
    # For example, if each record has 'name' and 'value' fields:
    name = serializers.CharField(
        max_length=100, allow_blank=True, required=False, allow_null=True)


class UpdateOrderByUserSerializer(serializers.Serializer):
    # Define the fields based on the structure of your Google Sheets data
    # For example, if each record has 'name' and 'value' fields:
    orderCode = serializers.IntegerField(
        required=False, allow_null=True)
    name = serializers.CharField(
        max_length=100, allow_blank=True, required=False, allow_null=True)
    value = serializers.CharField(
        max_length=1000, allow_blank=True, required=False, allow_null=True)
    note = serializers.CharField(
        max_length=1000, allow_blank=True, required=False, allow_null=True)
    quantity = serializers.IntegerField(
        default=0, required=False, allow_null=True)
    unitPrice = serializers.CharField(
        max_length=500, allow_blank=True, required=False, allow_null=True)
