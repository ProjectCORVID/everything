COP = ColdMUD Object Protocol

COP objects' only public members are methods and even those are wrappers which
enforce the COP method semantics. Methods run in their own sandboxes which are
reset on each invocation. COP objects can only be mutated by themselves or
an owner. Etc.

Protocol operations

- Object mutation
 - add/update/list/remove method(s)
 - add/update/list/remove fields(s)
- Method invocation
 - sandbox construction
  - fields, vars, globals
 - stack frame life cycle

About the method context (sandbox)

- its globals are not the Node globals
 - Object and Reflect are stripped down
  - no setPrototypeOf
 - require() doesn't exist
 - etc
- custom COP globals
 - reserved vars: sender, caller, definer, receiver
 - global objects
  - $root, $sys are like the ones in ColdMUD
  - are all wrapped so that invoking methods on them maintains the stack frames
- the context object's prototype is the instance's field dictionary
 - changes are detected by comparing the sandbox to its prototype?
 - __proto__ and getPrototypeOf are disabled so no way to trick the system

