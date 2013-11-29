CREATE OR REPLACE FUNCTION mongolike_tests ( ) RETURNS
json AS $$

// test statuses stored here
var test_statuses = [ ];

// assertion failure
function fail (actual, expected, message, operator) {
  test_statuses.push({
    actual:   actual,
    expected: expected,
    message:  message,
    operator: operator,
    status:  "fail"
  });
}

// assertion ok
function ok (actual, expected, message) {
  test_statuses.push({
    actual:   actual,
    expected: expected,
    status:   "pass",
    message:  message
  });
}

// assert methods
var assert = {
  equal: function (actual, expected, message) {
    if (actual != expected) {
      fail(actual, expected, message, "==");
    } else {
      ok(actual, expected, message);
    }
  }
};


// test_setup is run before any tests run
// create the test collection
function test_setup ( ) {
  plv8.execute("SELECT create_collection('test')");
}

// test_teardown is run after all tests have completed
// remove the collection
function test_teardown ( ) {
  plv8.execute("SELECT drop_collection('test')");
}

// tests to run, setup is run first, then any tests
// teardown is run after the tests are run
var tests = [
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
    },
    teardown: function ( ) {
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    },
    'save should work': function ( ) {
      var result = plv8.execute("SELECT * FROM col_test");
      assert.equal(result.length, 1, "save should work");
    }
  },
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    },
    'remove should work': function ( ) {
      var result = plv8.execute("SELECT * FROM col_test");
      assert.equal(result.length, 0, "remove should work");
    }
  },
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
    },
    'find should work with an empty search': function ( ) {
      var result = plv8.execute("SELECT find('test', '{ }')");
      assert.equal(result.length, 1, "find should work with an empty search");
    },
    teardown: function ( ) {
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    }
  },
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
    },
    'find should work with just a collection': function ( ) {
      var result = plv8.execute("SELECT find('test')");
      assert.equal(result.length, 1, "find should work just a collection");
    },
    teardown: function ( ) {
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    }
  },
  {
    setup: function ( ) {
      plv8.execute("SELECT save('test', '{ \"foo\": \"bar\" }')");
    },
    'find should work with a real search': function ( ) {
      var result = plv8.execute("SELECT find('test', '{ \"foo\": \"bar\" }')");
      assert.equal(result.length, 1, "find should work with a real search");
    },
    teardown: function ( ) {
      plv8.execute("SELECT remove('test', '{ \"foo\": \"bar\" }')");
    }
  }
];

test_setup();

// iterate through the tests, running each
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
    test[keys[j]]();
  }

  // run the teardown
  if (test.teardown) {
    test.teardown();
  }
}

test_teardown();

return test_statuses;
$$ LANGUAGE plv8 IMMUTABLE STRICT;