QunitHelpers =
  assertTimeEqual: (assert, actual, expected, description) ->
    assert.equal actual.format("YYYY-MM-DD hh:mm:ss A"),
        expected.format("YYYY-MM-DD hh:mm:ss A"),
        "#{description} is at #{expected.format("hh:mm:ss A")}"

(exports ? this).QunitHelpers = QunitHelpers
