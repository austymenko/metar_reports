namespace :metar do
  desc "Process METAR reports from a file"
  task :process_reports, [:filename] => :environment do |t, args|
    filename = args[:filename] || 'metar_reports.txt'

    processor = MetarStreamProcessor.new

    puts "Starting to process METAR reports from #{filename}"

    if File.exist?(filename)
      File.open(filename, 'r') do |file|
        processor.process_stream(file)
      end
      puts "Finished processing METAR reports"
    else
      puts "File not found: #{filename}"
    end
  end
end