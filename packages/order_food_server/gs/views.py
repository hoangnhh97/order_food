# myapp/views.py

from http.client import HTTPResponse
import os
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import Flow
from django.conf import settings
from django.shortcuts import redirect
from django.http import JsonResponse
from drf_yasg import openapi
from drf_yasg.utils import swagger_auto_schema
from rest_framework import generics
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .google_sheets import get_google_sheet_data, get_members, update_order_byUser
from .serializers import GoogleSheetDataSerializer, ListMemberDataSerializer, UpdateOrderByUserSerializer


@permission_classes([AllowAny])
class ListData(generics.ListAPIView):
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('orderDate', openapi.IN_QUERY,
                              description="Filter by Date", type=openapi.TYPE_STRING),
        ],
        operation_summary="List food get from gs"
    )
    def get(self, request):
        orderDate = self.request.query_params.get('orderDate', None)

        data = get_google_sheet_data(orderDate)
        # Assuming data is a list of dictionaries
        serializer = GoogleSheetDataSerializer(data=data, many=True)
        serializer.is_valid(raise_exception=True)  # Validate the data
        # Return the validated data
        return Response(serializer.data, content_type='application/json; charset=utf-8')


@permission_classes([AllowAny])
class UpdateOrderByUser(generics.UpdateAPIView):
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('orderDate', openapi.IN_QUERY,
                              description="Filter by Date", type=openapi.TYPE_STRING),
        ],
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'orderCode': openapi.Schema(type=openapi.TYPE_STRING, description='Order Code'),
                'value': openapi.Schema(type=openapi.TYPE_STRING, description='Order Food'),
                'note': openapi.Schema(type=openapi.TYPE_STRING, description='Order Note'),
                'quantity': openapi.Schema(type=openapi.TYPE_INTEGER, description='Quantity'),
            }
        ),
        operation_summary="Update order by User"
    )
    def post(self, request, username):
        orderDate = self.request.query_params.get('orderDate', None)
        serializer = UpdateOrderByUserSerializer(data=request.data)

        if (serializer.is_valid()):
            data = update_order_byUser(
                orderDate, username, serializer.validated_data['orderCode'],
                serializer.validated_data['value'], serializer.validated_data['note'],
                serializer.validated_data['quantity'], False)
            # Return the validated data
            return Response(data, content_type='application/json; charset=utf-8')
        return Response(None)


@permission_classes([AllowAny])
class ListMember(generics.ListAPIView):
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('orderDate', openapi.IN_QUERY,
                              description="Filter by Date", type=openapi.TYPE_STRING),
        ],
        operation_summary="List members"
    )
    def get(self, request):
        orderDate = self.request.query_params.get('orderDate', None)
        data = get_members(orderDate)

        # Return the validated data
        return Response(data, content_type='application/json; charset=utf-8')


@permission_classes([AllowAny])
class initiate_oauth(generics.RetrieveAPIView):
    @swagger_auto_schema(
        operation_summary="GS - Init Auth"
    )
    def get(self, request):
        # Create flow instance to manage the OAuth 2.0 Authorization Grant Flow steps.
        flow = Flow.from_client_secrets_file(
            'credentials.json',
            scopes=['https://www.googleapis.com/auth/spreadsheets'],
            redirect_uri='http://localhost:8989/api/gs/oauth-callback'
        )
        authorization_url, state = flow.authorization_url(
            # access_type='offline',
            # include_granted_scopes='true'
        )
        request.session['state'] = state
        return Response(authorization_url)


@permission_classes([AllowAny])
class oauth_callback(generics.RetrieveAPIView):
    @swagger_auto_schema(
        operation_summary="GS - Oauth Callback after Allow"
    )
    def get(self, request):
        state = request.session['state']
        flow = Flow.from_client_secrets_file(
            'credentials.json',
            scopes=['https://www.googleapis.com/auth/spreadsheets'],
            state=state,
            redirect_uri='http://localhost:8989/api/gs/oauth-callback'
        )
        flow.fetch_token(authorization_response=request.build_absolute_uri())
        credentials = flow.credentials

        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(credentials.to_json())

        return Response(
            "Authorization successful. You can now use the Google Sheets API.")
