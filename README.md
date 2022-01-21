# Traski-pl frontend

This project is a backend to the web application called Traski.pl - a platform for motorcyclists to share, rate and comment motorcycle routes. [More detailed information on this project can be found here.](http://mpanasiuk.me/project.php?project=18)

## Requirements

- Ruby: this project requires Ruby >= 2.7.0
- Rails: this project is based on Ruby on Rails >= 6
- This project is just an API. [You can find the frontend project under this link](https://github.com/grzala/traskipl-frontend)

## Installation

1. Clone the project
2. Run `bundle`
3. Run `rails db:create`, `rails db:migrate` and `rails db:seed`
4. Scrape the accident information using `rake sewik:scrape[dateFrom,dateTo]`, where "dateFrom" and "dateTo" are in `"YYYY-MM-DD"` format. Try not to scrape too much at once as it is a long process that needs to be repeated if interrupted.
5. If you havent done it yet,  [Set up the frondend project](https://github.com/grzala/traskipl-frontend)
6. Run `rails s`. The API will run on localhost:3001


