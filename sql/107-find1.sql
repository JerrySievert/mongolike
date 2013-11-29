CREATE OR REPLACE FUNCTION find (collection varchar) RETURNS
SETOF json AS $$
  var full_find = plv8.find_function("find(varchar,json,int,int)");
  var results = full_find(collection,{ },-1,0);
  return results;
$$ LANGUAGE plv8 STRICT;