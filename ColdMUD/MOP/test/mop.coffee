{ describe, it } = require 'my_node_modules/lib/setup-testing'

describe 'Meta Object Protocol', (describe, it) ->
  { create, MetaClass } = require '../lib/mop'

  global.TestClass = null

  describe 'create verb', (describe, it) ->
    create TestClass: MetaClass

    it 'mutates global', -> assert.equal 'function', typeof global.TestClass

  describe 'class view', (describe, it) ->
    it 'tracks children', ->
      kids = Class(MetaClass).children()

      assert.equal 1, kids.length
      assert.equal kids[0], TestClass

    it 'adds private vars', ->
      Class TestClass
        .addProp testvar: 'default value'
        .on 'newInstance', (instance) ->

      testClass1 = new TestClass
      testClass2 = new TestClass
