require "spec_helper"
include SketchUpJSON

describe "JSON parser" do
  it "should parse keywords" do
    Parser.new("true").parse.should be_true
    Parser.new("false").parse.should be_false
    Parser.new("null").parse.should be_nil

    lambda { Parser.new("puts").parse }.should raise_exception SketchUpJSON::SyntaxError
  end

  it "should parse numbers" do
    Parser.new("1").parse.should == 1
    Parser.new("10").parse.should == 10
    Parser.new("12345").parse.should == 12345
    Parser.new("1.1").parse.should == 1.1
    Parser.new("0.1234").parse.should == 0.1234
    Parser.new("-1").parse.should == -1
    Parser.new("-0.98").parse.should == -0.98
    Parser.new("0.2e1").parse.should == 0.2e1
    Parser.new("0.2e+1").parse.should == 0.2e+1
    Parser.new("0.2e-1").parse.should == 0.2e-1
    Parser.new("0.2e1").parse.should == 0.2E1
  end

  it "should parse arrays" do
    Parser.new("[]").parse.should == []
    Parser.new("[1]").parse.should == [1]
    Parser.new("[1, 3, 4]").parse.should == [1, 3, 4]
    Parser.new("[null, true, false, []]").parse.should == [nil, true, false, []]
    Parser.new("[[], {}, 1]").parse.should == [[], {}, 1]

    lambda { Parser.new("[;]").parse }.should raise_exception SketchUpJSON::SyntaxError
  end

  it "should parse objects" do
    Parser.new("{}").parse.should == {}
    Parser.new(%Q[{ "number" : 1, "text" : "text"}]).parse.should == { 'number' => 1, 'text' => 'text' }
    Parser.new(%Q[{ "array" : [], "object" : {}}]).parse.should == { 'array' => [], 'object' => {} }
    Parser.new(%Q[{ "array" : [1, 2, 3], "null" : null}]).parse.should == { 'array' => [1, 2, 3], 'null' => nil  }
    
    lambda { Parser.new(%Q[{ "t" : }]).parse }.should raise_exception SketchUpJSON::SyntaxError
  end

  it "should parse strings" do
    Parser.new('""').parse.should == ""
    Parser.new('"hello world"').parse.should == "hello world"
    Parser.new('"    "').parse.should == "    "
    Parser.new('"abracadabra666"').parse.should == "abracadabra666"
    Parser.new('" }:8)"').parse.should == " }:8)"
    Parser.new('"nested \"quotes\""').parse.should == "nested \"quotes\""
    Parser.new('"\u005C"').parse.should == "\\"
    Parser.new('"\u0022"').parse.should == '"'
    Parser.new('"\u002F"').parse.should == "/"
    Parser.new('"\u0008"').parse.should == "\b"
    Parser.new('"\u000C"').parse.should == "\f"
    Parser.new('"\u000A"').parse.should == "\n"
    Parser.new('"\u000D"').parse.should == "\r"
    Parser.new('"\u0009"').parse.should == "\t"
  end

  it "should parse BIG json strings" do
    parsed = Parser.new(read_fixture_contents("so-alltags.json")).parse
    parsed['total'].should == 29199
    parsed['tags'].size.should == 70
  end

  it "should raise an exception when trying to parse a malformed json string" do
    lambda { Parser.new('{{{{}').parse }.should raise_exception SketchUpJSON::SyntaxError
    lambda { Parser.new('}{}').parse }.should raise_exception SketchUpJSON::SyntaxError
    lambda { Parser.new('}[]}').parse }.should raise_exception SketchUpJSON::SyntaxError
    lambda { Parser.new('{[[[}').parse }.should raise_exception SketchUpJSON::SyntaxError
  end
end
