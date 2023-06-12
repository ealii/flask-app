#!/bin/bash

# https://spinnaker.io/docs/setup/other_config/security/ssl/

SSL_PATH=`realpath ../.hal/ssl`

CA_KEY_PASSWORD=12345678
DECK_KEY_PASSWORD=12345678
GATE_KEY_PASSWORD=12345678
JKS_PASSWORD=12345678
GATE_EXPORT_PASSWORD=12345678

mkdir -p $SSL_PATH

openssl genrsa \
  -des3 \
  -out $SSL_PATH/ca.key \
  -passout pass:${CA_KEY_PASSWORD} \
  4096

openssl req \
  -new \
  -x509 \
  -days 10000 \
  -key $SSL_PATH/ca.key \
  -out $SSL_PATH/ca.crt \
  -passin pass:${CA_KEY_PASSWORD}

openssl genrsa \
  -des3 \
  -out $SSL_PATH/deck.key \
  -passout pass:${DECK_KEY_PASSWORD} \
  4096

openssl req \
  -new \
  -key $SSL_PATH/deck.key \
  -out $SSL_PATH/deck.csr \
  -passin pass:${DECK_KEY_PASSWORD}

openssl x509 \
  -sha256 \
  -req \
  -days 10000 \
  -in $SSL_PATH/deck.csr \
  -CA $SSL_PATH/ca.crt \
  -CAkey $SSL_PATH/ca.key \
  -CAcreateserial \
  -out $SSL_PATH/deck.crt \
  -passin pass:${CA_KEY_PASSWORD}

openssl genrsa \
  -des3 \
  -out $SSL_PATH/gate.key \
  -passout pass:${GATE_KEY_PASSWORD} \
  4096

openssl req \
  -new \
  -key $SSL_PATH/gate.key \
  -out $SSL_PATH/gate.csr \
  -passin pass:${GATE_KEY_PASSWORD}

openssl x509 \
  -sha256 \
  -req \
  -days 10000 \
  -in $SSL_PATH/gate.csr \
  -CA $SSL_PATH/ca.crt \
  -CAkey $SSL_PATH/ca.key \
  -CAcreateserial \
  -out $SSL_PATH/gate.crt \
  -passin pass:${CA_KEY_PASSWORD}

openssl pkcs12 \
  -export \
  -clcerts \
  -in $SSL_PATH/gate.crt \
  -inkey $SSL_PATH/gate.key \
  -out $SSL_PATH/gate.p12 \
  -name gate \
  -passin pass:${GATE_KEY_PASSWORD} \
  -password pass:${GATE_EXPORT_PASSWORD}

keytool -importkeystore \
  -srckeystore $SSL_PATH/gate.p12 \
  -srcstoretype pkcs12 \
  -srcalias gate \
  -destkeystore $SSL_PATH/gate.jks \
  -destalias gate \
  -deststoretype pkcs12 \
  -deststorepass ${JKS_PASSWORD} \
  -destkeypass ${JKS_PASSWORD} \
  -srcstorepass ${GATE_EXPORT_PASSWORD}

keytool -importcert \
  -keystore $SSL_PATH/gate.jks \
  -alias ca \
  -file $SSL_PATH/ca.crt \
  -storepass ${JKS_PASSWORD} \
  -noprompt

hal config security api ssl edit \
  --key-alias gate \
  --keystore $SSL_PATH/gate.jks \
  --keystore-password \
  --keystore-type jks \
  --truststore $SSL_PATH/gate.jks \
  --truststore-password \
  --truststore-type jks

hal config security api ssl enable

echo $DECK_KEY_PASSWORD | hal config security ui ssl edit \
  --ssl-certificate-file $SSL_PATH/deck.crt \
  --ssl-certificate-key-file $SSL_PATH/deck.key \
  --ssl-certificate-passphrase

hal config security ui ssl enable

# https://spinnaker.io/docs/setup/other_config/security/authentication/saml/

keytool -genkey \
  -keystore ~/.hal/saml/saml.jks \
  -alias saml \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass ${JKS_PASSWORD} \
  -noprompt

hal config security authn saml edit \
  --keystore ~/.hal/saml/saml.jks \
  --keystore-alias saml \
  --keystore-password ${JKS_PASSWORD} \
  --metadata ~/.hal/saml/metadata.xml \
  --issuer-id spinnaker \
  --service-address-url https://localhost:8084 \
  --user-attribute-mapping-username username \
  --user-attribute-mapping-email email \
  --user-attribute-mapping-first-name firstName \
  --user-attribute-mapping-last-name lastName \
  --user-attribute-mapping-roles memberOf

hal config security authn saml enable

# https://spinnaker.io/docs/setup/other_config/security/admin/

echo 'fiat.admin.roles: ["administrators"]' > ~/.hal/default/profiles/fiat-local.yml
hal config security authz enable

hal deploy apply

# https://spinnaker.io/docs/setup/other_config/security/authorization/service-accounts/

kubectl port-forward svc/spin-front50 8080:8080 -n spinnaker
curl -X POST \
  -H "Content-type: application/json" \
  -d '{ "name": "spinnaker-service-account@spinnaker", "memberOf": ["Service Accounts"] }' \
  http://localhost:8080/serviceAccounts

kubectl port-forward svc/spin-fiat 7003:7003 -n spinnaker
curl -X POST http://localhost:7003/roles/sync