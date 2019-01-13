# ColdPress

ColdMUD in Coffee

# Cold Object Protocol (COP)

## Objects

- COP
  - The protocol itself handles low-level operations which should only be visible to $sys

  - Some methods
    - .create() => an object handle
    - .get definerHandle, names...
    - .set definerHandle, {[name]: value, ...}
    - .lookupName name => an object handle OR undefined
    - .addParent    handle,  parentHandle
    - .removeParent handle,  parentHandle
    - .setParents   handle, [parentHandles...]

  - Object handles
    - Primitive COP operations take object handles as arguments to identify the entities to be operated on
    - This aspect of the protocol exists to allow us to protect privileged state in the future
    - In the short term, such handles will be the objects themselves

## Implementation details


