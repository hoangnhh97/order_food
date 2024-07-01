from django.urls import path

from .reauthorize import ReauthorizeView
from .views import ListData, ListMember, UpdateOrderByUser, initiate_oauth, oauth_callback

urlpatterns = [
    path('gs/', ListData.as_view(), name='google_sheet_data'),
    path('gs/initiate-oauth/', initiate_oauth.as_view(), name='initiate_oauth'),
    path('gs/oauth-callback/', oauth_callback.as_view(), name='oauth_callback'),
    path('gs/members/', ListMember.as_view(), name='oauth_callback'),
    path('gs/update-order/<str:username>/',
         UpdateOrderByUser.as_view(), name='update_order_by_user'),
]
