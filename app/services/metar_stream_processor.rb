# frozen_string_literal: true

# Processes a stream of METAR reports
class MetarStreamProcessor
  # Initializes the processor with a repository and parser
  #
  # @param repository [MetarReportRepository] the repository to store processed data
  # @param parser [MetarParserService] the parser to parse METAR reports
  def initialize(repository: MetarReportRepository.new, parser: MetarParserService.new)
    @repository = repository
    @parser = parser
  end

  # Processes a stream of METAR reports
  #
  # @param input [IO] the input stream (defaults to STDIN)
  # @param display_interval [Integer] how often to display stats (in number of reports)
  # @param silent [Boolean] whether to suppress output
  def process_stream(input = $stdin, display_interval: 1000, silent: false)
    count = 0
    input.each_line do |line|
      process_report(line.chomp)
      count += 1
      display_stats if !silent && (count % display_interval).zero?
    end
    display_stats(final: true) unless silent
  end

  # Processes a single METAR report
  #
  # @param raw_report [String] the raw METAR report string
  def process_report(raw_report)
    report_data = @parser.parse(raw_report)
    @repository.update(report_data[:icao_code], report_data[:wind_speed])
  end

  # Retrieves all stats from the repository
  #
  # @return [Array<Hash>] an array of stats for each airport
  def get_stats
    @repository.get_all_stats
  end

  private

  # Displays the current stats
  #
  # @param final [Boolean] whether this is the final report
  def display_stats(final: false)
    puts final ? 'Final Report:' : 'Running Tally:'
    get_stats.each do |stat|
      puts "#{stat[:icao_code]}: Avg: #{stat[:average_speed].round(2)} MPS, Current: #{stat[:current_speed]} MPS"
    end
    puts "\n"
  end
end