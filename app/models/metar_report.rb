# frozen_string_literal: true

# Represents a single METAR report in the database
class MetarReport < ApplicationRecord
  # Ensures all required fields are present
  validates :icao_code, :timestamp, :wind_direction, :wind_speed, :wind_unit, presence: true
end