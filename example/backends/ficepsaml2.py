import json
import logging
import re
import saml2
import satosa.util as util

from backends.spidsaml2 import *
from jinja2 import Environment, FileSystemLoader, select_autoescape
from saml2.response import StatusAuthnFailed
from saml2.authn_context import requested_authn_context
from saml2.metadata import entity_descriptor, sign_entity_descriptor
from saml2.saml import NAMEID_FORMAT_TRANSIENT
from saml2.sigver import security_context, SignatureError
from saml2.validate import valid_instance
from satosa.backends.saml2 import SAMLBackend
from satosa.context import Context
from satosa.exception import SATOSAAuthenticationError
from satosa.response import Response
from satosa.saml_util import make_saml_response
from six import text_type

from .spidsaml2_validator import Saml2ResponseValidator

logger = logging.getLogger(__name__)

class FicepSAMLBackend(SpidSAMLBackend):
    """
    A saml2 backend module (acting as a FICEP SP).
    """

    _authn_context = "https://www.spid.gov.it/SpidL1"

    def _metadata_endpoint(self, context):
        """
        Endpoint for retrieving the backend metadata
        :type context: satosa.context.Context
        :rtype: satosa.response.Response

        :param context: The current context
        :return: response with metadata
        """
        logger.debug("Sending metadata response")
        conf = self.sp.config


        metadata = entity_descriptor(conf)
        # creare gli attribute_consuming_service
        metadata.spsso_descriptor.attribute_consuming_service[0].index = 99
        metadata.spsso_descriptor.attribute_consumer_service[0].is_default = "true"
        metadata.spsso_descriptor.attribute_consuming_service[0].requested_attribute = []
        breakpoint()
        metadata.spsso_descriptor.attribute_consuming_service[1].index = 100

 

        # nameformat patch... tutto questo non rispecchia gli standard OASIS
        for reqattr in metadata.spsso_descriptor.attribute_consuming_service[
            0
        ].requested_attribute:
            reqattr.name_format = None
            reqattr.friendly_name = None

        # attribute consuming service service name patch
        service_name = metadata.spsso_descriptor.attribute_consuming_service[
            0
        ].service_name[0]
        service_name.lang = "it"
        service_name.text = "eIDAS Natural Person Minimum Attribute Set"

        # remove extension disco and uuinfo (spid-testenv2)
        # metadata.spsso_descriptor.extensions = []

        # load ContactPerson Extensions
        self._metadata_contact_person(metadata, conf)

        # metadata signature
        secc = security_context(conf)
        #
        sign_dig_algs = self.get_kwargs_sign_dig_algs()
        eid, xmldoc = sign_entity_descriptor(
            metadata, None, secc, **sign_dig_algs)

        valid_instance(eid)
        return Response(
            text_type(xmldoc).encode("utf-8"), content="text/xml; charset=utf8"
        )

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
        self.check_blacklist(context, entity_id)

        kwargs = {}
        # fetch additional kwargs
        kwargs.update(self.get_kwargs_sign_dig_algs())

        authn_context = self.construct_requested_authn_context(entity_id)
        req_authn_context = authn_context or requested_authn_context(
            class_ref=self._authn_context
        )
        req_authn_context.comparison = self.config.get("spid_acr_comparison", "minimum")

        # force_auth = true only if SpidL >= 2
        if "SpidL1" in authn_context.authn_context_class_ref[0].text:
            force_authn = "false"
        else:
            force_authn = "true"

        try:
            binding = saml2.BINDING_HTTP_POST
            destination = context.internal_data.get("target_entity_id", entity_id)
            # SPID CUSTOMIZATION
            # client = saml2.client.Saml2Client(conf)
            client = self.sp

            logger.debug(f"binding: {binding}, destination: {destination}")

            # acs_endp, response_binding = self.sp.config.getattr("endpoints", "sp")["assertion_consumer_service"][0]
            # req_id, req = self.sp.create_authn_request(
            # destination, binding=response_binding, **kwargs)

            logger.debug(f"Redirecting user to the IdP via {binding} binding.")
            # use the html provided by pysaml2 if no template was specified or it didn't exist

            # SPID want the fqdn of the IDP as entityID, not the SSO endpoint
            # 'http://idpspid.testunical.it:8088'
            # dovrebbe essere destination ma nel caso di spid-testenv2 è entityid...
            # binding, destination = self.sp.pick_binding("single_sign_on_service", None, "idpsso", entity_id=entity_id)
            location = client.sso_location(destination, binding)
            # location = client.sso_location(entity_id, binding)

            # not used anymore thanks to avviso 11
            # location_fixed = destination  # entity_id
            # ...hope to see the SSO endpoint soon in spid-testenv2
            # returns 'http://idpspid.testunical.it:8088/sso'
            # fixed: https://github.com/italia/spid-testenv2/commit/6041b986ec87ab8515dd0d43fed3619ab4eebbe9

            # verificare qui
            # acs_endp, response_binding = self.sp.config.getattr("endpoints", "sp")["assertion_consumer_service"][0]

            authn_req = saml2.samlp.AuthnRequest()
            authn_req.force_authn = force_authn
            authn_req.destination = location
            # spid-testenv2 preleva l'attribute consumer service dalla authnRequest
            # (anche se questo sta già nei metadati...)
            authn_req.attribute_consuming_service_index = "0"

            issuer = saml2.saml.Issuer()
            issuer.name_qualifier = client.config.entityid
            issuer.text = client.config.entityid
            issuer.format = "urn:oasis:names:tc:SAML:2.0:nameid-format:entity"
            authn_req.issuer = issuer

            # message id
            authn_req.id = saml2.s_utils.sid()
            authn_req.version = saml2.VERSION  # "2.0"
            authn_req.issue_instant = saml2.time_util.instant()

            name_id_policy = saml2.samlp.NameIDPolicy()
            # del(name_id_policy.allow_create)
            name_id_policy.format = NAMEID_FORMAT_TRANSIENT
            authn_req.name_id_policy = name_id_policy

            # TODO: use a parameter instead
            authn_req.requested_authn_context = req_authn_context
            authn_req.protocol_binding = binding

            assertion_consumer_service_url = client.config._sp_endpoints[
                "assertion_consumer_service"
            ][0][0]
            authn_req.assertion_consumer_service_url = (
                assertion_consumer_service_url  # 'http://sp-fqdn/saml2/acs/'
            )

            authn_req_signed = client.sign(
                authn_req,
                sign_prepare=False,
                sign_alg=kwargs["sign_alg"],
                digest_alg=kwargs["digest_alg"],
            )
            authn_req.id

            _req_str = authn_req_signed
            logger.debug(f"AuthRequest to {destination}: {_req_str}")

            relay_state = util.rndstr()
            ht_args = client.apply_binding(
                binding,
                _req_str,
                location,
                sign=True,
                sigalg=kwargs["sign_alg"],
                relay_state=relay_state,
            )

            if self.sp.config.getattr("allow_unsolicited", "sp") is False:
                if authn_req.id in self.outstanding_queries:
                    errmsg = "Request with duplicate id {}".format(
                        authn_req.id)
                    logger.debug(errmsg)
                    raise SATOSAAuthenticationError(context.state, errmsg)
                self.outstanding_queries[authn_req.id] = authn_req_signed

            context.state[self.name] = {"relay_state": relay_state}
            # these will give the way to check compliances between the req and resp
            context.state["req_args"] = {"id": authn_req.id}

            logger.info(f"SAMLRequest: {ht_args}")
            return make_saml_response(binding, ht_args)

        except Exception as exc:
            logger.debug("Failed to construct the AuthnRequest for state")
            raise SATOSAAuthenticationError(
                context.state, "Failed to construct the AuthnRequest"
            ) from exc

    def authn_response(self, context, binding):
        """
        Endpoint for the idp response
        :type context: satosa.context,Context
        :type binding: str
        :rtype: satosa.response.Response

        :param context: The current context
        :param binding: The saml binding type
        :return: response
        """
        if not context.request["SAMLResponse"]:
            logger.debug("Missing Response for state")
            raise SATOSAAuthenticationError(context.state, "Missing Response")

        try:
            authn_response = self.sp.parse_authn_request_response(
                context.request["SAMLResponse"],
                binding,
                outstanding=self.outstanding_queries,
            )
        except StatusAuthnFailed as err:
            erdict = re.search(r"ErrorCode nr(?P<err_code>\d+)", str(err))
            if erdict:
                return self.handle_spid_anomaly(erdict.groupdict()["err_code"], err)
            else:
                return self.handle_error(
                    **{
                        "err": err,
                        "message": "Autenticazione fallita",
                        "troubleshoot": (
                            "Anomalia riscontrata durante la fase di Autenticazione. "
                            f"{_TROUBLESHOOT_MSG}"
                        ),
                    }
                )
        except SignatureError as err:
            return self.handle_error(
                **{
                    "err": err,
                    "message": "Autenticazione fallita",
                    "troubleshoot": (
                        "La firma digitale della risposta ottenuta "
                        f"non risulta essere corretta. {_TROUBLESHOOT_MSG}"
                    ),
                }
            )
        except Exception as err:
            return self.handle_error(
                **{
                    "err": err,
                    "message": "Anomalia riscontrata nel processo di Autenticazione",
                    "troubleshoot": _TROUBLESHOOT_MSG,
                }
            )

        if self.sp.config.getattr("allow_unsolicited", "sp") is False:
            req_id = authn_response.in_response_to
            if req_id not in self.outstanding_queries:
                errmsg = ("No request with id: {}".format(req_id),)
                logger.debug(errmsg)
                return self.handle_error(
                    **{"message": errmsg, "troubleshoot": _TROUBLESHOOT_MSG}
                )
            del self.outstanding_queries[req_id]

        # Context validation
        if not context.state.get(self.name):
            _msg = f"context.state[self.name] KeyError: where self.name is {self.name}"
            logger.error(_msg)
            return self.handle_error(
                **{"message": _msg, "troubleshoot": _TROUBLESHOOT_MSG}
            )
        # check if the relay_state matches the cookie state
        if context.state[self.name]["relay_state"] != context.request["RelayState"]:
            _msg = "State did not match relay state for state"
            return self.handle_error(
                **{"message": _msg, "troubleshoot": _TROUBLESHOOT_MSG}
            )

        # Spid and SAML2 additional tests
        _sp_config = self.config["sp_config"]
        accepted_time_diff = _sp_config["accepted_time_diff"]
        recipient = _sp_config["service"]["sp"]["endpoints"][
            "assertion_consumer_service"
        ][0][0]
        authn_context_classref = self.config["acr_mapping"][""]

        issuer = authn_response.response.issuer

        # this will get the entity name in state
        if len(context.state.keys()) < 2:
            _msg = "Inconsistent context.state"
            return self.handle_error(
                **{"message": _msg, "troubleshoot": _TROUBLESHOOT_MSG}
            )

        list(context.state.keys())[1]
        # deprecated
        # if not context.state.get('Saml2IDP'):
        # _msg = "context.state['Saml2IDP'] KeyError"
        # logger.error(_msg)
        # raise SATOSAStateError(context.state, "State without Saml2IDP")
        in_response_to = context.state["req_args"]["id"]

        # some debug
        if authn_response.ava:
            logging.debug(
                f"Attributes to {authn_response.return_addrs} "
                f"in_response_to {authn_response.in_response_to}: "
                f'{",".join(authn_response.ava.keys())}'
            )

        validator = Saml2ResponseValidator(
            authn_response=authn_response.xmlstr,
            recipient=recipient,
            in_response_to=in_response_to,
            accepted_time_diff=accepted_time_diff,
            authn_context_class_ref=authn_context_classref,
            return_addrs=authn_response.return_addrs,
            allowed_acrs=self.config["spid_allowed_acrs"],
        )
        try:
            validator.run()
        except Exception as e:
            logger.error(e)
            return self.handle_error(e)

        context.decorate(Context.KEY_BACKEND_METADATA_STORE, self.sp.metadata)
        if self.config.get(SAMLBackend.KEY_MEMORIZE_IDP):
            issuer = authn_response.response.issuer.text.strip()
            context.state[Context.KEY_MEMORIZED_IDP] = issuer
        context.state.pop(self.name, None)
        context.state.pop(Context.KEY_FORCE_AUTHN, None)

        logger.info(f"SAMLResponse{authn_response.xmlstr}")
        return self.auth_callback_func(
            context, self._translate_response(authn_response, context.state)
        )
