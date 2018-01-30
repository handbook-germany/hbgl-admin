# frozen_string_literal: true

require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

module RailsAdminChangeState
end

module RailsAdmin
  module Config
    module Actions
      class ChangeState < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        # There are several options that you can set here.
        # Check https://github.com/sferik/rails_admin
        # /blob/master/lib/rails_admin/config/actions/base.rb for more info.

        register_instance_option :visible? do
          false
        end

        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          proc do
            contract = @object.class::Contracts::ChangeState.new(@object)
            object_valid_for_state_change = contract.valid?
            # NOTE Hacky hack hack: allow forced state-change to checkup and
            # edit for invalid objects (e.g. expired offers are invalid)
            if !object_valid_for_state_change &&
               %w[start_checkup_process return_to_editing].include?(
                 params[:event]
               )
              state = if params[:event] == 'return_to_editing'
                        'edit'
                      else
                        'checkup_process'
                      end
              @object.update_columns(aasm_state: state)
              flash[:success] = t('.success')
            elsif object_valid_for_state_change && @object.send(
              "#{params[:event]}!"
            )
              flash[:success] = t('.success')
              if @object.respond_to?(:generate_translations!) &&
                 params[:event] == 'approve'
                @object.generate_translations!
              end
            else
              error_message = t('.invalid', obj: @object.class.to_s)
              contract.errors.full_messages.each do |message|
                error_message += '<br/>' + message
              end
              # quiet, rubocop.. we won't refactor this
              # rubocop:disable OutputSafety
              flash[:error] = error_message.html_safe
              # rubocop:enable OutputSafety
            end
            redirect_to request.referer
          end
        end
      end
    end
  end
end
