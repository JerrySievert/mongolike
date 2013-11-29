CREATE OR REPLACE FUNCTION ObjectId () RETURNS
VARCHAR AS $$
  var time = Number((Number(new Date()) / 1000).toFixed(0)).toString(16);

  var res = plv8.execute("SELECT md5(current_database())");
  var machineId = res[0].md5.substring(0, 6);
  plv8.elog(NOTICE, machineId);

  res = plv8.execute("SELECT pg_backend_pid()");
  var processId = Number(res[0].pg_backend_pid).toString(16);

  var rand = Math.floor(Math.random()*16777216).toString(16);

  return time + machineId + processId + rand;
$$ LANGUAGE plv8 IMMUTABLE STRICT;