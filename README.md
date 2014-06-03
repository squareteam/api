Squareteam
===

This is the backend of Squareteam. Written in Ruby with Sinatra.

_For convenience, all commands in this README have been used with this alias : ```alias brake='bundle exec rake'```_

Development & Testing
===

You have two usual environment to help you develop the backend : ```development``` and ```test```.

## Install & Setup

Install the bundle
```bash
bundle install --without "production"
```

Create sqlite databases if they don't exist
```bash
# For development env
touch db/development.sqlite3
brake db:schema:load

# For test env
touch db/test.sqlite3
RACK_ENV=test brake db:schema:load
```

## Launching a develoment console
```bash
bundle exec ruby console
``

## Launching a development server
```bash
brake run
```
Served by default on ```http://localhost:8000/```

## Launching all specs
```bash
brake spec
```


Preproduction
===

## Install

```bash
bundle install --deployment
```

Set database env variables and don't forget to create the database if it doesn't exist.
```bash
PREPROD_ST_DB_NAME=
PREPROD_ST_DB_USERNAME=
PREPROD_ST_DB_PASSWORD=
PREPROD_ST_DB_HOST=
PREPROD_ST_DB_PORT=
```
__if you need to create a database you can use the rake tasks__
```bash
RACK_ENV=preprod brake db:create
RACK_ENV=preprod brake db:setup
RACK_ENV=preprod brake db:migrate
```

## Launch

### without web server
```
RACK_ENV=preprod bundle exec rackup -o PREPROD_ST_HOST -p PREPROD_ST_PORT
```

### Nginx+Passenger

See nginx.conf.example to tweak the nginx configuration.

Production
===

## Install

```bash
bundle install --deployment
```

Set database env variables and don't forget to create the database if it doesn't exist.
```bash
ST_DB_NAME=
ST_DB_USERNAME=
ST_DB_PASSWORD=
ST_DB_HOST=
ST_DB_PORT=
```
__if you need to create a database you can use the rake tasks__
```bash
RACK_ENV=production brake db:create
RACK_ENV=production brake db:setup
RACK_ENV=production brake db:migrate
```

## Launch

### without web server

```
RACK_ENV=production bundle exec rackup -o ST_HOST -p ST_PORT
```

### Nginx + Passenger

See nginx.conf.example to tweak the nginx configuration.
