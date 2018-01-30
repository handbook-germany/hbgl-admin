# frozen_string_literal: true

class Offer::Update < Trailblazer::Operation
  include Offer::CommonSideEffects

  step Model(::Offer, :find_by)
  step Policy::Pundit(PermissivePolicy, :update?)

  step ::Lib::Macros::State::Contract(
    approve: Offer::Contracts::Approve,
    else: Offer::Contracts::Update
  )

  step Contract::Build()
  step Contract::Validate()
  step :save_section_id
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
  step Contract::Persist()
  step :change_state_side_effect # prevents persist on faulty state change
  step :set_next_steps_sort_value
  step :generate_translations!
  step ::Lib::Macros::Live::SendChanges()

  def save_section_id(options)
    options['model'].section_id =
      options['contract.default'].divisions.first.section.id
  end

  def change_state_side_effect(options, model:, params:, current_user:, **)
    commit = params['meta'] && params['meta']['commit']
    return true unless commit && triggerable_event?(model, commit)
    result = ::Offer::ChangeState.(
      { id: model.id }, 'event' => commit, 'current_user' => current_user
    )
    # add errors of side-effect operation to the errors of this operation
    if result.success?
      options['changed_state'] = true
      options['model'] = result['model']
    else
      add_all_errors(result['contract.default'], options['contract.default'])
    end
    result.success?
  end

  def triggerable_event?(model, potential_event_name)
    model.aasm.events.map(&:name).include?(potential_event_name.to_sym)
  end

  def generate_translations!(opts, changed_state: false, model:, params:, **)
    changes = opts['contract.default'].changed
    fields = model.translated_fields.select { |f| changes[f.to_s] }
    meta = params['meta'] && params['meta']['commit']
    if (meta.to_s == 'approve' && changed_state) || fields.any?
      model.generate_translations! fields.any? ? fields : :all
    end
    true
  end

  ### non-step functions ###

  def add_all_errors(from_contract, to_contract)
    from_contract.errors.each do |key, message|
      to_contract.errors.add(key, message)
    end
  end
end
