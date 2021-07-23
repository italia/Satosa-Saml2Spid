import base64
import logging
import saml2

from django.conf import settings
from django.contrib.auth.models import User
from django.dispatch import receiver
from django.http import HttpResponse
from django.shortcuts import render
from django.template import TemplateDoesNotExist
from djangosaml2.conf import get_config
from djangosaml2.cache import IdentityCache, OutstandingQueriesCache
from djangosaml2.cache import StateCache
from djangosaml2.conf import get_config
from djangosaml2.overrides import Saml2Client
from djangosaml2.signals import post_authenticated, pre_user_save
from djangosaml2.utils import (
    available_idps, get_custom_setting,
    get_idp_sso_supported_bindings, get_location
)
from saml2 import BINDING_HTTP_REDIRECT, BINDING_HTTP_POST
from saml2.authn_context import requested_authn_context
from saml2.metadata import entity_descriptor

from .utils import repr_saml


logger = logging.getLogger('djangosaml2')


def index(request):
    """ Barebone 'diagnostics' view, print user attributes if logged in + login/logout links.
    """
    if request.user.is_authenticated:
        out = "LOGGED IN: <a href={0}>LOGOUT</a><br>".format(settings.LOGOUT_URL)
        out += "".join(['%s: %s</br>' % (field.name, getattr(request.user, field.name))
                    for field in request.user._meta.get_fields()
                    if field.concrete])
        return HttpResponse(out)
    else:
        return HttpResponse("LOGGED OUT: <a href={0}>LOGIN</a>".format(settings.LOGIN_URL))


# TODO fix this in IdP side?
@receiver(pre_user_save, sender=User)
def custom_update_user(sender, instance, attributes, user_modified, **kargs):
    """ Default behaviour does not play nice with booleans encoded in SAML as u'true'/u'false'.
        This will convert those attributes to real booleans when saving.
    """
    for k, v in attributes.items():
        u = set.intersection(set(v), set([u'true', u'false']))
        if u:
            setattr(instance, k, u.pop() == u'true')
    return True  # I modified the user object
