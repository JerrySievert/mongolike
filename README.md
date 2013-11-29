# Mongolike

Mongolike is an experimental MongoDB clone being built on top of PLV8 and Postgres.

## Implemented (so far)

* create_collection()
* drop_collection()
* save()
* find()
* runCommand() (Map/Reduce)

## Installing

### Install PLV8

Visit [http://code.google.com/p/plv8js/wiki/PLV8](http://code.google.com/p/plv8js/wiki/PLV8) and follow the build instructions.

### Install Mongolike

#### The Easy Way

The easy way to install is to use `node.js`.

    $ npm install -g mongolike
    $ mongolike-install -d yourdb

#### The Slight Less Easy Way

    $ psql yourdb <sql/*.sql

## Running Tests

Mongolike includes a test suite and a test runner.

    $ test/test_runner.js -d yourdb

Additional tests can be added to `test/tests.sql`.

## Using

All commands must be prefixed by `SELECT`, and are modified slightly to work in the Postgres environment.

### create_collection(collection)

Create a collection.

_Example:_

    SELECT create_collection('test');

### drop_collection(collection)

Drop a collection.

_Example:_

    SELECT drop_collection('test');

### save(collection, object)

Save an object into a collection.

_Example:_

    SELECT save('test', '{ "foo": "bar" }');

### find(collection /*, terms, limit, skip */)

Find an object, with optional `terms`, `limit`, and `skip`.

_Example:_

    SELECT find('test', '{ "type": { "$in": [ "food", "snacks" ] } }');

### runCommand(command)

Run a command on the Database.  Currently only `mapReduce` is supported.

_Example:_

    SELECT runCommand('{
      "map": "function MapCode() {
        emit(this.Country, {
          \"data\": [
            {
              \"city\": this.City, 
              \"lat\":  this.Latitude, 
              \"lon\":  this.Longitude
            }
          ]
        });
      }",
      "reduce": "function ReduceCode(key, values) {
        var reduced = {
          \"data\": [ ]
        };
        for (var i in values) {
          var inter = values[i];
          for (var j in inter.data) {
            reduced.data.push(inter.data[j]);
          }
        }
        return reduced;
      }",
      "mapreduce": "cities",
      "finalize": "function Finalize(key, reduced) {
        if (reduced.data.length == 1) {
          return {
            \"message\" : \"This Country contains only 1 City\"
          };
        }
    
        var min_dist = 999999999999;
        var city1 = { \"name": "\" };
        var city2 = { \"name\": \"\" };
        var c1;
        var c2;
        var d;
    
        for (var i in reduced.data) {
          for (var j in reduced.data) {
            if (i >= j) continue;
            c1 = reduced.data[i];
            c2 = reduced.data[j];
            d = Math.sqrt((c1.lat-c2.lat)*(c1.lat-c2.lat)+(c1.lon-c2.lon)*(c1.lon-c2.lon));
    
            if (d < min_dist && d > 0) {
              min_dist = d;
              city1 = c1;
              city2 = c2;
            }
          }
        }
        return {
          \"city1\": city1.city,
          \"city2\": city2.city,
          \"dist\": min_dist
        };
      }" }');

## Importing the Data

I have included a modest amount of data for testing and benchmarking, both for Postgres and for MongoDB (1,706,873 rows).

Importing into Postgres:

    $ psql yourdb < data/cities.sql

This will create the collection and `save()` all of the data.

Importing into MongoDB

    $ mongoimport --collection cities --type csv --headerline --file data/cities.csv --db yourdb


Follow along at http://legitimatesounding.com/blog/
