class InstagramItem < ActiveRecord::Base
  validates_uniqueness_of :instagram_id
  validates_presence_of :instagram_id, :created_time, :full_data,
                        :latitude, :longitude, :distance_from_center_in_meters,
                        :username, :user_id, :link, :path, :instagram_type

  before_validation(on: :create) do
    set_path
    set_distance_from_center_in_meters
  end

  serialize :full_data

  reverse_geocoded_by :latitude, :longitude

  scope :distance_less_than, ->(dist) {
    where("distance_from_center_in_meters < ?", dist.to_f) if dist.present?
  }

  LATITUDE = ENV['LATITUDE'].to_f
  LONGITUDE = ENV['LONGITUDE'].to_f
  CENTER_COORDINATES = [LATITUDE, LONGITUDE]
  INSTAGRAM_MAX_ALLOWED_DISTANCE = 5_000
  MAX_DISTANCE_IN_METERS = [ENV['MAX_DISTANCE_IN_METERS'].to_f, INSTAGRAM_MAX_ALLOWED_DISTANCE].min.to_f
  METERS_PER_MILE = 5280 * 12 * 2.54 / 100

  REQUIRED_CONFIG_VARS = %w(LATITUDE LONGITUDE MAX_DISTANCE_IN_METERS INSTAGRAM_CLIENT_ID)
  MISSING_CONFIG_VARS = REQUIRED_CONFIG_VARS.select { |k| ENV[k].blank? }

  class << self
    def fetch(opts = {})
      opts.reverse_merge!(distance: MAX_DISTANCE_IN_METERS)
      Instagram.client.media_search(LATITUDE, LONGITUDE, opts)
    end

    def fetch_and_save(opts = {})
      fetch(opts).each do |media|
        create do |item|
          item.full_data = media
          item.instagram_id = media.id
          item.created_time = Time.zone.at(media.created_time.to_i)
          item.username = media.user.username
          item.user_id = media.user.id
          item.link = media.link
          item.latitude = media.location.latitude
          item.longitude = media.location.longitude
          item.instagram_type = media.type
          item.filter = media.filter
        end
      end
    end

    def backfill_items(opts = {})
      max_timestamp = opts.fetch(:max_timestamp, Time.zone.now)
      number_of_pages = opts.fetch(:max_number_of_pages, 10)
      stop_time = opts[:stop_at_timestamp].to_i

      number_of_pages.times do
        return if stop_time > 0 && max_timestamp.to_i > stop_time

        puts [max_timestamp, Time.zone.at(max_timestamp)].join("\t")

        items = fetch_and_save(max_timestamp: max_timestamp.to_i)
        max_timestamp = items.last.created_time.to_i
      end
    end
  end

  def self.find_by_path(path)
    super(path.sub(/\/+$/, ''))
  end

  def image?
    instagram_type == "image"
  end

  def video?
    instagram_type == "video"
  end

  def caption_text
    full_data.caption.try(:text).presence
  end

  def extra_tags
    tags_in_caption = Twitter::Extractor.extract_hashtags(caption_text.to_s.downcase)
    full_data.tags.reject { |t| tags_in_caption.include?(t) }
  end

  def caption_text_with_extra_tags
    base = caption_text.to_s.dup

    if (extras = extra_tags).present?
      base << "\n\n" if base.present?
      base << extras.map { |t| "##{t}" }.join(" ")
    end

    base.presence
  end

  private

  def set_path
    self.path = URI.parse(link).path.to_s.sub(/\/+$/, '')
  end

  def set_distance_from_center_in_meters
    self.distance_from_center_in_meters = distance_from(CENTER_COORDINATES) * METERS_PER_MILE
  end
end
