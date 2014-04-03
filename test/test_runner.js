#!/usr/bin/env node

var argv   = require('optimist')
    .usage('Usage: $0')
    .demand('d')
    .alias('d', 'database')
    .describe('d', 'Database to be installed in')
    .default('h', 'localhost')
    .alias('h', 'host')
    .describe('h', 'Database host')
    .default('p', 'password')
    .alias('p', 'password')
    .describe('u', 'User')
    .default('u', 'postgres')
    .alias('u', 'user')
    .describe('spec', 'Use the Spec reporter')
    .default('spec', false)
    .argv,
    pg    = require('pg'),
    color = require("ansi-color").set,
    fs    = require('fs');

var tests = fs.readFileSync(__dirname + '/tests.sql', 'utf8');

var conString = "postgres://" + argv.u + ":" + argv.p + "@" + argv.h + "/" + argv.d;

// verify connectivity
var client = new pg.Client(conString);
client.connect(function (err) {
  if (err) {
    console.error('could not connect to postgres', err.toString());
    return;
  }

  loadTests(client);
});

// [todo] - move tests out of tests.sql and into their own module
function loadTests (client) {
  client.query(tests, function (err) {
    if (err) {
      console.error('could not load tests', err.toString());

      client.end();
      return;
    }

    runTests(client);
  });
}
function runTests (client) {
  client.query("SELECT mongolike_tests()", function (err, results) {
    client.end();

    if (err) {
      console.error('test error', err.toString());

      return;
    }

    if (results && results.rows.length) {
      var data = results.rows[0];
      var keys = Object.keys(data);

      for (var i = 0; i < keys.length; i++) {
        if (argv.spec) {
          specReporter(keys[i], data[keys[i]]);
        } else {
          dotReporter(keys[i], data[keys[i]]);
        }
      }
    } else {
      console.log("No tests");
    }
  });
}

// spec reporter for detailed reporting
function specReporter (name, results) {
  console.log("\n" + name + ":\n");

  for (var i = 0; i < results.length; i++) {
    if (results[i].status === 'pass') {
      console.log("  ✓ " + color(results[i].message, "green"));
    } else {
      console.log("  ✗ " + color(results[i].message, "yellow"));
      console.log("     » " + color("expected " + results[i].expected + ",", "yellow"));
      console.log("     " + color("got " + results[i].actual + "(" + results[i].operator + ")", "yellow"));
    }
  }
}

// simple dot reporter
function dotReporter (name, results) {
  var out = "";
  for (var i = 0; i < results.length; i++) {
    if (results[i].status === 'pass') {
      out += color(".", "green");
    } else {
      out += color("✗", "red");
    }
  }

  console.log(out);
}