CREATE OR REPLACE FUNCTION save(collection varchar, data json) RETURNS
BOOLEAN AS $$
  var id = data._id;

  // First, lets try an update, see if that works. If so, then the data must exist ;)
  // We will do it in an tranaction, so we can create the collection if it doesnt exist

  try {
    plv8.subtransaction(function() {
      var update = plv8.prepare("UPDATE col_" + collection + " SET data = $1 WHERE col_" + collection + "_id = $2", [ 'json', 'character varying' ]);
      res = update.execute([ data, id ]);
    });
  } catch(err) {
      if (err == 'Error: relation "col_' + collection  + '" does not exist') {
        var create_collection = plv8.find_function("create_collection");
        res = create_collection(collection);
        var update = plv8.prepare("UPDATE col_" + collection + " SET data = $1 WHERE col_" + collection + "_id = $2", [ 'json', 'character varying' ]);
        res = update.execute([ data, id ]);
      }
      else{
        plv8.elog(INFO,"Error saving : " + err);
      }
  }

  if (res == 0) { // If it didnt affect anything, it must be a new row. Insert.
    var seq;
    seq = plv8.prepare("SELECT nextval('seq_col_" + collection + "') AS id");


    if (data._id === undefined) {
      var rows = seq.execute([ ]);
      id = rows[0].id;
      data._id = id;
      seq.free();
    }

    
    var insert = plv8.prepare("INSERT INTO col_" + collection +
      "  (col_" + collection + "_id, data) VALUES ($1, $2)", [ 'character varying', 'json']);
    insert.execute([ id, JSON.stringify(data) ]);
    insert.free();
  }

  return true;
$$ LANGUAGE plv8 IMMUTABLE STRICT;
