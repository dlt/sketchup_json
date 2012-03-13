module SketchUpJSON
  JSONEncodeError = Class.new(StandardError)
end

class String
  def to_json
    %Q["#{ self.escape_chars }"]
  end

  def escape_chars
    word = self.gsub('\\', '\\\\\\')
    {
      '"' => '\"',
      '/' => '\/',
      "\b" => '\b',
      "\f" => '\f',
      "\n" => '\n',
      "\t" => '\t',
      "\r" => '\r',
    }.each_pair do |before, after|
      word = word.gsub(before, after)
    end
    word
  end
end

class Numeric
  def to_json
    to_s
  end
end

class TrueClass
  def to_json
    to_s
  end
end

class FalseClass
  def to_json
    to_s
  end
end

class NilClass
  def to_json
    "null"
  end
end

class Array
  def to_json
    values = collect { |item| item.to_json }
    "[#{ values.join(", ") }]"
  end
end

class Hash
  def to_json
    values = collect do |k, v|
      validate_key! k
      %Q["#{k.to_s}" : #{v.to_json}]
    end
    "{#{ values.join(", ") }}"
  end

  # In valid json all object keys are strings
  def validate_key!(key)
    unless key.is_a?(String) or key.is_a?(Symbol)
      raise SketchUpJSON::JSONEncodeError, "This hash can not generate valid JSON"
    end
  end
end
