CREATE OR REPLACE FUNCTION find_in_obj(obj json, key varchar) RETURNS
VARCHAR AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return obj;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_int(obj json, key varchar) RETURNS
INT AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return Number(obj);
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_exists(obj json, key varchar) RETURNS
BOOLEAN AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return (obj === undefined ? 'f' : 't');
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find (collection varchar, terms json) RETURNS
SETOF json AS $$
  var table = 'col_' + collection;
  var sql = "SELECT data FROM " + table;

  var where_clause = plv8.find_function("where_clause");
  var where = where_clause(terms);
  where = JSON.parse(where);

  sql += " " + where.sql;
  var plan = plv8.prepare(sql, where.types);
  var rows = plan.execute(where.binds);

  var ret = [ ];

  for (var i = 0; i < rows.length; i++) {
    ret.push(rows[i].data);
  }

  plan.free();
  return ret;
$$ LANGUAGE plv8 STRICT;
