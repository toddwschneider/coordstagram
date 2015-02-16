desc "initial backfill: run this once after creating the database"
task :initial_backfill => :environment do
  if InstagramItem::MISSING_CONFIG_VARS.present?
    puts "You're missing some config vars: #{InstagramItem::MISSING_CONFIG_VARS.join(', ')}"
    puts "Check out /setup for instructions on how to set them"
    next
  end

  max_timestamp = Time.zone.now
  number_of_pages = (ENV['PAGES_TO_FETCH_FOR_INITIAL_BACKFILL'].presence || 20).to_i

  puts "fetching #{number_of_pages} page(s) from Instagram, starting at #{max_timestamp} and working backward"

  InstagramItem.backfill_items(max_timestamp: max_timestamp,
                               max_number_of_pages: number_of_pages)

  puts "done"
end
