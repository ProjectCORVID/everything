exports = ({assert, suite, test, lib} = {}) ->
  suite 'AO', (suite, test, done) ->
    test 'throws without callback', ->
      assert.throws -> (lib '.')()

    ns = null
    test 'sets up AO', (done) ->
      (lib '.') (AO) ->
        test "something returned"     , -> assert       AO
        test "has a name"             , -> assert.equal typeof AO.name, 'string'
        test "with the right name"    , -> assert.equal AO.name, 'AO'
        test "and a prototype"        , -> assert       AO::
        test "and has 'Namespace'"    , -> assert       AO.has 'Namespace'
        test "and ::Namespace works"  , -> assert       ns = AO::Namespace
        test "and it's a constructor" , -> assert.equal (typeof ns), 'function'
        test "and AO is one"          , -> assert       AO instanceof ns

        done()

    done()

exports require '.' if require.main is module
