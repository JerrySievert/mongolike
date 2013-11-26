CREATE OR REPLACE FUNCTION find_in_obj(data json, key varchar) RETURNS
VARCHAR AS $$

  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return data;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_int(data json, key varchar) RETURNS
INT AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return Number(data);
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_exists(data json, key varchar) RETURNS
BOOLEAN AS $$
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (data = data[part]) !== undefined) {
    part = parts.shift();
  }

  return (data === undefined ? 'f' : 't');
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION find (collection varchar, terms json, lim int, skip int) RETURNS
SETOF json AS $$
  var table = 'col_' + collection;
  var sql = "SELECT data FROM " + table;

  var where_clause = plv8.find_function("where_clause");
  var where = where_clause(terms);

  where = JSON.parse(where);

  sql += " " + where.sql;
  if (lim > -1 )
  {
    sql += "limit " + lim;
  }
  if (skip > 0)
  {
    sql += "offset " + skip;
  }


  try {
    plv8.subtransaction(function(){
      var plan = plv8.prepare(sql, where.types);
      rows = plan.execute(where.binds);
      plan.free();
    });
  }
  catch(err) {           
      if (err=='Error: relation "' + table + '" does not exist')
        {
        rows = []
        }
  }
  var ret = [ ];

  for (var i = 0; i < rows.length; i++) {
    ret.push(JSON.stringify(rows[i].data));
  }

  return ret;
$$ LANGUAGE plv8 STRICT;

CREATE OR REPLACE FUNCTION find (collection varchar, terms json) RETURNS
SETOF json AS $$
  var full_find = plv8.find_function("find(varchar,json,int,int)");
  var results = full_find(collection,terms,-1,0);
  return results;
$$ LANGUAGE plv8 STRICT;

CREATE OR REPLACE FUNCTION find (collection varchar, terms json, lim int) RETURNS
SETOF json AS $$
  var full_find = plv8.find_function("find(varchar,json,int,int)");
  var results = full_find(collection,terms,lim,0);
  return results;
$$ LANGUAGE plv8 STRICT;




