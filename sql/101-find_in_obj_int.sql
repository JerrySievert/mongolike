CREATE OR REPLACE FUNCTION find_in_obj_int(data json, key varchar) RETURNS
INT AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return Number(data);
$$ LANGUAGE plv8 IMMUTABLE STRICT;