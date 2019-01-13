Object.assign module.exports,
  createCall: (info = {}) ->
    { methodName
      self
      args = []
    } = info

    switch
      when methodName and self then (more)       -> self[methodName].call self, args..., more...
      when methodName          then (self)       -> self[methodName].call self, args...
      when self                then (methodName) -> self[methodName].call self, args...

