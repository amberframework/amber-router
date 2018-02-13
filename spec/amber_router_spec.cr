require "./spec_helper"

def build
  Amber::Router::RouteSet(Symbol).new.tap do |router|
    router.add "/get", :root
  end
end

def build(&block)
  router = build
  with router yield
  router
end

describe Amber::Router::RouteSet do
  it "resolves the root route" do
    build.find("/get").payload.should eq :root
  end

  it "resolves nested urls" do
    router = build do
      add "/get/books/23/chapters", :book_chapters
    end

    result = router.find "/get/books/23/chapters"
    result.payload.should eq :book_chapters
  end

  it "returns a nil payload for not found urls" do
    router = build

    result = router.find "/get/books/23/pages"
    result.found?.should eq false
    result.payload.should eq nil
  end

  it "routes many segments" do
    router = build do
      add "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", :alphabet
      add "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/f", :almost_alphabet
    end

    result = router.find "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
    result.payload.should eq :alphabet
  end

  it "routes many variables" do
    router = build do
      add "/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z", :variable_alphabet
    end

    result = router.find "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6"
    result.payload.should eq :variable_alphabet
  end

  it "correctly selects routes" do
    router = build do
      add "/get/users/:id",          :users
      add "/get/users/:id/books",    :users_books
      add "/get/books/:id",          :books
      add "/get/books/:id/chapters", :book_chapters
      add "/get/books/:id/authors",  :book_authors
      add "/get/books/:id/pictures", :book_pictures
    end

    router.find("/get/")                 .payload.should eq :root
    router.find("/get/users/3")          .payload.should eq :users
    router.find("/get/users/3/books")    .payload.should eq :users_books
    router.find("/get/books/3")          .payload.should eq :books
    router.find("/get/books/3/chapters") .payload.should eq :book_chapters
    router.find("/get/books/3/authors")  .payload.should eq :book_authors
    router.find("/get/books/3/pictures") .payload.should eq :book_pictures
  end

  it "resolves glob urls" do
    router = build do
      add "/get/products/*", :products_slug
    end

    router.find("/get/products/fancy_hairdoo").payload.should eq :products_slug
  end

  it "resolves glob urls with a suffix" do
    router = build do
      add "/get/products/*/with_name", :products_slug_with_name
    end

    router.find("/get/products/fancy_hairdoo/with_name").payload.should eq :products_slug_with_name
  end

  it "resolves multiple matches by sorting by insertion order" do
    router1 = build do
      add "/get/domains/mine", :my_domains
      add "/get/domains/:id", :a_domain
    end

    router1.find("/get/domains/mine").payload.should eq :my_domains
    router1.find("/get/domains/32").payload.should eq :a_domain


    router2 = build do
      add "/get/domains/:id", :a_domain
      add "/get/domains/mine", :my_domains
    end

    router2.find("/get/domains/mine").payload.should eq :a_domain
    router2.find("/get/domains/32").payload.should eq :a_domain
  end

  it "renders parameters from the route into the response" do
    router = build do
      add "/get/name/:name/", :parametric_route
    end

    result = router.find("/get/name/robert_paulson")
    result.params.should eq({ "name" => "robert_paulson" })
  end

  it "renders glob parameters" do
    router = build do
      add "/get/products/*slug/dp/:id", :product
    end

    result = router.find("/get/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ")
    result.params.should eq({
      "id"   => "B01J7DAMCQ",
      "slug" => "Winter-Windproof-Trapper-Hat",
    })
  end

  it "renders glob parameters which span segments" do
    router = build do
      add "/get/categories/*categories/products", :categories_products
    end

    result = router.find("/get/categories/hats/scarfs/mittens/gloves/products")
    result.params.should eq({
      "categories" => "hats/scarfs/mittens/gloves"
    })
  end

  it "renders a glob parameter which gobbles up the rest of a url" do
    router = build do
      add "/get/*", :spa_route
    end

    result = router.find("/get/products/1")
    result.payload.should eq :spa_route
  end

  it "renders a named glob parameter which gobbles up the rest of a url" do
    router = build do
      add "/get/*url", :spa_route
    end

    router.find("/get/products/1").params.should eq({
      "url" => "products/1"
    })
  end

  it "handles multiple variable length routes nested under a glob" do
    router = build do
      add "/get/*/two/test", :test_two
      add "/get/*/test", :test_one
    end

    router.find("/get/products/test").payload.should eq :test_one
    router.find("/get/products/two/test").payload.should eq :test_two
  end
end
