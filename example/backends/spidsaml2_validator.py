import datetime
import pytz
import inspect
import os
import time

from saml2 import samlp
#from saml2.time_util import str_to_time

# to load state from a cookie
# from satosa.base import SATOSABase
# from satosa.wsgi import satosa_config
# sb = SATOSABase(satosa_config)
# sb._load_state(context)


class Saml2ResponseValidator(object):

    def __init__(self, authn_response='', issuer='',
                 nameid_formats=['urn:oasis:names:tc:SAML:2.0:nameid-format:transient'],
                 recipient='spidSaml2/acs/post',
                 accepted_time_diff=1,
                 in_response_to='',
                 requester='',
                 authn_context_class_ref='https://www.spid.gov.it/SpidL2'):

        self.response = samlp.response_from_string(authn_response)
        self.nameid_formats = nameid_formats
        self.recipient = recipient
        self.accepted_time_diff = accepted_time_diff
        self.authn_context_class_ref = authn_context_class_ref
        self.in_response_to = in_response_to
        self.requester = requester

    # def validate_in_response_to(self):
        # """ spid test 18
            # inutile se disabiliti gli unsolicited
        # """
        # if self.in_response_to != self.response.in_response_to:
            # raise Exception('In response To not valid: {}'.format(self.response.in_response_to))

    def validate_issuer(self):
        """spid saml check 30, 70, 71, 72
        <saml:Issuer Format="urn:oasis:names:tc:SAML:2.0:nameid-format:entity">http://localhost:8080</saml:Issuer>
        """
        # 30
        # check that this issuer is in the metadata...
        # oppure passare context.state['Saml2IDP']['resp_args']['sp_entity_id']
        # if self.requester != self.response.issuer.text:
            # raise Exception('Issuer different {}'.format(self.response.issuer.text))

        msg = 'Issuer format is not valid: {}'
        # 70, 71
        if not hasattr(self.response.issuer, 'format') or \
           not getattr(self.response.issuer, 'format', None):
            raise Exception(msg.format(self.response.issuer.format))

        # 72
        for i in self.response.assertion:
            if i.issuer.format != "urn:oasis:names:tc:SAML:2.0:nameid-format:entity":
               raise Exception(msg.format(self.response.issuer.format))


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
        # Spid dt standard format
        for i in self.response.assertion:
            issueinstant_naive = datetime.datetime.strptime(i.issue_instant,
                                                            '%Y-%m-%dT%H:%M:%SZ')
            issuerinstant_aware = pytz.utc.localize(issueinstant_naive)
            now = pytz.utc.localize(datetime.datetime.utcnow())

            if now < issuerinstant_aware:
                seconds = (issuerinstant_aware - now).seconds
            else:
                seconds = (now - issuerinstant_aware).seconds

            if seconds > self.accepted_time_diff:
                msg = "Not a valid issue_instant: {}"
                raise Exception(msg.format(self.response.issue_instant))

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

                # 60
                if not subject_confirmation.subject_confirmation_data.in_response_to:
                    raise Exception('subject.subject_confirmation_data in response -> null data')

                # 62 avoided with allow_unsolicited set to false (XML parse error: Unsolicited response: id-OsoMQGYzX4HGLsfL7)
                # if subject.subject_confirmation_data.in_response_to != self.in_response_to:
                    # raise Exception('subject.subject_confirmation_data in response to not valid')

                # 50
                if self.recipient != subject_confirmation.subject_confirmation_data.recipient:
                    msg = 'subject_confirmation_data.recipient not valid: {}'
                    raise Exception(msg.format(subject_confirmation_data.recipient))

                # 63 ,64
                if not hasattr(subject_confirmation.subject_confirmation_data, 'not_on_or_after') or \
                     not getattr(subject_confirmation.subject_confirmation_data, 'not_on_or_after', None):
                    raise Exception('subject.subject_confirmation_data not_on_or_after not valid')

                if not hasattr(subject_confirmation.subject_confirmation_data, 'in_response_to') or \
                     not getattr(subject_confirmation.subject_confirmation_data, 'in_response_to', None):
                    raise Exception('subject.subject_confirmation_data in response to not valid')


    def validate_assertion_conditions(self):
        """ spid saml check 73, 74, 75, 76, 79, 80, 84, 85

            saml_response.assertion[0].conditions
        """
        for i in self.response.assertion:
            # 73, 74
            if not hasattr(i, 'conditions') or \
               not getattr(i, 'conditions', None):
               # or not i.conditions.text.strip(' ').strip('\n'):
                raise Exception('Assertion conditions not present')

            # 75, 76
            if not hasattr(i.conditions, 'not_before') or \
               not getattr(i.conditions, 'not_before', None):
               # or not i.conditions.text.strip(' ').strip('\n'):
                raise Exception('Assertion conditions not_before not valid')


            # 79, 80
            if not hasattr(i.conditions, 'not_on_or_after') or \
               not getattr(i.conditions, 'not_on_or_after', None):
               # or not i.conditions.text.strip(' ').strip('\n'):
                raise Exception('Assertion conditions not_on_or_after not valid')

            # 84
            if not hasattr(i.conditions, 'audience_restriction') or \
               not getattr(i.conditions, 'audience_restriction', None):
                raise Exception('Assertion conditions without audience_restriction')

            # 85
            # already filtered by pysaml2: AttributeError: 'NoneType' object has no attribute 'strip'
            for aud in i.conditions.audience_restriction:
                if not getattr(aud, 'audience', None):
                    raise Exception(('Assertion conditions audience_restriction '
                                     'without audience'))
                if not aud.audience[0].text:
                    raise Exception(('Assertion conditions audience_restriction '
                                     'without audience'))

    def validate_assertion_authn_statement(self):
        """ spid saml check 90, 92, 97, 98
        """
        for i in self.response.assertion:
            if not hasattr(i, 'authn_statement') or \
               not getattr(i, 'authn_statement', None):
                raise ('Assertion authn_statement is missing/invalid')

            # 90, 92, 93
            for authns in i.authn_statement:
                if not hasattr(authns, 'authn_context') or \
                   not getattr(authns, 'authn_context', None) or \
                   not hasattr(authns.authn_context, 'authn_context_class_ref') or \
                   not getattr(authns.authn_context, 'authn_context_class_ref', None):
                    raise Exception('Assertion authn_statement.authn_context_class_ref is missing/invalid')

                # 97
                if authns.authn_context.authn_context_class_ref.text != self.authn_context_class_ref:
                    raise Exception(('Assertion '
                                     'authn_statement.authn_context.authn_context_class_ref is '
                                     'missing/invalid'))
                # 98
                if not hasattr(i, 'attribute_statement') or \
                   not getattr(i, 'attribute_statement', None):
                    raise Exception('Assertion attribute_statement is missing/invalid')

                for attri in i.attribute_statement:
                    if not attri.attribute:
                        raise Exception('Assertion attribute_statement.attribute is missing/invalid')

    def run(self, tests=[]):
        """ run all tests/methods
        """
        if not tests:
            tests = [i[0] for i in inspect.getmembers(self, predicate=inspect.ismethod) if not i[0].startswith('_')]
            tests.remove('run')

        for element in tests:
            getattr(self, element)()
