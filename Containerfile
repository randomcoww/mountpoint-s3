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

ARG CSI_VERSION
FROM public.ecr.aws/mountpoint-s3-csi-driver/aws-mountpoint-s3-csi-driver:$CSI_VERSION AS csi

# Ref: https://github.com/awslabs/mountpoint-s3-csi-driver/blob/main/Dockerfile
FROM registry.fedoraproject.org/fedora-minimal:latest AS ca
COPY --from=certs ca-cert.pem /etc/pki/ca-trust/source/anchors/
COPY --from=csi /bin/aws-s3-csi-driver /bin
COPY --from=csi /bin/aws-s3-csi-controller /bin
COPY --from=csi /bin/aws-s3-csi-mounter /bin

ARG MOUNTPOINT_VERSION
ENV MOUNTPOINT_VERSION=${MOUNTPOINT_VERSION}
ENV MOUNTPOINT_BIN_DIR=/mountpoint-s3/bin

RUN set -x \
  \
  && update-ca-trust \
  && microdnf install -y \
    https://s3.amazonaws.com/mountpoint-s3-release/$MOUNTPOINT_VERSION/$(arch)/mount-s3-$MOUNTPOINT_VERSION-$(arch).rpm \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/* \
  \
  && mkdir -p $MOUNTPOINT_BIN_DIR \
  && ln -s $(which mount-s3) $MOUNTPOINT_BIN_DIR/
