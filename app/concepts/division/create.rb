# frozen_string_literal: true

require_relative './sync_organization.rb'
class Division::Create < Trailblazer::Operation
  include SyncOrganization
  include Assignable::CommonSideEffects::CreateNewAssignment

  step Model(::Division, :new)
  step Policy::Pundit(PermissivePolicy, :create?)

  step :inject_section
  step Contract::Build(constant: Division::Contracts::Create)
  step Contract::Validate()
  step Wrap(::Lib::Transaction) {
    step ::Lib::Macros::Nested::Create(:websites, Website::Create)
    # step ::Lib::Macros::Nested::Find(:section, ::Section)
    step ::Lib::Macros::Nested::Find(:city, ::City)
    step ::Lib::Macros::Nested::Find(:area, ::Area)
    step ::Lib::Macros::Nested::Find(:organization, ::Organization)
    step ::Lib::Macros::Nested::Find(:presumed_tags, ::Tag)
    step ::Lib::Macros::Nested::Find(
      :presumed_solution_categories, ::SolutionCategory
    )
  }
  step :generate_label # TODO: write tests for this!!
  step Contract::Persist()
  step :create_initial_assignment!
  step :syncronize_organization_approve_or_done_state

  def inject_section(options)
    # NOTE default section - change this for other project!
    options['model'].section = ::Section.find_by(identifier: 'refugees')
  end

  def generate_label(options, model:, **)
    contract = options['contract.default']
    # NOTE: only works of inline creation of division in organization
    orga_or_contract =
      contract.organization || options['nesting_operation']['contract.default']
    model.label = build_label(orga_or_contract.name, contract)
  end

  private

  def build_label(orga_name, contract)
    label = "#{orga_name} (#{contract.section.identifier})"
    label += ", City: #{contract.city.name}" if contract.city
    label += ", Area: #{contract.area.name}" if contract.area
    label += ", Addition: #{contract.addition}" if contract.addition.present?
    label
  end
end
