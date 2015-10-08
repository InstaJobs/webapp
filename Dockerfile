FROM uioporqwerty/ruby:2.2.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Install instajobs
RUN mkdir /webapp
WORKDIR /webapp

ADD . /webapp

RUN bundle install

