FROM ruby:3.4-alpine

# --- Corporate TLS interception (Zscaler) support ---------------------------
# Behind a TLS-intercepting proxy, HTTPS fetches fail with "certificate not
# trusted" and apk exits 6 ("no such package", because the signed package
# index could not be downloaded). We bootstrap apk over HTTP first — Alpine's
# package index is cryptographically signed, so integrity is preserved without
# TLS — then install any corporate root CA(s) placed in certs/ so that Ruby /
# Bundler HTTPS to rubygems.org also works. If certs/ has no .crt (e.g. you are
# not behind such a proxy), this is a harmless no-op. See certs/README.md.
COPY certs/ /usr/local/share/ca-certificates/
RUN sed -i 's|https://|http://|g' /etc/apk/repositories \
 && apk add --no-cache ca-certificates \
 && update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

RUN apk add --no-cache build-base postgresql-dev tzdata libxml2-dev libxslt-dev yaml-dev

WORKDIR /app

ENV BUNDLE_FORCE_RUBY_PLATFORM=1

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 8080

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]
