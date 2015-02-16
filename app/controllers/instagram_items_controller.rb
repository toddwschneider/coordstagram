class InstagramItemsController < ApplicationController
  include ApplicationHelper

  skip_before_filter :ensure_necessary_config, only: :setup

  def index
    @page = params.fetch(:page, 1).to_i

    @items = InstagramItem.distance_less_than(filter_distance).
                           order("created_time desc").
                           limit(per_page).
                           offset((@page - 1) * per_page)
  end

  def show
    @item = InstagramItem.find_by_path("/#{params[:path]}")

    if @item.blank?
      redirect_to root_url
      return
    end
  end

  private

  def per_page
    mobile_device? ? 24 : 48
  end

  def filter_distance
    params[:d].presence || default_filter_distance
  end

  def default_filter_distance
    ENV.fetch('MAX_DISTANCE_IN_METERS').to_f * 1.1
  end

  def index_cache_key
    [@page, mobile_device?, filter_distance, InstagramItem.maximum(:id)].join(':')
  end
  helper_method :index_cache_key
end
