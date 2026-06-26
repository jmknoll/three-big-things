FROM ruby:3.4-alpine

RUN apk add --no-cache build-base postgresql-dev tzdata libxml2-dev libxslt-dev yaml-dev

WORKDIR /app

ENV BUNDLE_FORCE_RUBY_PLATFORM=1

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 8080

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "8080"]
