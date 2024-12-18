#!/usr/bin/env bash
#
# Common bash functions used for testing FTP, FPTS and SFTP.
#
# For configuration reference, see:
#
# * docker-compose.yaml
# * https://hub.docker.com/r/fauria/vsftpd
# * https://hub.docker.com/r/delfer/alpine-ftp-server
# * https://hub.docker.com/r/atmoz/sftp
#
# @author mikko.parviainen@fmi.fi, 2023
#

set -o errexit
set -o nounset
set -o pipefail
set -o errtrace

SCRIPT_BASE_DIR="$(dirname "${BASH_SOURCE[0]}")"

function cleanup() {
  cd "${SCRIPT_BASE_DIR}"
  rm -f -v \
    cert/localhost.{crt,key} \
    upload/{image.jpg,text.txt} || \
    echo "warning: failed to remove some test resources"
}

# Generates a private key and a self-signed certificate for FTPS
function generate_private_key_and_certificate_for_ftps() {
  mkdir -p -v cert
  rm -f -v cert/localhost.{crt,key}
  openssl req -x509 -out cert/localhost.crt -keyout cert/localhost.key \
    -newkey rsa:2048 -nodes -sha256 \
    -subj '/CN=localhost' -extensions EXT -config <( \
     printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
}

function generate_test_files() {
  mkdir -m 777 -p -v upload
}

function remove_previously_known_localhost_sftp_host_key() {
  ssh-keygen -R "[localhost]:2222" || \
    echo "warning: host key file is probably missing"
}

function start_ftp_servers() {
  docker compose up --detach
}

function stop_ftp_servers() {
  docker compose down
}
