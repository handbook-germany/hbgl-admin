clarat Admin Interface
======================

[![Build Status](https://travis-ci.org/clarat-org/claradmin.svg?branch=master)](https://travis-ci.org/clarat-org/claradmin)

This software uses a variety of external services to enhance User experience, including but not limited to newsletter subscriptions via Mailchimp, automated mailings via Mandrill, the [Google Translate API](https://cloud.google.com/translate/docs/) for automated translations, and the Google Geocoding API.

# Local Development

The clarat admin interface (CAI) uses a list of server and frontend technologies. Before you start with local development,
make sure you meet those requirements (esp. the versions) in your development environment.
The following manual tested in a Linux (Mint) setup.

* docker
* docker-compose


* ruby (v2.3.3)
* node (v6.17.1)
* postgres (tested with v13.1)
* redis ()

For the postgres library installation you'll need additional OS drivers set up beforehand,
see solutions for MacOSX and Debian-likes here:
[Install Postgres Gem under MacOSx & Debian](https://wikimatze.de/installing-postgresql-gem-under-ubuntu-and-mac/)

## Setup

If not stated different, the commands should be run from the the project root.

1. Check out repo and change into the project folder
1. Run `docker-compose up -d`
1. Run `npm install`
1. Change into the folder `client`, call again `npm install`
1. Back again in the project root, run `gem install bundler`
1. Run `bundle install`, which resolves the Gemfile and downloads all ruby packages needed
# 1. Run `rake db:setup`, which should create all tables in the clarat_development database
1. Import the database dump you received into the database
   1. Copy the `dump.sql` into the `db` container with `docker cp dump.sql db:/`
   1. Switch into the `db` container with `docker exec -it db bash`
   1. Restore the dump into the dev database with `pg_restore dump.sql -u postgres -p 11111 -d clarat_development`
   1. In case you encounter errors during restore, try the following:
     1. Drop all tables from `clarat_development`.
     2. Create a role called `orfywwiofdlmxj`, give it all priviliges and give user `postgres` that role.
     3. Run the restore command in 3. again.
   1. Repeat step c. for all other needed databases e.g. `clarat_test` or `clarat_production`
1. Start the rails server with `rails s -p 3000` or the whole development setup with `npm start`.
1. Under `localhost:3000` you should be able to login with your assigned credentials.
