CREATE OR REPLACE FUNCTION find (collection varchar, terms json, lim int) RETURNS
SETOF json AS $$
  var full_find = plv8.find_function("find(varchar,json,int,int)");
  var results = full_find(collection,terms,lim,0);
  return results;
$$ LANGUAGE plv8 STRICT;