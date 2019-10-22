import datetime
import pytz
import inspect
import os
import time

from saml2 import samlp
from saml2.time_util import str_to_time

# to load state from a cookie
# from satosa.base import SATOSABase
# from satosa.wsgi import satosa_config
# sb = SATOSABase(satosa_config)
# sb._load_state(context)


class Saml2ResponseValidator(object):

    def __init__(self, authn_response='', issuer='',
                 nameid_formats=['urn:oasis:names:tc:SAML:2.0:nameid-format:transient'],
                 recipient='spidSaml2/acs/post'):
        self.response = samlp.response_from_string(authn_response)
        self.nameid_formats = nameid_formats
        self.recipient = recipient

    def validate_issuer(self):
        """spid saml check 30, 70, 71, 72
        <saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://localhost:8080</saml:Issuer>
        """
        # 30
        # check that this issuer is in the metadata...
        #assert self.response.issuer.text

        # 70
        assert hasattr(self.response.issuer, 'format')
        # 71
        assert getattr(self.response.issuer, 'format', None)
        # 72


    def validate_assertion_version(self):
        """ spid saml check 35
        """
        for i in self.response.assertion:
            if i.version != '2.0':
                msg = 'validate_assertion_version failed on: "{}"'
                raise Exception(msg.format(i.version))

    def validate_issueinstant(self):
        """ spid saml check 39, 40
        """
        issueinstant_time_struct = str_to_time(self.response.issue_instant)
        issueinstant_naive = datetime.datetime.fromtimestamp(time.mktime(issueinstant_time_struct))

        issuerinstant_aware = pytz.utc.localize(issueinstant_naive)
        # TODO validare basandoci sul time slack
        #assert ''

    def validate_name_qualifier(self):
        """ spid saml check 43, 45, 46, 47, 48, 49
        """
        for i in self.response.assertion:
            if not hasattr(i.subject.name_id, 'name_qualifier') or \
               not i.subject.name_id.name_qualifier:
                raise Exception('Not a valid subject.name_id.name_qualifier')
            if not i.subject.name_id.format:
                raise Exception('Not a valid subject.name_id.format')
            if i.subject.name_id.format not in self.nameid_formats:
                msg = 'Not a valid subject.name_id.format: {}'
                raise Exception(msg.format(i.subject.name_id.format))

    def validate_subject_confirmation_data(self):
        """ spid saml check 59, 61, 62, 63, 64

            saml_response.assertion[0].subject.subject_confirmation[0].subject_confirmation_data.__dict__
        """
        for i in self.response.assertion:
            for subject_confirmation in i.subject.subject_confirmation:
                # 61
                if not hasattr(subject_confirmation, 'subject_confirmation_data') or \
                     not getattr(subject_confirmation, 'subject_confirmation_data', None):
                    msg = 'subject_confirmation_data not present'
                    raise Exception(msg)

                # 50
                if self.recipient not in subject_confirmation.subject_confirmation_data.recipient:
                    msg = 'subject_confirmation_data.recipient not valid: {}'
                    raise Exception(msg.format(subject_confirmation_data.recipient))

                # 63 ,64
                if not hasattr(subject_confirmation.subject_confirmation_data, 'not_on_or_after') or \
                     not getattr(subject_confirmation.subject_confirmation_data, 'not_on_or_after', None):
                    raise Exception('subject.subject_confirmation_data not_on_or_after not valid')

                if not hasattr(subject_confirmation.subject_confirmation_data, 'in_response_to') or \
                     not getattr(subject_confirmation.subject_confirmation_data, 'in_response_to', None):
                    raise Exception('subject.subject_confirmation_data in response to no valid')

                # 62 TODO
                # elif subject.subject_confirmation_data.in_response_to


    def validate_assertion_conditions(self):
        """ spid saml check 73, 74, 75, 76, 79, 80, 84, 85

            saml_response.assertion[0].conditions
        """
        for i in self.response.assertion:
            if i.conditions:
                pass

            # 84
            if not hasattr(i.conditions, 'audience_restriction'):
                raise ('Assertion conditions without audience_restriction')

            # 85
            for aud in i.conditions.audience_restriction:
                if not getattr(aud, 'audience', None):
                    raise (('Assertion conditions audience_restriction '
                            'without audience'))

    def validate_assertion_authn_statement(self):
        """ spid saml check 90, 92, 97, 98
        """
        for i in self.response.assertion:
            # 92, 93
            if not hasattr(i, 'authn_statement') or \
               not getattr(i, 'authn_statement', None):
                raise ('Assertion authn_statement is missing/invalid')

            # 97, 98
            for authn_statement in i.authn_statement:
                if not hasattr(authn_statement, 'authn_context') or \
                   not getattr(authn_statement, 'authn_context', None):
                    raise Exception(('Assertion authn_statement.authn_context is '
                                     'missing/invalid'))

    def run(self, tests=[]):
        """ run all tests/methods
        """
        if not tests:
            tests = [i[0] for i in inspect.getmembers(self, predicate=inspect.ismethod) if not i[0].startswith('_')]
            tests.remove('run')

        for element in tests:
            getattr(self, element)()
