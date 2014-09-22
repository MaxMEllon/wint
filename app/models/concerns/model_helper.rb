
module ModelHelper
  def decode_json(text)
    ActiveSupport::JSON.decode text
  end

  def encode_json(object)
    ActiveSupport::JSON.encode object
  end

  module_function :decode_json, :encode_json
end

