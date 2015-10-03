
module ModelHelper
  def decode_json(text)
    ActiveSupport::JSON.decode(text).deep_symbolize_keys
  end

  def encode_json(object)
    ActiveSupport::JSON.encode object
  end

  def data_root
    "#{Rails.root}/public/data"
  end

  module_function :decode_json, :encode_json, :data_root
end

