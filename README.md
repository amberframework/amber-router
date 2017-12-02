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
router: root   2.51M (398.68ns) (± 5.94%)  1.87× slower
 radix: root   4.69M (213.15ns) (± 6.87%)       fastest


/get/books/23/chapters
router: deep    1.1M (912.59ns) (± 8.47%)       fastest
 radix: deep 995.39k (   1.0µs) (± 2.32%)  1.10× slower


/get/books/23/pages
router: wrong    1.5M (664.99ns) (± 2.98%)       fastest
 radix: wrong   1.24M (806.25ns) (± 1.81%)  1.21× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
router: many segments 266.87k (  3.75µs) (± 5.51%)  5.81× slower
 radix: many segments   1.55M (645.03ns) (± 2.28%)       fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
router: many variables 280.95k (  3.56µs) (± 5.39%)       fastest
 radix: many variables 272.64k (  3.67µs) (± 2.95%)  1.03× slower


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
router: long_segments   1.48M (677.61ns) (± 2.54%)       fastest
 radix: long_segments  895.5k (  1.12µs) (± 5.43%)  1.65× slower
```

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request.
