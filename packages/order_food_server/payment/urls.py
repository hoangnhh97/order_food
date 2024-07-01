from django.urls import path

from .views import CancelPayment, CreatePaymentLink, PaymentCallback

urlpatterns = [
    path('payment/create-payment-link/',
         CreatePaymentLink.as_view(), name='create_payment_link'),
    path('payment/cancel-payment/<str:id>/',
         CancelPayment.as_view(), name='cancel_payment'),
    path('payment/callback/',
         PaymentCallback.as_view(), name='payment_callback'),
]
