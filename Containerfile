FROM hashicorp/terraform:latest as certs
COPY trusted_ca.tf .

ARG AWS_ENDPOINT_URL_S3
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ENV AWS_ENDPOINT_URL_S3=$AWS_ENDPOINT_URL_S3
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

RUN set -x \
  \
  && terraform init \
  && terraform apply -auto-approve \
  && cat outputs/* > ca-cert.pem

FROM registry.fedoraproject.org/fedora-minimal:latest AS ca
COPY --from=certs ca-cert.pem /etc/pki/ca-trust/source/anchors/

ARG VERSION
RUN set -x \
  \
  && update-ca-trust \
  && microdnf install -y \
    https://s3.amazonaws.com/mountpoint-s3-release/$VERSION/$(arch)/mount-s3-$VERSION-$(arch).rpm \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/*
