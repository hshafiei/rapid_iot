# Rails Fast Iot API
We are tasked with the postponement of database access to the background, in order to scale up the overall system performance and reduce the delays which is specifically useful when dealing with various resource constrained IoT devices with high rate of data generation. The server must be in a consistent state at any given point. Our idea is to put an in-memory storage between database and the application to handle high rates of incoming request, the in-memory storage acts as cache and the database requests are postponed to the background.

## Getting Started
To get the Rails server running locally:
* [Install ruby on rails on your machine](https://gorails.com/setup)
* [install redis-server](https://redis.io/topics/quickstart)
* Clone this repo
* `bundle install` to install all req'd dependencies
* `rake db:migrate` to make all database migrations
* `rails s` to start the local server
## Usage
For full documentaion please refer to the [project's homepage](https://agile-wildwood-66481.herokuapp.com/)
## Running the tests

`bundle exec rspec`

## Authors

* *Hossein Shafiei* - [hshafiei](https://github.com/hshafiei)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

