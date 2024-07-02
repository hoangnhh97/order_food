from ast import List
import json
import os

from django.http import HttpResponseRedirect
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# If modifying these SCOPES, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets']


def authenticate_google_sheets():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is created automatically when the authorization flow completes for the first time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)

    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            return HttpResponseRedirect('/api/gs/initiate-oauth/')
    return creds


def updatePaymentStatus(dateTime, orderCode):
    creds = authenticate_google_sheets()
    # The ID and range of the spreadsheet.
    SAMPLE_SPREADSHEET_ID = '1s0rVZKXEpDZ9alcEoOnQKWW0_xgTcKHa6Gp0EIzJcew'
    SAMPLE_RANGE_NAME = str(dateTime) + '!G3:O30'

    service = build('sheets', 'v4', credentials=creds)

    # Call the Sheets API
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                range=SAMPLE_RANGE_NAME).execute()

    values = result.get('values', [])
    # Check if username exists and update quantity
    for row in values:
        if len(row[0]) > 0 and row[1] == orderCode:
            row[5] = True
            try:
                if isinstance(row[2], str) and len(row[2]) > 0:
                    row[2] = int(row[2])
            except ValueError:
                row[2] = row[2]  # Default to 0 if conversion fails
            break
        row[2] = int(row[2])

    # Append new row
    # values.append([orderUser, orderCode, quantity, orderFood, isPaid])

    # Update the sheet with new data
    body = {'values': values}
    sheet.values().update(spreadsheetId=SAMPLE_SPREADSHEET_ID, range=SAMPLE_RANGE_NAME,
                          valueInputOption="RAW", body=body).execute()

    return True


def update_order(dateTime, orderUser):
    creds = authenticate_google_sheets()
    # The ID and range of the spreadsheet.
    SAMPLE_SPREADSHEET_ID = '1s0rVZKXEpDZ9alcEoOnQKWW0_xgTcKHa6Gp0EIzJcew'
    SAMPLE_RANGE_NAME = str(dateTime) + '!A3:D13'

    service = build('sheets', 'v4', credentials=creds)

    # Call the Sheets API
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                range=SAMPLE_RANGE_NAME).execute()
    values = result.get('values', [])
    # Transform the data into a list of dictionaries

    data = []
    for value in values[0:]:  # Skipping header row
        if value and len(value) > 0 and len(value[1]) > 0:
            data.append({
                'name': value[0],
                'value': value[1],
                'quantity': value[2],
                'unitPrice': value[3]
            })
    print(values, data)

    return data


def updateOrderByUser(dateTime, orderUser, orderCode, orderFood, note, quantity, isPaid):
    creds = authenticate_google_sheets()
    # The ID and range of the spreadsheet.
    SAMPLE_SPREADSHEET_ID = '1s0rVZKXEpDZ9alcEoOnQKWW0_xgTcKHa6Gp0EIzJcew'
    SAMPLE_RANGE_NAME = str(dateTime) + '!G3:O30'

    service = build('sheets', 'v4', credentials=creds)

    # Call the Sheets API
    sheet = service.spreadsheets()
    result = sheet.values().get(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                range=SAMPLE_RANGE_NAME).execute()

    values = result.get('values', [])
    # Check if username exists and update quantity
    for row in values:
        if len(row[0]) == 0:
            row[0] = orderUser
            row[1] = orderCode
            try:
                if isinstance(row[2], str):
                    row[2] = int(row[2])
            except ValueError:
                row[2] = quantity  # Default to 0 if conversion fails
            row[3] = orderFood
            row[4] = note
            row[5] = isPaid
            break
        row[2] = int(row[2])

    # Append new row
    # values.append([orderUser, orderCode, quantity, orderFood, isPaid])

    # Update the sheet with new data
    body = {'values': values}
    sheet.values().update(spreadsheetId=SAMPLE_SPREADSHEET_ID, range=SAMPLE_RANGE_NAME,
                          valueInputOption="RAW", body=body).execute()

    return True
