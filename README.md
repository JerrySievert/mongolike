# Mongolike

Mongolike is an experimental MongoDB clone being built on top of PLV8 and Postgres.

## Implemented (so far)

* create_collection()
* drop_collection()
* find()
* save()
* runCommand() (Map/Reduce)

## Installing

### Install PLV8

Visit [http://code.google.com/p/plv8js/wiki/PLV8](http://code.google.com/p/plv8js/wiki/PLV8) and follow the build instructions.

### Install Mongolike

#### The Easy Way

The easy way to install is to use `node.js`.

    $ npm install
    $ bin/mongolike -d yourdb

#### The Slight Less Easy Way

    $ psql yourdb <sql/*.sql

## Running Tests

Mongolike includes a test suite and a test runner.

    $ test/test_runner.js -d yourdb

Additional tests can be added to `test/tests.sql`.

## Importing the Data

I have included a modest amount of data for testing and benchmarking, both for Postgres and for MongoDB (1,706,873 rows).

Importing into Postgres:

    $ psql yourdb < data/cities.sql

This will create the collection and `save()` all of the data.

Importing into MongoDB

    $ mongoimport --collection cities --type csv --headerline --file data/cities.csv --db yourdb


Follow along at http://legitimatesounding.com/blog/
