FROM registry.fedoraproject.org/fedora-minimal:latest
# ARG VERSION=1.14.0

RUN set -x \
  \
  && microdnf install -y \
    # https://s3.amazonaws.com/mountpoint-s3-release/$VERSION/$(arch)/mount-s3-$VERSION-$(arch).rpm \
    https://s3.amazonaws.com/mountpoint-s3-release/latest/$(arch)/mount-s3.rpm \
  && microdnf clean all \
  && rm -rf \
    /var/cache \
    /var/log/*

ENTRYPOINT ["mount-s3"]