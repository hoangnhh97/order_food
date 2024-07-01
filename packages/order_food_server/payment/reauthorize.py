from http.client import HTTPResponse
import os
from django.http import HttpResponseRedirect
from django.views import View
from google_auth_oauthlib.flow import InstalledAppFlow
from .google_sheets import SCOPES


class ReauthorizeView(View):
    def get(self, request):
        flow = InstalledAppFlow.from_client_secrets_file(
            'credentials.json', SCOPES)
        flow.run_local_server(port=8989, redirect_uri_trailing_slash=False)
        creds = flow.credentials
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
        return HTTPResponse('/')
