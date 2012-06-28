CREATE OR REPLACE FUNCTION runCommand (options varchar) RETURNS
json AS $$
  options = JSON.parse(options);

  var map, reduce, finalize;
  
  if (options.map) {
    eval("map = " + options.map);
  }
  if (options.reduce) {
    eval("reduce = " + options.reduce);
  }
  if (options.finalize) {
    eval("finalize = " + options.finalize);
  }

  if (map === undefined || reduce === undefined) {
    throw new Error("not code");
  }

  var emitted = { };

  function emit(key, data) {
    if (emitted[key] === undefined) {
      emitted[key] = [ ];
    }
    emitted[key].push(data);
  }

  var collection = 'col_' + options.mapreduce;
  var sql = "SELECT data FROM " + collection;

  var plan, cursor, row;

  if (options.query) {
    var where_clause = plv8.find_function("where_clause");
    var where = where_clause(JSON.stringify(options.query));
    where = JSON.parse(where);
    
    sql += " " + where.sql;
    plan = plv8.prepare(sql, where.types);
    cursor = plan.cursor(where.binds);
  } else {
    plan = plv8.prepare(sql);
    cursor = plan.cursor();
  }

  while (row = cursor.fetch()) {
    map.apply(JSON.parse(row.data));
  }

  cursor.close();
  plan.free();

  var reduced = { };
  for (var j in emitted) {
    if (reduced[j] === undefined) {
      reduced[j] = [ ];
    }
    reduced[j] = reduced[j].concat(reduce(j, emitted[j]));
    delete emitted[j];
  }

  if (finalize) {
    var final = [ ];
    for (var x in reduced) {
      final.push({ "_id": x, "value": finalize(x, reduced[x][0]) });
      delete reduced[x];
    }
    return JSON.stringify(final);
  } else {
    var out = [ ];
    for (var k in reduced) {
      out.push({_id: k, value: reduced[k][0] });
    }
    
    return JSON.stringify(out);
  }

  
  return JSON.stringify(emitted);
$$ LANGUAGE plv8 STRICT;