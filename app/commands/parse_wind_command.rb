# frozen_string_literal: true

# Handles parsing of wind information from METAR reports
class ParseWindCommand
  include MetarErrors

  # Parses the wind information string and returns a hash with the parsed data
  #
  # @param wind_info [String] the wind information string from a METAR report
  # @return [Hash] parsed wind data
  # @raise [InvalidWindInfoError] if the wind info format is invalid
  def execute(wind_info)
    raise InvalidWindInfoError, 'Invalid wind info format' unless wind_info.match?(/^\d{3}\d{2,3}(G\d{2,3})?(KT|MPS)$/)

    direction = wind_info[0..2].to_i
    speed = wind_info[3..4].to_i
    unit = wind_info[-3..] == 'MPS' ? 'MPS' : 'KT'

    gust = nil
    if wind_info.include?('G')
      gust_index = wind_info.index('G')
      gust = wind_info[gust_index + 1, 2].to_i
      speed = wind_info[3...gust_index].to_i if gust_index != 5
    end

    raise InvalidWindInfoError, 'Invalid wind direction' unless (0..360).include?(direction)
    raise InvalidWindInfoError, 'Invalid wind speed' if speed.negative?
    raise InvalidWindInfoError, 'Invalid gust speed' if gust && gust < speed

    {
      wind_direction: direction,
      wind_speed: normalize_speed(speed, unit),
      wind_gust: gust ? normalize_speed(gust, unit) : nil,
      wind_unit: 'MPS'
    }
  end

  private

  # Normalizes wind speed to meters per second (MPS)
  #
  # @param speed [Integer] the wind speed
  # @param unit [String] the unit of the wind speed ('KT' or 'MPS')
  # @return [Float] the normalized wind speed in MPS
  def normalize_speed(speed, unit)
    unit == 'KT' ? speed / 2.0 : speed.to_f
  end
end