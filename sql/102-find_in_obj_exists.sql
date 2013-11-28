CREATE OR REPLACE FUNCTION find_in_obj_exists(data json, key varchar) RETURNS
BOOLEAN AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return (data === undefined ? 'f' : 't');
$$ LANGUAGE plv8 IMMUTABLE STRICT;