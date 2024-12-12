# frozen_string_literal: true

# Service for parsing METAR report strings
class MetarParserService
  include MetarErrors

  # Regex for matching METAR report format
  METAR_REGEX = /^(\w+)\s+(\d{2})(\d{2})(\d{2})Z\s+(\d{3})(\d{2,3})(G\d{2,3})?(KT|MPS)$/

  # Parses a raw METAR report string
  #
  # @param raw_report [String] the raw METAR report string
  # @return [Hash] parsed METAR data
  # @raise [InvalidFormatError] if the METAR format is invalid
  def parse(raw_report)
    match = METAR_REGEX.match(raw_report)
    raise InvalidFormatError, 'Invalid METAR format' unless match

    icao_code, day, hour, minute, direction, speed, gust, unit = match.captures

    {
      icao_code: parse_icao_code(icao_code),
      timestamp: parse_timestamp(day, hour, minute),
      wind_direction: parse_direction(direction),
      wind_speed: normalize_speed(speed.to_i, unit),
      wind_gust: gust ? normalize_speed(gust[1..].to_i, unit) : nil,
      wind_unit: 'MPS'
    }
  end

  private

  # Validates and returns the ICAO code
  #
  # @param code [String] the ICAO code
  # @return [String] the validated ICAO code
  # @raise [InvalidIcaoCodeError] if the ICAO code is invalid
  def parse_icao_code(code)
    raise InvalidIcaoCodeError, 'Invalid ICAO code' unless code.match?(/^[A-Z]{1,4}$/)

    code
  end

  # Parses and validates the timestamp
  #
  # @param day [String] the day of the month
  # @param hour [String] the hour
  # @param minute [String] the minute
  # @return [Time] the parsed timestamp
  # @raise [InvalidTimestampError] if any part of the timestamp is invalid
  def parse_timestamp(day, hour, minute)
    day = day.to_i
    hour = hour.to_i
    minute = minute.to_i
    raise InvalidTimestampError, 'Invalid day' unless (1..31).include?(day)
    raise InvalidTimestampError, 'Invalid hour' unless (0..23).include?(hour)
    raise InvalidTimestampError, 'Invalid minute' unless (0..59).include?(minute)

    Time.new(Time.now.year, Time.now.month, day, hour, minute)
  end

  # Parses and validates the wind direction
  #
  # @param direction [String] the wind direction in degrees
  # @return [Integer] the parsed wind direction
  # @raise [InvalidWindInfoError] if the wind direction is invalid
  def parse_direction(direction)
    direction = direction.to_i
    raise InvalidWindInfoError, 'Invalid wind direction' unless (0..360).include?(direction)

    direction
  end

  # Normalizes the wind speed to MPS
  #
  # @param speed [Integer] the wind speed
  # @param unit [String] the unit of the wind speed ('KT' or 'MPS')
  # @return [Float] the normalized wind speed in MPS
  # @raise [InvalidWindInfoError] if the wind speed is negative
  def normalize_speed(speed, unit)
    raise InvalidWindInfoError, 'Invalid wind speed' if speed.negative?

    unit == 'KT' ? speed / 2.0 : speed.to_f
  end
end