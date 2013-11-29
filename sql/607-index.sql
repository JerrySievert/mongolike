CREATE OR REPLACE FUNCTION removeIndex(collection varchar, obj json) RETURNS
boolean AS $$

  var keys = Object.keys(obj).sort();

  var index = "idx_col_" + collection + "_" + keys.join("_");

  var removeIndex = plv8.find_function("removeIndex(varchar,varchar)");
  var results = removeIndex(collection, index);

  return results;
$$ LANGUAGE plv8 IMMUTABLE STRICT;