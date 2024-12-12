# frozen_string_literal: true

# Service for processing METAR reports and managing their data
class MetarStreamService
  def initialize(parser: MetarParserService.new, repository: MetarReportRepository.new)
    @parser = parser
    @repository = repository
  end

  def process_file(filename)
    File.foreach(filename) do |line|
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
end