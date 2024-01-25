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
Best option is to use foreman to run Rails + Tailwind watcher
```bash
cp Procfile.dev.example Procfile.dev
foreman start -f Procfile.dev
```

Or, you can run these individually
```bash
./bin/rails s
./bin/rails tailwindcss:watch
```

### Playing w/ console
```bash
./bin/rails c
```
