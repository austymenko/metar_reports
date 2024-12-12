# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetarParserService do
  let(:service) { described_class.new }

  describe '#parse' do
    it 'successfully parses a valid METAR report' do
      raw_report = 'KJFK 122201Z 18027MPS'
      result = service.parse(raw_report)

      expect(result[:icao_code]).to eq('KJFK')
      expect(result[:timestamp]).to be_a(Time)
      expect(result[:wind_direction]).to eq(180)
      expect(result[:wind_speed]).to eq(27.0)
      expect(result[:wind_unit]).to eq('MPS')
    end

    it 'successfully parses a report with gusts' do
      raw_report = 'KJFK 122201Z 18027G35KT'
      result = service.parse(raw_report)

      expect(result[:wind_speed]).to eq(13.5)
      expect(result[:wind_gust]).to eq(17.5)
      expect(result[:wind_unit]).to eq('MPS')
    end

    it 'raises an error for invalid METAR format' do
      raw_report = 'INVALID REPORT'
      expect { service.parse(raw_report) }.to raise_error(MetarErrors::InvalidFormatError)
    end

    it 'raises an error for invalid ICAO code' do
      raw_report = 'K1JK 122201Z 18027MPS'
      expect { service.parse(raw_report) }.to raise_error(MetarErrors::InvalidIcaoCodeError)
    end

    it 'raises an error for invalid timestamp' do
      raw_report = 'KJFK 322201Z 18027MPS'
      expect { service.parse(raw_report) }.to raise_error(MetarErrors::InvalidTimestampError)
    end

    it 'raises an error for invalid wind direction' do
      raw_report = 'KJFK 122201Z 36127MPS'
      expect { service.parse(raw_report) }.to raise_error(MetarErrors::InvalidWindInfoError)
    end

    it 'raises an error for invalid wind speed' do
      raw_report = 'KJFK 122201Z 180XXMPS'
      expect { service.parse(raw_report) }.to raise_error(MetarErrors::InvalidFormatError)
    end
  end
end
