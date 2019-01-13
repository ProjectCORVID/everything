Since we're creating an Object Oriented programming system within another
Object Oriented programming system, it's easy to get confused about what kind
of object, method, etc we're talking about. To help with this we're naming the
contexts:

# The Matrix

The insides of apps written on top of ColdPress are The Matrix. Objects in the
apps are vertices, references are edges, etc. This is where the ColdPress
Object Protocol is used but not directly exposed.

# The Substrate

The ColdPress API as experienced by apps built on it is the Substrate. Objects
are (building) blocks, references are glue, etc. This is where the ColdPress
Object Protocol is exposed.

# The Engine

The CoffeeScript and such which implement The Substrate are "Under the Hood"
and use normal terms such as Object and Method. This is where the ColdPress
Object Protocol is implemented.
