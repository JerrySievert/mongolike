CREATE OR REPLACE FUNCTION find_in_obj(data json, key varchar) RETURNS
VARCHAR AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return data;
$$ LANGUAGE plv8 IMMUTABLE STRICT;