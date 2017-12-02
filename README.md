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

## Contributing

Contributions are welcome. Please fork the repository, commit changes on a branch, and then open a pull request.
