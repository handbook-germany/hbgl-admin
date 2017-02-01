# frozen_string_literal: true
module JsonapiTestUtils
  def to_jsonapi(param_hash, type, id = nil)
    hash = {
      data: {
        type: type,
        attributes: param_hash
      }
    }
    hash[:data][:id] = id if id
    hash.to_json
  end
end