# Traski-pl frontend

This project is a backend to the web application called Traski.pl - a platform for motorcyclists to share, rate and comment motorcycle routes. [More detailed information on this project can be found here.](http://mpanasiuk.me/project.php?project=18)

## Requirements

- Ruby: this project requires Ruby >= 2.7.0
- Rails: this project is based on Ruby on Rails >= 6
- This project is just an API. [You can find the frontend project under this link](https://github.com/grzala/traskipl-frontend)
- This project requires access to Google Storage Cloud. You need to setup a bucket and have an access key.

## Installation

1. Clone the project
2. Run `bundle`
3. Setup your GCS in /config/storage.yml. Create a file called google.credentials.json in the root of the project and enter your key there.
3. Run `rails db:create`, `rails db:migrate` and `rails db:seed`
4. Scrape the accident information using `rake sewik:scrape[dateFrom,dateTo]`, where "dateFrom" and "dateTo" are in `"YYYY-MM-DD"` format. Try not to scrape too much at once as it is a long process that needs to be repeated if interrupted.
5. If you havent done it yet,  [Set up the frondend project](https://github.com/grzala/traskipl-frontend)
6. Run `rails s`. The API will run on localhost:3001

You can log by creating your own user or by loggin in as:  
username: `testX@mail.com` where X is any number between 1 and 40
password: `testtest` (every seeded user has the same password)


