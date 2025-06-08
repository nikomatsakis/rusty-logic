# Special traits

The most common use for traits in Rust is to define interfaces,
but they are also regularly used as markers to indicate sets of types with a particular property.
Some traits are special in that they have a specific meaning to the Rust compiler,
such as the following:

- The `Copy` trait indicates types whose values can safely be copied by simply copying their bits.
  In logical terms, a value is not affine if its type implements `Copy`.
  The `Copy` trait is implemented like any other trait but, as a special rule,
  the compiler enforces that this is only permitted if all subfields also implement `Copy`.
- The `Send` and `Sync` traits indicate types whose values can safely be sent between threads
  and shared between threads, respectively. 
  The next section discusses how they are implemented.
