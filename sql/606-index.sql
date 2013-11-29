CREATE OR REPLACE FUNCTION removeIndex(collection varchar, name varchar) RETURNS
boolean AS $$

  var sql = "SELECT collection_index_id FROM collection_index WHERE collection = $1 AND name = $2";
  var plan = plv8.prepare(sql, [ 'varchar', 'varchar' ]);
  var rows = plan.execute([ collection, name ]);

  // index exists
  if (rows && rows.length) {
    try {
      plv8.subtransaction(function () {
        var idx = "DROP INDEX IF EXISTS " + name;

        plv8.execute(idx);

        var idx_plan = plv8.prepare("DELETE FROM collection_index WHERE collection = $1 AND name = $2", [ 'varchar', 'varchar' ]);

        idx_plan.execute([ collection, name ]);

        idx_plan.free();
      });
    } catch (err) {
      plan.free();

      return false;
    }
  }

  plan.free();

  return true;


$$ LANGUAGE plv8 IMMUTABLE STRICT;