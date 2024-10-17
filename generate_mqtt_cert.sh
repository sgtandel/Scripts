#!/bin/bash
TEMP_PATH=$(mktemp -d /tmp/XXXXXXXXXX)
CERT_PATH=/etc/certs
CERT_EXPIRE=365
ip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"
SUBJECT_CA="/C=US/ST=MA/L=Hudson/O=AESI Inc/OU=CA/CN=mqtt-root"
SUBJECT_BROKER="/C=US/ST=MA/L=Hudson/O=AESI Inc/OU=Server/CN=$ip"
SUBJECT_CLIENT="/C=US/ST=MA/L=Hudson/O=AESI Inc/OU=Client/CN=mqqt-client"
PASSWD="123456"

generate_CA_cert () {
   echo "$SUBJECT_CA"
   cd "${TEMP_PATH}/ca" || exit 1
   openssl req -new -x509 -subj "$SUBJECT_CA" -days ${CERT_EXPIRE} -extensions v3_ca -keyout ca.key -out ca.crt -passout pass:"$PASSWD"
   cd - || exit 1
}

generate_broker_cert () {
   echo "$SUBJECT_BROKER"
   cd "${TEMP_PATH}/broker" || exit 1
   openssl genrsa -out broker.key 2048
   openssl req -new -subj "$SUBJECT_BROKER" -key broker.key -out broker.csr #-passout #pass:"$PASSWD"
   openssl x509 -req -in broker.csr -CA ${CERT_PATH}/ca/ca.crt -CAkey ${CERT_PATH}/ca/ca.key -CAcreateserial -out broker.crt -days ${CERT_EXPIRE} -passin pass:"$PASSWD"
   cd - || exit 1
}

generate_client_cert () {
   echo "$SUBJECT_CLIENT"
   cd "${TEMP_PATH}/client" || exit 1
   openssl genrsa -out client.key 2048
   openssl req -new -subj "$SUBJECT_CLIENT" -out client.csr -key client.key #-passout #pass:"$PASSWD"
   openssl x509 -req -in client.csr -CA ${CERT_PATH}/ca/ca.crt -CAkey ${CERT_PATH}/ca/ca.key -CAcreateserial -out client.crt -days ${CERT_EXPIRE} -passin pass:"$PASSWD"
   cd - || exit 1
}


if [[ ! -e "${CERT_PATH}/ca/ca.crt"
      || ! -e "${CERT_PATH}/ca/ca.key" ]]
then
   sudo rm -rf "${CERT_PATH}"
   mkdir -p "${CERT_PATH}"
   mkdir "${TEMP_PATH}/ca"
   generate_CA_cert
   cp -a "${TEMP_PATH}/ca" "${CERT_PATH}"
   chmod 644 "${CERT_PATH}/ca/"*
fi

if [[ ! -e "${CERT_PATH}/broker/broker.crt"
      || ! -e "${CERT_PATH}/broker/broker.csr"
      || ! -e "${CERT_PATH}/broker/broker.key" ]]
then
   sudo rm -rf "${CERT_PATH}/broker"
   mkdir "${TEMP_PATH}/broker"
   generate_broker_cert
   cp -a "${TEMP_PATH}/broker" "${CERT_PATH}"
   chmod 644 "${CERT_PATH}/broker/"*
fi

if [[ ! -e "${CERT_PATH}/client/client.crt"
      || ! -e "${CERT_PATH}/client/client.csr"
      || ! -e "${CERT_PATH}/client/client.key" ]]
then
   sudo rm -rf "${CERT_PATH}/client"
   mkdir "${TEMP_PATH}/client"
   generate_client_cert
   cp -a "${TEMP_PATH}/client" "${CERT_PATH}"
   chmod 644 "${CERT_PATH}/client/"*
fi

sudo rm -rf "${TEMP_PATH}"

exit 0
