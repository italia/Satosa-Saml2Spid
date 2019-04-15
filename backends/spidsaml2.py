import logging
import saml2

from satosa.backends.saml2 import SAMLBackend
from satosa.logging_util import satosa_logging
from saml2 import BINDING_HTTP_REDIRECT, BINDING_HTTP_POST
from saml2.authn_context import requested_authn_context
from saml2.metadata import entity_descriptor
from six import text_type


logger = logging.getLogger(__name__)


class SpidSAMLBackend(SAMLBackend):
    """
    A saml2 backend module (acting as a SPID SP).
    """


    def _metadata_endpoint(self, context):
        """
        Endpoint for retrieving the backend metadata
        :type context: satosa.context.Context
        :rtype: satosa.response.Response

        :param context: The current context
        :return: response with metadata
        """
        satosa_logging(logger, logging.DEBUG, "Sending metadata response", context.state)

        conf = self.sp.config
        metadata = entity_descriptor(conf)
        import pdb; pdb.set_trace()

        # creare gli attribute_consuming_service
        cnt = 0
        for attribute_consuming_service in metadata.spsso_descriptor.attribute_consuming_service:
            attribute_consuming_service.index = str(cnt)
            cnt += 1

        cnt = 0
        for assertion_consumer_service in metadata.spsso_descriptor.assertion_consumer_service:
            assertion_consumer_service.is_default = 'true' if not cnt else ''
            assertion_consumer_service.index = str(cnt)
            cnt += 1

        # nameformat patch... tutto questo non rispecchia gli standard OASIS
        for reqattr in metadata.spsso_descriptor.attribute_consuming_service[0].requested_attribute:
            reqattr.name_format = None
            reqattr.friendly_name = None

        # remove unecessary encryption and digest algs
        supported_algs = ['http://www.w3.org/2009/xmldsig11#dsa-sha256',
                          'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256']
        new_list = []
        for alg in metadata.extensions.extension_elements:
            # if alg.namespace != 'urn:oasis:names:tc:SAML:metadata:algsupport': continue
            if alg.attributes.get('Algorithm') in supported_algs:
                new_list.append(alg)
        metadata.extensions.extension_elements = new_list
        # ... Piuttosto non devo specificare gli algoritmi di firma/criptazione...
        metadata.extensions = None

        # attribute consuming service service name patch
        service_name = metadata.spsso_descriptor.attribute_consuming_service[0].service_name[0]
        service_name.lang = 'it'
        service_name.text = conf._sp_name

        return Response(text_type(metadata).encode('utf-8'),
                        content_type="text/xml; charset=utf8")


    def get_kwargs_sign_dig_algs(self):
        kwargs = {}
        # backend support for selectable sign/digest algs
        for alg in ('sign_alg', 'digest_alg'):
            selected_alg = self.config['sp_config']['service']['sp'].get(alg)
            if not selected_alg: continue
            kwargs[alg] = getattr(saml2.xmldsig,
                                  util.xmldsig_validate_w3c_format(selected_alg))
        return kwargs


    def check_blacklist(self):
        # If IDP blacklisting is enabled and the selected IDP is blacklisted,
        # stop here
        if self.idp_blacklist_file:
            with open(self.idp_blacklist_file) as blacklist_file:
                blacklist_array = json.load(blacklist_file)['blacklist']
                if entity_id in blacklist_array:
                    satosa_logging(logger, logging.DEBUG, "IdP with EntityID {} is blacklisted".format(entity_id), context.state, exc_info=False)
                    raise SATOSAAuthenticationError(context.state, "Selected IdP is blacklisted for this backend")


    def authn_request(self, context, entity_id):
        """
        Do an authorization request on idp with given entity id.
        This is the start of the authorization.

        :type context: satosa.context.Context
        :type entity_id: str
        :rtype: satosa.response.Response

        :param context: The current context
        :param entity_id: Target IDP entity id
        :return: response to the user agent
        """
        self.check_blacklist()

        kwargs = {}
        # fetch additional kwargs
        kwargs.update(self.get_kwargs_sign_dig_algs())

        authn_context = self.construct_requested_authn_context(entity_id)
        if authn_context:
            kwargs['requested_authn_context'] = authn_context

        try:
            binding, destination = self.sp.pick_binding(
                "single_sign_on_service", None, "idpsso", entity_id=entity_id)

            satosa_logging(logger, logging.DEBUG, "binding: %s, destination: %s" % (binding, destination),
                           context.state)

            acs_endp, response_binding = self.sp.config.getattr("endpoints", "sp")["assertion_consumer_service"][0]

            req_id, req = self.sp.create_authn_request(
                destination, binding=response_binding, **kwargs)

            relay_state = util.rndstr()
            ht_args = self.sp.apply_binding(binding, "%s" % req, destination, relay_state=relay_state)
            satosa_logging(logger, logging.DEBUG, "ht_args: %s" % ht_args, context.state)

        except Exception as exc:
            satosa_logging(logger, logging.DEBUG, "Failed to construct the AuthnRequest for state", context.state,
                           exc_info=True)
            raise SATOSAAuthenticationError(context.state, "Failed to construct the AuthnRequest") from exc

        if self.sp.config.getattr('allow_unsolicited', 'sp') is False:
            if req_id in self.outstanding_queries:
                errmsg = "Request with duplicate id {}".format(req_id)
                satosa_logging(logger, logging.DEBUG, errmsg, context.state)
                raise SATOSAAuthenticationError(context.state, errmsg)
            self.outstanding_queries[req_id] = req

        context.state[self.name] = {"relay_state": relay_state}
        return make_saml_response(binding, ht_args)
