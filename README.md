# Simple Calendar

Simple Calendar is a small Ruby on Rails app for keeping track of personal events. It covers the basics you would expect from a scheduler: signing in, adding events, editing them later, deleting them, and viewing what is coming up.

The goal is to keep the app straightforward and easy to run locally. It is not trying to be a full calendar platform, but it has enough structure to show how events, users, recurring entries, and calendar views can work together in a Rails application.

Project is mostly focused on trying out basic Ruby on Rails principles, while also providing a complete, simplistic Application structure.

## Features

- User registration, login, and logout
- User-specific events
- Month, week, and upcoming event views
- Create, update, and delete events
- All-day and timed events
- Recurring event series support
- Event colors, descriptions, and locations
- User settings for default calendar and upcoming views
- Hotwire/Turbo-based Rails interface
- SQLite-backed local development database
- Date-relative demo seed data for the current and next month

## Tech Stack

- Ruby on Rails 8.1
- SQLite
- Hotwire: Turbo and Stimulus
- Importmap
- Solid Queue, Solid Cache, and Solid Cable
- BCrypt authentication

## Requirements

- Ruby 4.0.5 installed locally
- Bundler installed locally
- SQLite available locally

## Setup

Install dependencies:

```sh
bundle install
```

Prepare the database:

```sh
ruby bin/rails db:prepare
```

Add demo data to the database:

```sh
ruby bin/rails db:seed
```

Start the development server:

```sh
ruby bin/rails server
```

Open the app in your browser:

```text
http://localhost:3000
```

## Demo Account

Running `ruby bin/rails db:seed` creates a demo account and fills it with sample calendar data for the current and next month.

Use this login to skip creating your own mock data:

```text
Email: example.user@example.com
Password: examplepassword
```
