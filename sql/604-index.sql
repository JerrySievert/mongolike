CREATE OR REPLACE FUNCTION ensureIndex(collection varchar, obj json) RETURNS
BOOLEAN AS $$
  var full_find = plv8.find_function("ensureIndex(varchar,json,json)");
  var results = full_find(collection,obj,{ });
  return results;
$$ LANGUAGE plv8 IMMUTABLE STRICT;