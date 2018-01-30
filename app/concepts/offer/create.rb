# frozen_string_literal: true

class Offer::Create < Trailblazer::Operation
  include Offer::CommonSideEffects

  step Model(::Offer, :new)
  step Policy::Pundit(PermissivePolicy, :create?)
  step Contract::Build(constant: Offer::Contracts::Create)
  step Contract::Validate()
  step :inject_section_id
  step Wrap(::Lib::Transaction) {
    step ::Lib::Macros::Nested::Find :solution_category, ::SolutionCategory
    step ::Lib::Macros::Nested::Find :divisions, ::Division
    step ::Lib::Macros::Nested::Find :next_steps, ::NextStep
    step ::Lib::Macros::Nested::Create :contact_people, ::ContactPerson::Create
    step ::Lib::Macros::Nested::Create :location, ::Location::Create
    step ::Lib::Macros::Nested::Find :area, ::Area
    step ::Lib::Macros::Nested::Find :tags, ::Tag
    step ::Lib::Macros::Nested::Find :trait_filters, ::TraitFilter
    step ::Lib::Macros::Nested::Find :language_filters, ::LanguageFilter
    step ::Lib::Macros::Nested::Create :target_audience_filters_offers,
                                       ::TargetAudienceFiltersOffer::Create
    step ::Lib::Macros::Nested::Find :openings, ::Opening
    step ::Lib::Macros::Nested::Create :websites, ::Website::Create
  }
  step :set_creating_user
  step Contract::Persist()
  step :generate_slug
  step :set_next_steps_sort_value

  def generate_slug(_, model:, **)
    model.update_column :slug, model.send(:set_slug)
  end

  def inject_section_id(options)
    options['model'].section_id =
      options['contract.default'].divisions.first.section.id
  end

  def set_creating_user(_, current_user:, model:, **)
    model.created_by = current_user.id
  end
end
