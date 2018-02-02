# frozen_string_literal: true

module API::V1
  module Organization
    module Representer
      class Show < Roar::Decorator
        include Roar::JSON::JSONAPI.resource :organizations
        include API::V1::Assignable::Representer

        attributes do
          property :label, getter: ->(organization) do
            organization[:represented].name
          end
          # TODO: make this work correctly!!
          property :offers_count, getter: ->(organization) do
            organization[:represented].offers.count
          end
          # property :offers_count

          property :description
          property :name
          property :priority
          property :comment
          property :aasm_state
          property :locations_count
          property :pending_reason
          property :legal_form
          property :charitable
          property :website_id
          property :mailings
          property :accredited_institution
          # NOTE: do we need this here? or only for create/update or not at all?
          property :location_ids
          property :contact_person_ids
          property :division_ids
          property :umbrella_filter_ids
          property :topic_ids
        end

        # has_one :website do
        #   type :websites
        #   attributes do
        #     property :url
        #   end
        # end

        link(:preview) do
          ::RemoteShow.build_preview_link(:organisationen, represented)
        end
      end

      class Index < Show
        has_many :topics, class: ::Topic do
          type :topics

          attributes do
            property :label, getter: ->(o) { o[:represented].name }
            property :name
          end
        end
      end

      class Create < Index
        has_one :website,
                decorator: API::V1::Website::Representer::Show,
                populator: API::V1::Lib::Populators::FindOrInstantiate,
                class: ::Website

        has_many :divisions,
                 decorator: API::V1::Division::Representer::Create,
                 populator: API::V1::Lib::Populators::FindOrInstantiate,
                 class: ::Division

        has_many :locations,
                 decorator: API::V1::Location::Representer::Create,
                 populator: API::V1::Lib::Populators::FindOrInstantiate,
                 class: ::Location

        has_many :contact_people,
                 decorator: API::V1::ContactPerson::Representer::Create,
                 populator: API::V1::Lib::Populators::FindOrInstantiate,
                 class: ::ContactPerson
      end

      class Update < Create
        has_many :umbrella_filters,
                 decorator: API::V1::Filter::Representer::Show,
                 populator: API::V1::Lib::Populators::Find,
                 class: ::UmbrellaFilter
      end
    end
  end
end
