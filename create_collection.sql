CREATE TABLE collection (
  collection_id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR
);

CREATE UNIQUE INDEX idx_collection_constraint ON collection (name);

CREATE OR REPLACE FUNCTION create_collection(collection varchar) RETURNS
boolean AS $$

  var plan1 = plv8.prepare('INSERT INTO collection (name) VALUES ($1)', [ 'varchar' ]);
  var plan2 = plv8.prepare('CREATE TABLE col_' + collection +
    ' (col_' + collection + '_id CHARACTER VARYING NOT NULL PRIMARY KEY, data JSON)');
  var plan3 = plv8.prepare('CREATE SEQUENCE seq_col_' + collection);

  var ret;
  try {
    plv8.subtransaction(function () {
      plan1.execute([ collection ]);
      plan2.execute([ ]);
      plan3.execute([ ]);
      ret = true;
    });
  } catch (err) {
    plv8.elog(INFO,"Error creating table: " + err);
    ret = false;
  }
  plan1.free();
  plan2.free();
  plan3.free();

$$ LANGUAGE plv8 IMMUTABLE STRICT;
