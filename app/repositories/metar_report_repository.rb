# frozen_string_literal: true

# Repository for managing METAR report data in memory
class MetarReportRepository
  # Struct to hold airport data
  Airport = Struct.new(:average, :count, :current_speed, :last_update)

  # Initializes the repository
  def initialize
    @data = {}
    @prune_threshold = 24.hours # Prune data older than 24 hours
  end

  # Updates the data for a given airport
  #
  # @param icao_code [String] the ICAO code of the airport
  # @param wind_speed [Float] the current wind speed
  def update(icao_code, wind_speed)
    airport = @data[icao_code] ||= Airport.new(0.0, 0, 0.0, Time.now)

    airport.count += 1
    airport.average += (wind_speed - airport.average) / airport.count
    airport.current_speed = wind_speed
    airport.last_update = Time.now

    prune_old_data if rand < 0.01 # 1% chance to prune on each update
  end

  # Gets the average wind speed for a given airport
  #
  # @param icao_code [String] the ICAO code of the airport
  # @return [Float] the average wind speed
  def get_average(icao_code)
    @data[icao_code]&.average || 0.0
  end

  # Gets the current wind speed for a given airport
  #
  # @param icao_code [String] the ICAO code of the airport
  # @return [Float] the current wind speed
  def get_current_speed(icao_code)
    @data[icao_code]&.current_speed || 0.0
  end

  # Gets statistics for all airports
  #
  # @return [Array<Hash>] array of hashes containing stats for each airport
  def get_all_stats
    @data.map do |icao_code, airport|
      {
        icao_code: icao_code,
        average_speed: airport.average,
        current_speed: airport.current_speed
      }
    end
  end

  private

  # Removes data older than the prune threshold
  def prune_old_data
    threshold = Time.now - @prune_threshold
    @data.delete_if { |_, airport| airport.last_update < threshold }
  end
end