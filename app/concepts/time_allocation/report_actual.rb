# frozen_string_literal: true

class TimeAllocation::ReportActual < Trailblazer::Operation
  step :dynamic_find_model
  step Policy::Pundit(TimeAllocationPolicy, :report_actual?)

  step Contract::Build()
  step Contract::Validate()
  step Contract::Persist()

  extend Contract::DSL
  contract do
    property :actual_wa_hours
    property :actual_wa_comment
    validates :actual_wa_hours, presence: true, numericality: true
  end

  def dynamic_find_model(options, params:, current_user:, **)
    options['model'] = TimeAllocation::DynamicFind.new(
      *essential_parameters(params, current_user)
    ).find_or_initialize
  end

  def essential_parameters(params, current_user)
    [current_user.id, params[:year], params[:week_number]]
  end
end
