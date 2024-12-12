# frozen_string_literal: true

class MetarStreamProcessor
  def initialize(repository: MetarReportRepository.new, parser: MetarParserService.new)
    @repository = repository
    @parser = parser
  end

  def process_stream(input = $stdin)
    input.each_line do |line|
      process_report(line.chomp)
    end
  end

  def process_report(raw_report)
    report_data = @parser.parse(raw_report)
    @repository.update(report_data[:icao_code], report_data[:wind_speed])
  end

  def get_stats
    @repository.get_all_stats
  end

  def process_stream(input = $stdin, display_interval: 1000)
    count = 0
    input.each_line do |line|
      process_report(line.chomp)
      count += 1
      display_stats if count % display_interval == 0
    end
    display_stats(final: true)
  end

  private

  def display_stats(final: false)
    puts final ? 'Final Report:' : 'Running Tally:'
    get_stats.each do |stat|
      puts "#{stat[:icao_code]}: Avg: #{stat[:average_speed].round(2)} MPS, Current: #{stat[:current_speed]} MPS"
    end
    puts "\n"
  end
end
