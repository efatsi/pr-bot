# PR Bot

## System Dependencies

Recommend installing these w/ homebrew:

- ruby 3.2.2
- postgresql (for main application database)
- redis (for websocket communication)

## Setup

```bash
gem install bundler
bundle install
```

And finally:
```bash
./bin/rails db:create
./bin/rails db:migrate

# Run this anytime you add a new Card type to seed the Card(s) into your database
./bin/rails db:seed
```

### Running the app locally
```bash
./bin/rails s
```

### Playing w/ console
```bash
./bin/rails c
```
