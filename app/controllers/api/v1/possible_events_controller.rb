# frozen_string_literal: true

# hotfixing load order leading to 'uninitialized constant' error
require_dependency "app/concepts/api/v1/possible_events/representer"

# NON-JSON-API getter for all currently possible events of a model
module API::V1
  class PossibleEventsController < API::V1::BackendController
    respond_to :json

    def show
      instance =
        params[:model].underscore.camelize.constantize.find(params[:id])
      render json: API::V1::PossibleEvents::Show.new(instance)
    end
  end
end
