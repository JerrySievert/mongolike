--- [todo] - test
CREATE OR REPLACE FUNCTION find (collection varchar, terms json, lim int, skip int) RETURNS
SETOF json AS $$
  var table = 'col_' + collection;
  var sql = "SELECT data FROM " + table;

  var where_clause = plv8.find_function("where_clause");
  var where = where_clause(terms);
  where = JSON.parse(where);

  sql += " " + where.sql;
  if (lim > -1 ) {
    sql += "LIMIT " + lim;
  }

  if (skip > 0) {
    sql += "OFFSET " + skip;
  }


  try {
    plv8.subtransaction(function(){
      var plan = plv8.prepare(sql, where.types);
      rows = plan.execute(where.binds);
      plan.free();
    });
  } catch(err) {           
    if (err=='Error: relation "' + table + '" does not exist') {
      rows = [ ];
    }
  }

  var ret = [ ];

  for (var i = 0; i < rows.length; i++) {
    ret.push(JSON.stringify(rows[i].data));
  }

  return ret;
$$ LANGUAGE plv8 STRICT;