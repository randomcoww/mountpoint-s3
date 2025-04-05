FROM hashicorp/terraform:latest as CA
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

FROM registry.fedoraproject.org/fedora-minimal:latest
ARG VERSION
COPY --from=CA ca-cert.pem /etc/pki/ca-trust/source/anchors/

RUN set -x \
  \
  # && VERSION=$(wget -O - https://api.github.com/repos/awslabs/mountpoint-s3/releases/latest | grep tag_name | cut -d '"' -f 4 | tr -d "mountpoint\-s3-") \
  && update-ca-trust \
  && microdnf install -y \
    https://s3.amazonaws.com/mountpoint-s3-release/$VERSION/$(arch)/mount-s3-$VERSION-$(arch).rpm \
    # https://s3.amazonaws.com/mountpoint-s3-release/latest/$(arch)/mount-s3.rpm \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/*

ENTRYPOINT ["mount-s3"]