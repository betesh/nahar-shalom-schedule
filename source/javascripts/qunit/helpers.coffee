QunitHelpers =
  assertTimeEqual: (assert, actual, expected) ->
    assert.equal actual.format("YYYY-MM-DD hh:mm:ss A"), expected.format("YYYY-MM-DD hh:mm:ss A")

(exports ? this).QunitHelpers = QunitHelpers
