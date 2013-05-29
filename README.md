# Mongolike

Mongolike is an experimental MongoDB clone being built on top of PLV8 and Postgres.

## Implemented (so far)

* create_collection()
* find()
* save()
* runCommand() (Map/Reduce)

## Installing

Install PLV8 - http://code.google.com/p/plv8js/wiki/PLV8

I recommend installing V8 via these instructions: http://code.google.com/p/v8/wiki/BuildingWithGYP


    $ psql yourdb < create_collection.sql
    $ psql yourdb < whereclause.sql
    $ psql yourdb < save.sql
    $ psql yourdb < find.sql
    $ psql yourdb < mapreduce.sql

## Importing the data

I have included a modest amount of data for testing and benchmarking, both for Postgres and for MongoDB (1,706,873 rows).

Importing into Postgres:

    $ psql yourdb < data/cities.sql

This will create the collection and `save()` all of the data.

Importing into MongoDB

    $ mongoimport --collection cities --type csv --headerline --file data/cities.csv --db yourdb


Follow along at http://legitimatesounding.com/blog/
