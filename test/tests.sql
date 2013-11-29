CREATE OR REPLACE FUNCTION mongolike_tests ( ) RETURNS
json AS $$

var test_statuses = [ ];

function fail (actual, expected, message, operator) {
  test_statuses.push({
    actual:   actual,
    expected: expected,
    message:  message,
    operator: operator,
    status:  "fail"
  });
}

function ok (actual, expected) {
  test_statuses.push({
    actual:   actual,
    expected: expected,
    status:   "pass"
  });
}

var assert = {
  equal: function (actual, expected, message) {
    if (actual != expected) {
      fail(actual, expected, message, "==");
    } else {
      ok(actual, expected);
    }
  }
};

function execute (sql, args) {
  var plan = plv8.prepare(sql);

  var status = true;
  try {
    plv8.subtransaction(function ( ) {
      rows = plan.execute(args ? args : [ ]);
    });
  } catch(err) {
    test_statuses.push({
      status: "fail",
      error:  "Unable to create collection"
    });

    status = false;
  }

  plan.free();

  return status;
}

function test_setup ( ) {
  plv8.execute("SELECT create_collection('test')");
}

function test_teardown ( ) {
  plv8.execute("SELECT drop_collection('test')");
}

var tests = [
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
    },
    teardown: function ( ) {
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    },
    'save should work': function ( ) {
      var result = plv8.execute("SELECT * FROM test");
      assert.equal(result.length, 1, "save should work");
    }
  }
];

test_setup();

for (var i = 0; i < tests.length; i++) {
  var test = tests[i];
  var keys = Object.keys(test).filter(function (item) {
    if (item === "setup" || item === "teardown") {
      return false;
    }

    return true;
  });

  // run the setup
  if (test.setup) {
    test.setup();
  }

  // run the tests
  for (var j = 0; j < keys.length; j++) {
    test[i]();
  }

  // run the teardown
  if (test.teardown) {
    test.teardown();
  }
}

test_teardown();

return test_statuses;
$$ LANGUAGE plv8 IMMUTABLE STRICT;