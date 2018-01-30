# frozen_string_literal: true

class Offer::ChangeState < Trailblazer::Operation
  step Model(::Offer, :find_by)
  step Policy::Pundit(PermissivePolicy, :change_state?)

  step ::Lib::Macros::State::Contract(Offer::Contracts::Update)
  step Contract::Build()
  step Contract::Validate()
  step :send_event! # Attention: This does not translate!

  def send_event!(options, model:, event:, **)
    options['before_state'] = model.aasm_state
    if model.respond_to?("may_#{event}?") && model.send("may_#{event}?")
      model.send :"#{event}!"
    else
      options['contract.default'].errors.add(
        :base, "Event `#{event}` couldn't be processed"
      )
      false
    end
  end
end
