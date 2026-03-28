#!/bin/bash

copy_custom_certificate_from_environment_variable() {
  # takes a variable name and pipes the content to a certificate file
  custom_ca_variable_name="$1"
  if [ -n "${!custom_ca_variable_name}" ]; then
    echo -e "${!custom_ca_variable_name}" > /usr/local/share/ca-certificates/opendut_custom_ca_"${custom_ca_variable_name}".crt
  fi
}

refresh_ca_bundle() {
  # create a CA bundle that includes the system bundle and any provided OpenDUT custom CAs
  local base_bundle="/etc/ssl/certs/ca-certificates.crt"
  local out_bundle="/etc/ssl/certs/opendut-ca-bundle.crt"

  if [ -f "$base_bundle" ]; then
    cat "$base_bundle" > "$out_bundle"
  else
    : > "$out_bundle"
  fi

  for crt in /usr/local/share/ca-certificates/opendut_custom_ca_*.crt; do
    if [ -f "$crt" ]; then
      echo >> "$out_bundle"
      cat "$crt" >> "$out_bundle"
    fi
  done

  export SSL_CERT_FILE="$out_bundle"
}
append_data_from_env_variable() {
  var_name="$1"
  file_name="$2"
  if [ -n "${!var_name}" ]; then
    echo -e "${!var_name}" >> "$file_name"
  fi
}

die_with_error() {
        echo "terminating with error"
        exit 1
}
die_with_success() {
        echo "terminating"
        return 0
}

echo "Preparing opendut certificates ..."
copy_custom_certificate_from_environment_variable "OPENDUT_CUSTOM_CA1"
copy_custom_certificate_from_environment_variable "OPENDUT_CUSTOM_CA2"
refresh_ca_bundle
append_data_from_env_variable OPENDUT_HOSTS /etc/hosts

trap die_with_success TERM

echo "Running command in background:" "$@"

# Run command in background to properly handle SIGTERM
exec "$@" &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
