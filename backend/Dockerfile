FROM ruby:3.4-bookworm

COPY ./ /inventory
RUN cd inventory && bundle install

WORKDIR /inventory
ENTRYPOINT [ "rackup", "-o", "0.0.0.0" ]
