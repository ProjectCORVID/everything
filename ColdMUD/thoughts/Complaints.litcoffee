# ECMAScript default globals are unnecessarily noisy/untidy

I expect this is for historical reasons. Removing the noise would break something.

Examples:


		Object.getOwnPropertyNames Object::

    # =>
		[
			'__defineGetter__'     ,
			'__defineSetter__'     ,
			'__lookupGetter__'     ,
			'__lookupSetter__'     ,
			'__proto__'            ,
			'hasOwnProperty'       ,
			'isPrototypeOf'        ,
			'propertyIsEnumerable' ,
			'toLocaleString'			 ,
			'toString'             ,
			'valueOf'              ,
		  'constructor'
		]

Almost all of the above are obsolete:
`__{define,lookup}{G,S}etter__` are obsoleted by Object.defineProperties and
Object.getOwnPropertyDescriptors. `__proto__` is obsoleted by
Object.getPrototypeOf. Etc. The exceptions are:

- toString
- valueOf
- constructor

# So what

I could come up with my own defaults which suit my tastes:

    merge = (args...) -> Object.assign {}, args...
    { create, defineProperties } = Object

    global.ECMAObject = global.Object

    Object = create null
    defineProperties Object,

    Class = merge create Object,
      comment: '''
          I am THE class object. My instances are the classes of the system. I
          provide information commonly attributed to classes: namely, the
          class name, class comment (you wouldn’t be reading this if it
          weren’t for me), a list of the instance variables of the class, and
          the class category.
        '''


		MetaClass = merge Object.create Class,
      comment: '''
          I am the root of the class hierarchy. My instances are metaclasses,
          one for each real class. My instances have a single instance, which
          they hold onto, which is the class that they are the metaclass of. I
          provide methods for creation of actual class objects from metaclass
          object, and the creation of metaclass objects, which are my
          instances.  If this is confusing to you, it should be...the
          Smalltalk metaclass system is strange and complex.
        '''


# Problems to investigate

How to disallow overrides?
- Override Object.create to detect and prevent them?

