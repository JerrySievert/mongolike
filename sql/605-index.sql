CREATE OR REPLACE FUNCTION getIndexes(collection varchar) RETURNS
json AS $$
  var results = [ ];

  var sql = "SELECT collection, name, key FROM collection_index WHERE collection = $1";

  var plan = plv8.prepare(sql, [ 'varchar' ]);
  var rows = plan.execute([ collection ]);

  if (rows === undefined || rows.length === 0) {
    plan.free();
    return [ ];
  }

  for (var i = 0; i < rows.length; i++) {
    results.push({
      v:    1,
      ns:   rows[i].collection,
      name: rows[i].name,
      key:  rows[i].key
    });
  }

  plan.free();

  return results;
$$ LANGUAGE plv8 IMMUTABLE STRICT;