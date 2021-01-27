SaToSa internals
----------------

Every HttpRequest is parsed by `proxy_Server.unpack_request` in the call()
method of `proxy_Server.WsgiApplication`, a child of base.SATOSABase.
It fills a context object with request arguments like the following:

````
{'_path': 'Saml2/sso/post',
 'cookie': 'SAML2_PROXY_STATE="_Td6WFoAAATm[...]',
 'internal_data': {},
 'request': {'RelayState': '/',
             'SAMLRequest': 'PD94bWw[....]'},
 'request_authorization': '',
 'state': {'_state_dict': {'CONSENT': {'filter': ['surname',
                                        'name',
                                        'schacpersonalpersonprincipalname',
                                        'schacpersonaluniqueid',
                                        'schacpersonaluniquecode',
                                        'mail'],
                             'requester_name': [{'lang': 'en',
                                                 'text': 'http://sp1.testunical.it:8000/saml2/metadata/'}]},
                 'ROUTER': 'Saml2IDP',
                 'SATOSA_BASE': {'requester': 'http://sp1.testunical.it:8000/saml2/metadata/'},
                 'SESSION_ID': 'urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5',
                 'Saml2': {'relay_state': 'NChCi4Ez56y19rci'},
                 'Saml2IDP': {'relay_state': '/',
                              'resp_args': {'binding': 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                                            'destination': 'http://sp1.testunical.it:8000/saml2/acs/',
                                            'in_response_to': 'id-0Q7q6ha9t7VbbxlZ8',
                                            'name_id_policy': '<ns0:NameIDPolicy '
                                                              'xmlns:ns0="urn:oasis:names:tc:SAML:2.0:protocol" '
                                                              'AllowCreate="false" '
                                                              'Format="urn:oasis:names:tc:SAML:2.0:nameid-format:persistent" '
                                                              '/>',
                                            'sp_entity_id': 'http://sp1.testunical.it:8000/saml2/metadata/'}}},
 'delete': False},
 'target_backend': None,
 'target_frontend': None,
 'target_micro_service': None}
````

**Hint: an authnRequest fancy print to stdout as Debug would be better inside run().

the `self.module_router.endpoint_routing(context)` is called in .run() method, returning this call
`functools.partial(<bound method SAMLFrontend.handle_authn_request of <satosa.frontends.saml2.SAMLFrontend object at 0x7ff091d733c8>>, binding_in='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST')`
that make SATOSA find the routing to the its frontend.

````
[2019-04-14 15:42:55] [DEBUG]: [urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5] Routing path: Saml2/sso/post
[2019-04-14 15:42:55] [DEBUG]: [urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5] Found registered endpoint: module name:'Saml2IDP', endpoint: Saml2/sso/post
functools.partial(<bound method SAMLFrontend.handle_authn_request of <satosa.frontends.saml2.SAMLFrontend object at 0x7ff091d733c8>>, binding_in='urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST')
````

next `self._run_bound_endpoint(context, spec)` being called returning a
`satosa.response.SeeOther` object.

````
[2019-04-14 15:45:01] [DEBUG]: [urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5] Filter: ['schacpersonalpersonprincipalname', 'name', 'schacpersonaluniqueid', 'mail', 'schacpersonaluniquecode', 'surname']
[2019-04-14 15:45:01] [INFO ]: [urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5] Requesting provider: http://sp1.testunical.it:8000/saml2/metadata/
[2019-04-14 15:45:01] [DEBUG]: [urn:uuid:3605176c-8079-4a5c-8ac7-8a67377f91a5] Routing to backend: Saml2
````

then `self._save_state(resp, context)` and return `satosa.response.SeeOther` object.

SeeOther object is called when SATOSA redirect user-agents to DiscoFeed service, this object have the following attributes:

````
{'status': '303 See Other',
 'headers': [('Content-Type', 'text/html'),
             ('Location', 'http://sp1.testunical.it:8001/role/idp.ds?entityID=https%3A%2F%2Fsatosa.testunical.it%3A10000%2FSaml2%2Fmetadata&return=https%3A%2F%2Fsatosa.testunical.it%3A10000%2FSaml2%2Fdisco'),
             ('Set-Cookie', 'SAML2_PROXY_STATE=_Td6WF[...]; Max-Age=1200; Path=/; Secure')],
             'message': 'http://sp1.testunical.it:8001/role/idp.ds?entityID=https%3A%2F%2Fsatosa.testunical.it%3A10000%2FSaml2%2Fmetadata&return=https%3A%2F%2Fsatosa.testunical.it%3A10000%2FSaml2%2Fdisco'}
````
SeeOther object is then converted to Bytes as a standard HttpResponse (POST /Saml2/sso/post => generated 178 bytes in 1483 msecs (HTTP/1.1 303)).


_pyFF SCREENSHOT here_
*DiscoveryService the user will select its authentication endpoint.


When the response return with the selected entityID the same previous execution stack
will be called again. Now in context dictionary we found:

````
{'_path': 'Saml2/disco',
 'cookie': 'SAML2_PROXY_STATE="_Td6WFo[...]',
 'internal_data': {},
 'request': {'entityID': 'http://idp1.testunical.it:9000/idp/metadata'},
 'request_authorization': '',
 'state': None,
 'target_backend': None,
 'target_frontend': None,
 'target_micro_service': None}

````

I think that one of the most important and powerfull feature of SATOSA is the MICROSERVICES middlewares.
At this moment of the flow we have the configuration, as a constant, and a `context` with the `entityID`
expliticely defined....

````
{'_config': {'BASE': 'https://satosa.testunical.it:10000',
             'INTERNAL_ATTRIBUTES': {'attributes': {'address': {'openid': ['address.street_address'],
                                                                'orcid': ['addresses.str'],
                                                                'saml': ['postaladdress']},
                                                                'displayname': {'openid': [... ALL YOUR ATTR_MAP...]},
             'COOKIE_STATE_NAME': 'SAML2_PROXY_STATE',
             'STATE_ENCRYPTION_KEY': [...Then all the proxy_conf.yaml definitions, FRONTENDS, BACKENDS, etc...]
             [... then MICROSERVICES configured ...]

             'MICRO_SERVICES': [{'module': 'satosa.micro_services.attribute_modifications.AddStaticAttributes', 'name': 'AddAttributes', 'config': {'static_attributes': {'organisation': 'testunical', 'schachomeorganization': 'testunical.it', 'schachomeorganizationtype': 'urn:schac:homeOrganizationType:eu:higherEducationInstitution', 'organizationname': 'testunical', 'noreduorgacronym': 'EO', 'countryname': 'IT', 'friendlycountryname': 'Italy'}}},

             {'module': 'satosa.micro_services.custom_routing.DecideBackendByTarget', 'name': 'TargetRouter', 'config': {'target_mapping': {'http://idpspid.testunical.it:8088': 'spidSaml2'}}}],

             [..then logging and all the config ...]
             }}}}
````

For example in [this](https://github.com/IdentityPython/SATOSA/pull/220) PR I developed a microservice to intercept incoming request and select a custom Saml2 backend instead of the default one

