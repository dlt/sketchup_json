require "spec_helper"

describe "JSON Generator" do
  
  it "should generate json from strings" do
    "text".to_json.should == '"text"'
    'nested "quotes"'.to_json.should == '"nested \"quotes\""'
  end

  it "should generate json from integers" do 
    1.to_json.should == "1"
    10000.to_json.should == "10000"
  end

  it "should generate json from numerics" do
    1.4901.to_json.should == "1.4901"
  end

  it "should generate json from booleans" do
    true.to_json.should == "true"
    false.to_json.should == "false"
    nil.to_json.should == "null"
  end

  it "should generate json from arrays" do
    [1, 2, 3].to_json.should == "[1, 2, 3]"
    ["oi", "como", "vai?"].to_json.should == '["oi", "como", "vai?"]'
  end

  it "should generate json from hashes" do
    { "text" => "text", "array" => [1, 2, 3] }.to_json.should == '{"text" : "text", "array" : [1, 2, 3]}'
    { :ratio => 1.534 }.to_json.should == '{"ratio" : 1.534}'
    lambda { { 6 => [] }.to_json }.should raise_exception SketchUpJSON::JSONEncodeError
  end
end
