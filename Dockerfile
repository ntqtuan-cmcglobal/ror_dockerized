FROM ruby:3.4.4

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  ffmpeg

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN npm install tailwindcss

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "${PORT}"]
