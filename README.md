# Amber/Router

An experimental url router.

## Usage

```crystal
route_set = Amber::Router::RouteSet(Symbol).new
route_set.add "/get/", :root
route_set.add "/get/users/:id", :users
route_set.add "/get/users/:id/books", :users_books
route_set.add "/get/books/:id", :books
route_set.add "/get/books/:id/chapters", :book_chapters
route_set.add "/get/books/:id/authors", :book_authors
route_set.add "/get/books/:id/pictures", :book_pictures
route_set.add "/get/users/:id/pictures", :users_pictures
route_set.add "/get/*/slug", :slug
route_set.add "/get/products/*/reviews", :amazon_style
route_set.add "/get/*", :catch_all

route_set.find("/get/users/3").payload # => :users
route_set.find("/get/users/3/books").payload # => :users_books
route_set.find("/get/books/3").payload #=> :book
```

## Performance

`crystal run src/benchmark.cr --release` produces a comparison of this router and [radix](/luislavena/radix). As of now, this is the comparison:

```
/get/
router: root   1.87M (536.01ns) (±10.28%)  2.39× slower
 radix: root   4.46M ( 224.2ns) (± 9.64%)       fastest


/get/books/23/chapters
router: deep 900.85k (  1.11µs) (± 8.39%)  1.08× slower
 radix: deep 970.57k (  1.03µs) (± 7.37%)       fastest


/get/books/23/pages
router: wrong   1.19M (843.14ns) (± 7.09%)       fastest
 radix: wrong   1.06M (947.58ns) (±10.94%)  1.12× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 257.19k (  3.89µs) (± 7.24%)  5.86× slower
 radix: many segments   1.51M (663.25ns) (± 6.96%)       fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables  175.6k (  5.69µs) (± 4.87%)  1.49× slower
 radix: many variables 260.96k (  3.83µs) (± 4.62%)       fastest


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.16M (862.29ns) (± 5.97%)       fastest
 radix: long_segments 847.65k (  1.18µs) (± 3.00%)  1.37× slower
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request.
