# frozen_string_literal: true

module RemoteShow
  # def redirect_to_remote_show controller, identifier
  #   instance = model_instance params
  #   redirect_to RemoteShow.build_preview_link(controller, identifier, instance)
  # end

  def self.build_preview_link controller, instance
    host = Rails.application.secrets.frontend_host
    "#{host}/preview/#{controller}/#{instance.slug}"
  end

  # private
  #
  # def model_instance params
  #   klass = params[:controller].classify.constantize
  #   klass.find(params[:id])
  # end
end
