# gs/serializers.py
from email.policy import default
from rest_framework import serializers


class CreatePaymentLinkRequest(serializers.Serializer):
    # Define the fields based on the structure of your Google Sheets data
    # For example, if each record has 'name' and 'value' fields:
    orderDate = serializers.CharField(
        max_length=100, allow_blank=True, required=False, allow_null=True)
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
    unitPrice = serializers.IntegerField(
        required=False, allow_null=True)
    totalPrice = serializers.IntegerField(
        required=False, allow_null=True)
    buyerName = serializers.CharField(
        max_length=500, allow_blank=True, required=False, allow_null=True)


class TransactionSerializer(serializers.Serializer):
    reference = serializers.CharField(
        max_length=50, allow_null=True, allow_blank=True)
    amount = serializers.IntegerField()
    accountNumber = serializers.CharField(
        max_length=20, allow_null=True, allow_blank=True)
    description = serializers.CharField(
        max_length=100, allow_null=True, allow_blank=True)
    transactionDateTime = serializers.DateTimeField(format='%d/%m/%Y')
    virtualAccountName = serializers.CharField(
        max_length=100, allow_null=True, allow_blank=True)
    virtualAccountNumber = serializers.CharField(
        max_length=20, allow_null=True, allow_blank=True)
    counterAccountBankId = serializers.CharField(
        max_length=50, allow_null=True, allow_blank=True)
    counterAccountBankName = serializers.CharField(
        max_length=100, allow_null=True, allow_blank=True)
    counterAccountName = serializers.CharField(
        max_length=100, allow_null=True, allow_blank=True)
    counterAccountNumber = serializers.CharField(
        max_length=20, allow_null=True, allow_blank=True)


class PaymentDataSerializer(serializers.Serializer):
    id = serializers.CharField(
        max_length=32, required=False, allow_null=True, allow_blank=True)
    orderCode = serializers.IntegerField(required=False, allow_null=True)
    amount = serializers.IntegerField(required=False, allow_null=True)
    amountPaid = serializers.IntegerField(required=False, allow_null=True)
    amountRemaining = serializers.IntegerField(required=False, allow_null=True)
    status = serializers.CharField(required=False, max_length=20)
    createdAt = serializers.DateTimeField(required=False, allow_null=True)
    transactions = TransactionSerializer(
        many=True, required=False, allow_null=True)
    cancellationReason = serializers.CharField(
        max_length=255, required=False, allow_null=True, allow_blank=True)
    canceledAt = serializers.DateTimeField(required=False, allow_null=True)


class MainSerializer(serializers.Serializer):
    code = serializers.CharField(max_length=2)
    desc = serializers.CharField(max_length=255)
    data = PaymentDataSerializer()
    signature = serializers.CharField(max_length=64)
