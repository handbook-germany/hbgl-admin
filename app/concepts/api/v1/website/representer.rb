# frozen_string_literal: true

module API::V1
  module Website
    module Representer
      class Show < Roar::Decorator
        include Roar::JSON::JSONAPI.resource :websites
        include API::V1::Assignable::Representer

        attributes do
          property :label, getter: ->(website) do
            website[:represented].url
          end
          property :host
          property :url
        end
      end

      class Index < Show
      end
    end
  end
end
