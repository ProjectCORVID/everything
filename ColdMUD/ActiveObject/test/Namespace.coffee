exports = ({assert, suite, test, lib} = {}) ->
  suite 'Namespace', (suite, test) ->
    { Namespace } = lib 'Namespace'

    test 'basics', ->
      root = new Namespace 'root'
      root.add 'testing', 'foo', 'bar'

    root = new Namespace 'root'
    root.add 'testing', 'foo', 'bar'

    test 'auto-vivification', ->
      assert       root::foo
      assert       root::foo::bar
      assert.equal root::foo::bar, 'testing'

    test 'no accidental overwrites', ->
      assert.throws -> root.add 'testing', 'foo'

    test 'overwrites of branches never OK', ->
      assert.throws -> root.add 'whatever', 'foo'

    test 'intentional overwrites OK if key is not a Namespace', ->
      root.set 'not baz', 'foo', 'bar'
      assert.equal root::foo::bar, 'not baz'

exports require '.' if require.main is module
