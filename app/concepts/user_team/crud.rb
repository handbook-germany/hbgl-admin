# frozen_string_literal: true

class UserTeam < ApplicationRecord
  class GeneralContract < Reform::Form
    property :name
    property :users
    property :observing_users
    property :parent
    property :lead

    validates :name, presence: true
    validates :users, presence: true
  end

  class Create < Trailblazer::Operation
    step Model(::UserTeam, :new)
    step Policy::Pundit(::UserTeamPolicy, :create?)

    step Contract::Build(constant: UserTeam::GeneralContract)
    step Contract::Validate()
    step Wrap(::Lib::Transaction) {
      step ::Lib::Macros::Nested::Find(:parent, ::User)
      step ::Lib::Macros::Nested::Find(:lead, ::User)
      step ::Lib::Macros::Nested::Find(:observing_users, ::User)
      step ::Lib::Macros::Nested::Find(:users, ::User)
    }
    step Contract::Persist()
  end

  class Update < Trailblazer::Operation
    step Model(::UserTeam, :find_by)
    step Policy::Pundit(::UserTeamPolicy, :update?)

    step Contract::Build(constant: UserTeam::GeneralContract)
    step Contract::Validate()
    step Wrap(::Lib::Transaction) {
      step ::Lib::Macros::Nested::Find(:parent, ::User)
      step ::Lib::Macros::Nested::Find(:lead, ::User)
      step ::Lib::Macros::Nested::Find(:observing_users, ::User)
      step ::Lib::Macros::Nested::Find(:users, ::User)
    }
    step Contract::Persist()
    step ::Lib::Macros::Live::SendChanges()
  end
end
