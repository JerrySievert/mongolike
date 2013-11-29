CREATE OR REPLACE FUNCTION ensureIndex(collection varchar, obj json, modifier json) RETURNS
BOOLEAN AS $$
  var keys = Object.keys(obj).sort();

  var index = "idx_col_" + collection + "_" + keys.join("_");

  // find out if there is an index already
  var sql = "SELECT collection_index_id FROM collection_index WHERE collection = $1 AND name = $2";
  var plan = plv8.prepare(sql, [ 'varchar', 'varchar' ]);
  var rows = plan.execute([ collection, index ]);

  // index does not exist
  if (rows === undefined || rows.length === 0) {
    try {
      plv8.subtransaction(function () {
        var idx;

        // check if unique
        if (modifier && modifier.unique) {
          idx = "CREATE UNIQUE INDEX " + index + " ON col_" + collection + " (";
        } else {
          idx = "CREATE INDEX " + index + " ON col_" + collection + " (";
        }

        var parts = [ ];
        for (var i = 0; i < keys.length; i++) {
          parts.push("find_in_obj(data, '" + keys[i] + "')");
        }

        idx += parts.join(", ");
        idx += ")";

        plv8.execute(idx);
        var idx_plan = plv8.prepare("INSERT INTO collection_index (collection, name) VALUES ($1, $2)", [ 'varchar', 'varchar' ]);
        idx_plan.execute([ collection, index ]);
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