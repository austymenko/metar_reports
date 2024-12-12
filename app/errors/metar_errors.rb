# frozen_string_literal: true

# Custom error classes for METAR report processing
module MetarErrors
  # Raised when the overall METAR format is invalid
  class InvalidFormatError < StandardError; end

  # Raised when the ICAO code in a METAR report is invalid
  class InvalidIcaoCodeError < StandardError; end

  # Raised when the timestamp in a METAR report is invalid
  class InvalidTimestampError < StandardError; end

  # Raised when the wind information in a METAR report is invalid
  class InvalidWindInfoError < StandardError; end
end