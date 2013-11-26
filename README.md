# Mongolike

Mongolike is a MongoDB workalike, implemented in PLV8 and Postgres.
Mongolike was originally written by JerrySievert.

## Implemented (so far)

* create_collection()
* drop_collection()
* find()
* save()
* runCommand() (Map/Reduce)


## Installing

    $ psql yourdb < create_collection.sql
    $ psql yourdb < drop_collection.sql
    $ psql yourdb < whereclause.sql
    $ psql yourdb < save.sql
    $ psql yourdb < find.sql
    $ psql yourdb < mapreduce.sql
