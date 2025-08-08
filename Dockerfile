FROM ruby:3.4.4

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  ffmpeg

# Create app directory
RUN mkdir /myapp
WORKDIR /myapp

# Install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Install Node dependencies
COPY package.json ./
RUN npm install

# Copy the rest of the app
COPY . .

# Build Tailwind CSS
RUN npm run build:css

# Precompile Rails assets
# RUN bundle exec rails assets:precompile
# Expose port and start server
ENV PORT=3000
CMD bundle exec rails server -b 0.0.0.0 -p $PORT
