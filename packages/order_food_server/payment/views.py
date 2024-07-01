# myapp/views.py

from datetime import datetime
import random
from wsgiref.handlers import format_date_time

from decouple import config
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from payos import ItemData, PaymentData, PayOS
from rest_framework import status
from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .payment_handler import updateOrderByUser, updatePaymentStatus
from .serializers import (CreatePaymentLinkRequest,
                          PaymentDataSerializer)

client_id = config('PAYOS_CLIENT_ID')
api_key = config('PAYOS_API_KEY')
checksum_key = config('PAYOS_CHECKSUM_KEY')


@permission_classes([AllowAny])
class CreatePaymentLink(APIView):
    @swagger_auto_schema(
        operation_summary="Create payment link",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'orderDate': openapi.Schema(type=openapi.TYPE_STRING, description='Order Date'),
                'buyerName': openapi.Schema(type=openapi.TYPE_STRING, description='Buyer Name'),
                'orderCode': openapi.Schema(type=openapi.TYPE_INTEGER, description='Order Code'),
                'name': openapi.Schema(type=openapi.TYPE_STRING, description='Order Code'),
                'note': openapi.Schema(type=openapi.TYPE_STRING, description='Order Note'),
                'quantity': openapi.Schema(type=openapi.TYPE_INTEGER, description='Quantity'),
                'unitPrice': openapi.Schema(type=openapi.TYPE_NUMBER, description='Unit Price'),
                'totalPrice': openapi.Schema(type=openapi.TYPE_NUMBER, description='Total Price'),
            }
        ),
    )
    def post(self, request):
        orderCode = generate_unique_order_code()
        serializer = CreatePaymentLinkRequest(data=request.data)
        print(serializer)

        if (serializer.is_valid()):
            data = updateOrderByUser(
                serializer.validated_data['orderDate'],
                serializer.validated_data['buyerName'],
                orderCode,
                serializer.validated_data['name'],
                serializer.validated_data['note'],
                serializer.validated_data['quantity'],
                False)

            if (data == True):
                payOS = PayOS(client_id=client_id, api_key=api_key,
                              checksum_key=checksum_key)

                print(serializer.validated_data['unitPrice'])

                name = serializer.validated_data['name']
                quantity = serializer.validated_data['quantity']
                unitPrice = 2000
                buyerName = serializer.validated_data['buyerName']
                totalPrice = unitPrice*quantity
                item = ItemData(name=name, quantity=quantity, price=unitPrice)
                paymentData = PaymentData(orderCode=orderCode, buyerName=buyerName, amount=totalPrice, description="Thanh toan don hang",
                                          items=[item], cancelUrl="http://localhost:7979/payment/cancel-payment", returnUrl="http://localhost:7979/payment/callback")

                paymentLinkData = payOS.createPaymentLink(
                    paymentData=paymentData)
                print(paymentLinkData)

                # Return the validated data
                return Response(paymentLinkData.to_json(), content_type='application/json; charset=utf-8')
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@permission_classes([AllowAny])
class CancelPayment(APIView):
    @swagger_auto_schema(
        operation_summary="Cancel payment link"
    )
    def delete(self, request, id: int):
        payOS = PayOS(client_id=client_id, api_key=api_key,
                      checksum_key=checksum_key)
        paymentLinkInfo = payOS.cancelPaymentLink(orderId=id)
        print(paymentLinkInfo)

        # paymentLinkInfo = payOS.getPaymentLinkInformation(orderId=id)
        # print(paymentLinkInfo.status)
        # Return the validated data
        return Response(paymentLinkInfo.to_json(), content_type='application/json; charset=utf-8')


@permission_classes([AllowAny])
class PaymentCallback(APIView):
    @swagger_auto_schema(
        operation_summary="Payment callback",
        manual_parameters=[
            openapi.Parameter('code', openapi.IN_QUERY,
                              description="", type=openapi.TYPE_STRING),
            openapi.Parameter('id', openapi.IN_QUERY,
                              description="", type=openapi.TYPE_STRING),
            openapi.Parameter('cancel', openapi.IN_QUERY,
                              description="", type=openapi.TYPE_STRING),
            openapi.Parameter('status', openapi.IN_QUERY,
                              description="", type=openapi.TYPE_STRING),
            openapi.Parameter('orderCode', openapi.IN_QUERY,
                              description="", type=openapi.TYPE_STRING, required=True),
        ],
    )
    def get(self, request):
        payOS = PayOS(client_id=client_id, api_key=api_key,
                      checksum_key=checksum_key)

        code = self.request.query_params.get('code', None)
        id = self.request.query_params.get('id', None)
        orderCode = self.request.query_params.get('orderCode', None)

        print('PaymentId', id, code)
        paymentLinkInfo = payOS.getPaymentLinkInformation(orderId=id)
        print(paymentLinkInfo)

        if paymentLinkInfo and len(orderCode) > 0:
            formatted_date = convert_datetime_to_string(
                paymentLinkInfo.createdAt)
            order_status = paymentLinkInfo.status

            if (code == '00' and order_status == 'PAID'):
                updatePaymentStatus(formatted_date, orderCode)
                return Response(True, content_type='application/json; charset=utf-8')
        return Response(False, status=status.HTTP_409_CONFLICT)


def generate_unique_order_code():
    order_code = random.randint(1000000000, 9999999999)
    return order_code


def convert_datetime_to_string(date_string):
    # Parse the date-time string into a datetime object
    dt = datetime.fromisoformat(date_string)

    # Format the datetime object into the desired string format
    formatted_date = dt.strftime('%d/%m/%Y')

    return formatted_date
