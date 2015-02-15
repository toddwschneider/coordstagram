class ApplicationController < ActionController::Base
  before_filter :ensure_necessary_config
  protect_from_forgery with: :exception
  layout ->(controller) { controller.request.xhr? ? false : "application" }

  private

  def ensure_necessary_config
    render 'setup' if InstagramItem::MISSING_CONFIG_VARS.present?
  end
end
