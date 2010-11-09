lib_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include? lib_path

require "rspec"
require "sketchup_json"

FIXTURES_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))

def read_fixture_contents(file_name)
  File.read(FIXTURES_PATH + "/#{file_name}")
end
