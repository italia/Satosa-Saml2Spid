pyFF
----

## Installation
````
pip install git+https://github.com/IdentityPython/pyFF.git
````

## First run

`examples/` folder taken from git repository.
This command will print in stdout all the log, if you want to put it in a file just add `--log=pyff.log` after `--loglevel`.
It seems that pyff is sensible to arguments order, unfortunately it doesn't use arparse...

````
pyffd -p pyff.pid -f -a --loglevel=DEBUG --dir=`pwd` -H 0.0.0.0 -P 8001 examples/big.fd
````
When it finishes to download all the metadata it will expose a web catalog of them, and also a DiscoveryService.

Useful things that we need to know
1. pyFF uses by default a local sqllite db, automatically created in the working directory

## how does it works
You need also to read:
- https://pythonhosted.org/pyFF/
- https://github.com/IdentityPython/pyFF

pyFF works with configuration files called _pipelines_, it exposes services and all its features depending of what we configure in these _pipelines_ files. The following example is used to download to `./garr` folder all the metadata.

`custom_examples/` contains some of the following examples.

*garr.xrd*
````
<?xml version="1.0"?>
<XRDS xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
  <XRD>
    <Link rel="urn:oasis:names:tc:SAML:2.0:metadata" href="http://md.idem.garr.it/metadata/idem-test-metadata-sha256.xml"/>
  </XRD>
  <XRD>
    <Link rel="urn:oasis:names:tc:SAML:2.0:metadata" href="http://md.idem.garr.it/metadata/idem-metadata-sha256.xml"/>
  </XRD>
</XRDS>
````

*garr.fd*
````
- load xrd ./garr-loaded.xrd:
  - custom_examples/garr.xrd
- select
- store:
     directory: ./garr
- publish:
     output: ./garr-loaded.xml
- stats
````

## Advanced Topics
I think that pyFF would a be a real stop application for the following goals:

1. Downloader, validatore avanzato per federare entità saml2
2. Store su RDBMS interrogabile da remoto
3. Metadata Query Resolver per entità interne alla home organization, in questo caso i nostri IDP non dovrebbero scaricare i metadatati degli SP ma interrogarli da remoto
4. DiscoveryService Integrato

Italian isn't so difficult to be read, isn't it?


## Fancy screenshot (what you will get)
WebPAge during metadata download and validation, this will be also the only thing you will see if metadata could not be imported (404 on their page).

![Home](gallery/service_request.png)
_**Frontend**: Default pyFF landing page
