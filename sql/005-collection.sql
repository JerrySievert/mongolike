CREATE OR REPLACE FUNCTION drop_collection(collection varchar) RETURNS
boolean AS $$


  var plan1 = plv8.prepare('DELETE FROM collection $1', [ 'varchar' ]);
  var plan2 = plv8.prepare('DROP TABLE col_' + collection);
  var plan3 = plv8.prepare('DROP SEQUENCE seq_col_' + collection);

  var ret;
  try {
    plv8.subtransaction(function () {
      plan1.execute([ collection ]);
      plan2.execute([ ]);
      plan3.execute([ ]);
      ret = true;
    });
  } catch (err) {
    ret = false;
  }
  plan1.free();
  plan2.free();
  plan3.free();

$$ LANGUAGE plv8 IMMUTABLE STRICT;