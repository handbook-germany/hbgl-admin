# frozen_string_literal: true
require_relative './jsonapi_test_utils'
module API
  module ControllerTestUtils
    include JsonapiTestUtils

    def jsonapi_params(additional_params = {})
      { format: 'application/vnd.api+json' }.merge(additional_params)
    end

    def api_get_works_for action, additional_params = {}
      get action, jsonapi_params(additional_params)
      assert_response :success
    end

    def create_works_with klass, params
      set_jsonapi_raw_post(params, klass)
      assert_difference "#{klass.name}.count", 1 do
        post :create, jsonapi_params
      end
      # Validate JSONAPI spec implementation: returns 201 + resource document
      assert_response 201
      response.body.must_include '{"data":{"type":'
    end

    def create_fails_with klass, params
      set_jsonapi_raw_post(params, klass)
      assert_difference "#{klass.name}.count", 0 do
        post :create, jsonapi_params
      end
      # Validate JSONAPI spec implementation: returns Forbidden, error hash
      assert_response 403
      response.body.must_include '{"errors":[{"title":'
    end

    def update_works_with klass, params
      set_jsonapi_raw_post(params, klass)
      assert_difference "#{klass.name}.count", 0 do
        patch :update, jsonapi_params
      end
      assert_response :success
    end

    def set_jsonapi_raw_post(params, klass)
      type = klass.name.tableize
      request.env['RAW_POST_DATA'] = to_jsonapi(params, type)
    end
  end
end