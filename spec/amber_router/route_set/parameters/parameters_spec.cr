require "../../../spec_helper"

describe "parameters" do
  it "renders parameters from the route into the response" do
    router = build do
      add "/get/name/:name/", :parametric_route
    end

    result = router.find("/get/name/robert_paulson")
    result.params.should eq({"name" => "robert_paulson"})
  end
end
