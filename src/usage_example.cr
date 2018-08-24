require "./amber_router"

class RouteSetDemonstration
  property route_set

  def initialize
    @route_set = Amber::Router::RouteSet(Symbol).new

    add_route "/get/", :root
    add_route "/get/users/:id", :users
    add_route "/get/users/:id/books", :users_books
    add_route "/get/books/:id", :books
    add_route "/get/books/:id/chapters", :book_chapters
    add_route "/get/books/:id/authors", :book_authors
    add_route "/get/books/:id/pictures", :book_pictures
    add_route "/get/users/:id/pictures(/sorted)", :users_pictures
    add_route "/get/*/slug", :slug
    add_route "/get/products/*slug/reviews", :product_reviews
    add_route "/get/*", :catch_all
  end

  def add_route(path, payload)
    puts "Adding route: #{path} => #{payload}"
    route_set.add path, payload
  end

  def find_and_check(url, expected_payload)
    puts "Routing `#{url}`"
    result = route_set.find(url)
    puts result.found? ? "Found #{result.payload}" : "No Route"

    if result.params.any?
      puts "Params:"
      puts result.params
    end
    puts
    puts
  end
end

RouteSetDemonstration.new.tap do |rsd|
  puts "="*80
  puts "Rendering of route tree:"
  puts "="*80
  puts rsd.route_set.formatted_s
  puts "="*80
  puts
  puts
  rsd.find_and_check "/get/books/23/chapters", :book_chapters
  rsd.find_and_check "/get/very-warm-winter-hat/slug", :slug
  rsd.find_and_check "/get/very/warm/winter/hat/slug", :slug
  rsd.find_and_check "/get/products/very/warm/winter/hat/reviews", :product_reviews
  rsd.find_and_check "/get/spa/yolo", :catch_all
  rsd.find_and_check "/get/users/:id/pictures", :users_pictures
  rsd.find_and_check "/get/users/:id/pictures/sorted", :users_pictures
end
