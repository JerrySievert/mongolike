CREATE OR REPLACE FUNCTION find_in_obj(data json, key varchar) RETURNS
VARCHAR AS $$
  var obj = JSON.parse(data);
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return obj;
$$ LANGUAGE plv8 STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_int(data json, key varchar) RETURNS
INT AS $$
  var obj = JSON.parse(data);
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return Number(obj);
$$ LANGUAGE plv8 STRICT;

CREATE OR REPLACE FUNCTION find_in_obj_exists(data json, key varchar) RETURNS
BOOLEAN AS $$
  var obj = JSON.parse(data);
  var parts = key.split('.');

  var part = parts.shift();
  while (part && (obj = obj[part]) !== undefined) {
    part = parts.shift();
  }

  return (obj === undefined ? 'f' : 't');
$$ LANGUAGE plv8 STRICT;

CREATE OR REPLACE FUNCTION find (collection varchar, terms json) RETURNS
SETOF json AS $$
  var table = 'col_' + collection;
  var sql = "SELECT data FROM " + table;
  var c = [ ];
  var t = [ ];
  var b = [ ];

  var count = 1;
  
  function build_clause (key, value, type) {
    var clauses = [ ],
        binds   = [ ],
        types   = [ ];

    if (typeof(value) === 'object') {
      if (key === '$or') {
        var tclauses = [ ];

        for (var i = 0; i < value.length; i++) {
          var ret  = build_clause(Object.keys(value[i])[0], value[i][Object.keys(value[i])[0]]);

          tclauses = tclauses.concat(ret.clauses);
          binds    = binds.concat(ret.binds);
          types    = types.concat(ret.types);
        }

        clauses.push('( ' + tclauses.join(' OR ') + ' )');
      } else {
        var keys = Object.keys(value);

        for (var i = 0; i < keys.length; i++) {
          var ret;
          if (keys[i] === '$gt') {
            ret = build_clause(key, value[keys[i]], '>');
          } else if (keys[i] === '$lt') {
            ret = build_clause(key, value[keys[i]], '<');
          } else if (keys[i] === '$gte') {
            ret = build_clause(key, value[keys[i]], '>=');
          } else if (keys[i] === '$lte') {
            ret = build_clause(key, value[keys[i]], '<=');
          } else if (keys[i] === '$exists') {
            ret = build_clause(key, value[keys[i]], 'exists');
          }

          clauses = clauses.concat(ret.clauses);
          binds   = binds.concat(ret.binds);
          types   = types.concat(ret.types);
        }
      }
    } else {
      type = type || '=';
      var lval;

      if (type === 'exists') {
        clauses.push("find_in_obj_exists(data, '" + key + "') = $" + count);
        types.push('boolean');
        value = value ? 't' : 'f';
      } else {
        switch (typeof(value)) {
          case 'number':
          clauses.push("find_in_obj_int(data, '" + key + "') " + type + " $" + count);
          types.push('int');
          break;

          case 'string':
          clauses.push("find_in_obj(data, '" + key + "') " + type + " $" + count);
          types.push('varchar');
          break;

          default:
          console.log("unknown type: " + typeof(value));
        }
      }

      binds.push(value);

      count++;
    }

    return { clauses: clauses, binds: binds, types: types };
  }
    
  if (terms !== undefined) {
    var obj = JSON.parse(terms);
    var keys = Object.keys(obj);

    for (var i = 0; i < keys.length; i ++) {
      var ret = build_clause(keys[i], obj[keys[i]]);
      c = c.concat(ret.clauses);
      b = b.concat(ret.binds);
      t = t.concat(ret.types);
    }
    
    if (c.length) {
      sql += " WHERE ";
      
      sql += c.join(" AND ");
    }
  }

  var plan = plv8.prepare(sql, t);
  var rows = plan.execute(b);

  var ret = [ ];

  for (var i = 0; i < rows.length; i++) {
    ret.push(JSON.stringify(rows[i].data));
  }

  plan.free();
  return ret;
$$ LANGUAGE plv8 STRICT;
