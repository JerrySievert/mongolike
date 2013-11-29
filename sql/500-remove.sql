CREATE OR REPLACE FUNCTION remove (collection varchar, terms json) RETURNS
boolean AS $$
  var table = 'col_' + collection;
  var sql = "DELETE FROM " + table;

  var where_clause = plv8.find_function("where_clause");
  var where = where_clause(terms);
  where = JSON.parse(where);

  sql += " " + where.sql;

  try {
    plv8.subtransaction(function(){
      var plan = plv8.prepare(sql, where.types);
      plan.execute(where.binds);
      plan.free();
    });
  } catch(err) {
    return false;
  }

  return true;
$$ LANGUAGE plv8 STRICT;