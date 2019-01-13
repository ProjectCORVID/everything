# On core definition language

Core modules will be processed in a context which eliminates boilerplate.

    isa $parent, $otherParent

    has propName: kind

    does
      methodName: (arg) ->
        get 'propName'
        propName = arg
        set {propName}



# Thinking about improving the DSL aspects of this stuff

## Format options

- verb subject, details
- meta(subject).verb details
- subject[meta].verb details
- META verb: object, details
- META.verb objectName: details

Examples

    cs = require 'coffeescript'

    makeVerb = (name, def) ->
      # This should define a function 'name' whose implementation is defined
      # by 'def'
      cs.eval """
        #{name} = (subject, details) ->
          def #{name}: {subject, details}
      """

# On the topic of CoffeeScript syntax tricks...

    sentance   = verb subject prep object
    # ->
    prepPhrase =              prep object
    subjObj    =      subject prepPhrase
    sentance   = verb subjObj

    # conjunction
    sentance    = verb subject1 conj subject2
    # ->
    partialConj =               conj subject2
    subj        =      subject1 partialConj
    sentance    = verb subj

# Some vocabulary

    goto   'location'
    locate 'subject'


# On globals

Cake has this neat feature where Cakefiles are evaluated in a scope which has
'task' and 'option' defined already. This approach pulls boilerplate out of
the most-edited files but also touches the sacred global namespace.

I want some kind of middle ground...

    (require 'bolerplate') v1_0: global

    foo bar()

This on the first line could serve as a kind of she-bang which both declares
intent and pulls modules into the global scope in a controlled way. Those
wishing to protect the global namespace could use a different variable:

    (require 'bolerplate') v1_0: bp = {}

    bp.foo bp.bar()

And those wishing to declare which parts they intend to use can easily do so:

    {foo, bar} = (require 'bolerplate') v1_0: imported = {}
    
    foo bar()

Another option would be to make the version part of the module path:

    (require 'bolerplate/1.0') global

And the global namespace could be assumed:

    (require 'bolerplate/1.0')()

Or it could just automatically install itself when required the first time:

    require 'bolerplate/1.0'

The problem with that being that it's not optional. Maybe it should be easier
to declare a non-global global?
