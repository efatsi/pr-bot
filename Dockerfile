FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory
WORKDIR /myapp

# Copy the Gemfile and install gems
COPY Gemfile* /myapp/
RUN bundle install

# Copy the main application
COPY . /myapp

# Expose the port the app runs on
EXPOSE 3000

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]