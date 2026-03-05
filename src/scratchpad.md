```rust
struct String {}

trait Magic: Copy {}
impl<T: Magic> Magic for T {}

fn foo<T: Magic>() {
    assert<T: Copy>();
}

fn main() {
    foo::<String>();
}
```

```rust
struct String {}

trait Magic: Copy {}
impl a<T: Magic> Magic for T {}

impl b Copy for String {}

fn foo<T>()
where
    T: Magic,
{
    assert<T: Copy>();
}

fn main() {
    foo::<String>()
    where
        (a<String> where a<String>, b);
}
```

how Niko is thinking about it

```rust
struct String {}

trait Magic: Copy {}
impl a<T: Magic> Magic for T {}


fn foo<T>()
where
    T: Magic, // <-- to prove this, caller need to provide proof for `T: Magic` + its supertraits (`T: Copy`)
{
    assert<T: Copy>();
}

fn main() {
    foo::<String>()
    where
        (a<String> where a<String>, a);
        //                          ^ error, this is an impl of Magic, not Copy
}
```

```rust
struct String {}

trait Magic: Copy {}
impl a<T: Magic> Magic for T {}
fn a_impl<T>(dict: MagicDict<T>) -> MagicDict<T> {
    MagicDict {
        copy_dict: dict.copy_dict
    }
}

fn foo<T>()
where
    T: Magic, // <-- to prove this, caller need to provide proof for `T: Magic` + its supertraits (`T: Copy`)
{
    assert<T: Copy>();
    // would use `magic_dict.copy_dict`
}

fn main() {
    foo::<String>();
    // dictionary provider would be
    co-fix string_magic() -> MagicDict<String> {
        a_impl(string_magic())

        // inlining gives us
        MagicDict {
            copy_dict: string_magic().copy_dict
            //~^ error: unguarded recusion
        }
    }
}
```



```rust
struct String {}

trait Magic: Copy {}
impl a<T: Magic> Magic for T {}
fn a_impl<T>(dict: MagicDict<T>) -> MagicDict<T> {
    MagicDict {
        copy_dict: dict.copy_dict
    }
}

impl Copy for String {}

fn foo<T>()
where
    T: Magic, // <-- to prove this, caller need to provide proof for `T: Magic` + its supertraits (`T: Copy`)
{
    assert<T: Copy>();
    // would use `magic_dict.copy_dict`
}

fn main() {
    foo::<String>();
    // dictionary provider would be
    co-fix string_magic() -> MagicDict<String> {
        a_impl(string_magic())

        // inlining gives us
        MagicDict {
            copy_dict: string_magic().copy_dict
            //~^ error: unguarded recusion
        }
        // more inlining
        MagicDict {
            copy_dict: MagicDict {
                copy_dict: string_magic().copy_dict   
            }.copy_dict
        }
        // reduces to
        MagicDict {
            copy_dict: string_magic().copy_dict, // no progress
        }
    }
}
```
Is that a problem? :3

```rust
struct List<T> {
    next: List<T>,
}

impl<T> Send for List<T>
where
    List<T>: Send,
{}
// dict
impl fn a_impl<T>(_unused: SendDict<List<T>>) -> SendDict<List<T>> {
    SendDict {
        _unused,
    }
}
 
impl Send for String {}
fn foo<T: Send>() {}
fn main() {
    foo::<List<String>>();
    // dictionary provider:
    co-fix list_string_send() -> SendDict<List<String>> {
        a_impl(list_string_send())
        // inlining
        SendDict {
            _unused: list_string_send(),
            // guarded recursion: ok
        }
    }
}
```

```rust
auto trait Foo {}
auto trait Bar: Foo {}

struct List<T> {
    next: List<T>,
}

impl<T> Bar for List<T>
where
    List<T>: Bar,
{}
// two valid ways to build dict, one makes it unusable, one does not
//
// is there sometimes *not* a best choice? unknown.

impl<T> Foo for List<T>
where
    List<T>: Foo,
{}
```

```rust
struct String {}

trait Magic: Copy {}
impl a<T: Magic> Magic for T {}
fn a_impl<T>(wc: MagicVtable<T>) -> MagicVtable<T> {
    MagicVtable {
        copy: wc.copy,
    }
}

impl b Copy for String {}

fn foo<T>()
where
    T: Magic, // <-- to prove this, caller need to provide proof for `T: Magic` + its supertraits (`T: Copy`)
{
    assert<T: Copy>();
    // would use `magic_dict.copy_dict`
}

fn main() {
    foo::<String>();
    // ^ lcnr would like this to work
}

co-fix magic_string() -> MagicVtable<T> {
    a(magic_string()) => 

    MagicVtable { copy: magic_string().copy } => 

    MagicVtable { copy: MagicVtable { copy: magic_string().copy }.copy } normalize
    MagicVtable { copy: magic_string().copy } // no progress, would have to inject the `b` impl here
}
```


```rust
trait IsUnit {
    type Unit;
}
impl<T> IsUnit for T {
    type Unit = ();
}

trait Trait {
    type Assoc;
}
impl<T: IsUnit<Unit = ()>> Trait for T {
    type Assoc = T;
}

fn inner<T>(x: <T as Trait>::Assoc) {
    let _: T = x;
}
fn caller<T: IsUnit>(x: <T as Trait>::Assoc) {
    inner(x);
}
```

---


Niko's current implied bounds design:

"Bounds with privacy"

```rust
trait Foo<U: Ord>: Bar {

}
```







```rust
auto trait Foo {}
auto trait Bar: Foo {}

struct List<T> {
    next: Element<T>,
}

// AUTO GENERATED:
impl a<T> Bar for List<T>
where
    Element<T>: Bar,
{
    fn(wc: BarVtable<Element<T>>) -> BarVtable<List<T>> {
        BarVtable { foo: b<T>(wc.foo) }
    }
}
impl b<T> Foo for List<T>
where
    Element<T>: Foo,
{
    fn(foo: FooVtable<Element<T>>) -> FVtable<List<T>> {
        FooVtable { _unused: foo }
    }

}

struct Element<T> {
    next: List<T>,
}

// MANUALLY WRITTEN:
impl c Foo for Element<String> where List<String>: Foo {
    fn(wc: FooVtable<List<String>>) -> FooVtable<Element<String>> {
        FooVtable { _unused: wc }
    }
}
impl d Bar for Element<String> where List<String>: Bar {
    fn(wc: BarVtable<List<String>>) -> BarVtable<Element<String>> {
        BarVtable { foo: c(wc.foo) }
    }
}
// impl e<T> Bar for Element<T> where List<T>: Bar {
//     fn(wc: BarVtable<List<T>>) -> BarVtable<Element<T>> {
//         BarVtable { foo: /* can't get what we need from the wc */ }
//     }
// }

fn prove_bar_list_string() -> BarVtable<List<String>> {
    a(d(prove_bar_list_string()))

    BarVtable { foo: FooVtable { _unused: FooVtable { _unused: prove_bar_list_string().foo } } }
    // expand below!


    // Niko tries

    a(d(prove_bar_list_string())) =>

    BarVtable { foo: b<T>(
        d(prove_bar_list_string())
    .foo) } =>

    BarVtable { foo: FooVtable { _unused: d(prove_bar_list_string()) } } =>
    
    BarVtable { foo: FooVtable { _unused: BarVtable { foo: c(prove_bar_list_string().foo) } } } =>

    BarVtable { foo: FooVtable { _unused: BarVtable { foo: FooVtable { _unused: prove_bar_list_string().foo } } } } =>

    BarVtable { foo: FooVtable { _unused: BarVtable { foo: FooVtable { _unused: 
        BarVtable { foo: FooVtable { _unused: BarVtable { foo: FooVtable { _unused: 
            prove_bar_list_string().foo
        } } } }.foo
    } } } } =>

    BarVtable { foo: FooVtable { _unused: BarVtable { foo: FooVtable { _unused: 
        FooVtable { _unused: BarVtable { foo: FooVtable { _unused: 
            prove_bar_list_string().foo
        } } }
    } } } }
}

fn prove_bar_list_string_helper() -> FooVtable<Element<String>> {
    prove_bar_list_string().foo

    => FooVtable { _unused: BarVtable { foo: FooVtable { _unused: 
            prove_bar_list_string_helper()
    } } }
}
```