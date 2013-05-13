CREATE OR REPLACE FUNCTION save(collection varchar, data json) RETURNS
BOOLEAN AS $$
  var obj = JSON.parse(data);
  var id = obj._id;

  // if there is no id, naively assume an insert
  if (id === undefined) {



    var seq;
    try
    {
      plv8.subtransaction(function(){
        seq = plv8.prepare("SELECT nextval('seq_col_" + collection + "') AS id");
        });
    }
    catch(err)
    {
      if (err == 'Error: relation "seq_col_' + collection  + '" does not exist')
        {
        var create_collection = plv8.find_function("create_collection");
        res = create_collection(collection);
        seq = plv8.prepare("SELECT nextval('seq_col_" + collection + "') AS id");
        }
    }

    var rows = seq.execute([ ]);
      
    id = rows[0].id;
    obj._id = id;

    seq.free();
    
    var insert = plv8.prepare("INSERT INTO col_" + collection +
      "  (col_" + collection + "_id, data) VALUES ($1, $2)", [ 'int', 'json']);
    insert.execute([ id, JSON.stringify(obj) ]);
    insert.free();
  } else {
    var update = plv8.prepare("UPDATE col_" + collection +
      " SET data = $1 WHERE col_" + collection + "_id = $2", [ 'json', 'int' ]);
    update.execute([ data, id ]);
  }

  return true;
$$ LANGUAGE plv8 IMMUTABLE STRICT;
