desc "get new items"
task :get_new_items => :environment do
  if InstagramItem::MISSING_CONFIG_VARS.present?
    puts "You're missing some config vars: #{InstagramItem::MISSING_CONFIG_VARS.join(', ')}"
    puts "Check out /setup for instructions on how to set them"
    next
  end

  max_timestamp = Time.zone.now
  max_number_of_pages = (ENV['MAX_PAGES_TO_FETCH_PER_UPDATE'].presence || 10).to_i
  stop_at_timestamp = InstagramItem.maximum(:created_time)

  puts "fetching up to #{max_number_of_pages} page(s) from Instagram, starting at #{max_timestamp} and working backward, stopping at #{stop_at_timestamp}"

  InstagramItem.backfill_items(max_timestamp: max_timestamp,
                               max_number_of_pages: max_number_of_pages,
                               stop_at_timestamp: stop_at_timestamp)

  puts "done"
end
