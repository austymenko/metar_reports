# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ParseWindCommand do
  let(:command) { described_class.new }

  describe '#execute' do
    it 'parses wind info in MPS' do
      result = command.execute('18027MPS')
      expect(result[:wind_direction]).to eq(180)
      expect(result[:wind_speed]).to eq(27.0)
      expect(result[:wind_unit]).to eq('MPS')
    end

    it 'parses wind info in KT and converts to MPS' do
      result = command.execute('18054KT')
      expect(result[:wind_direction]).to eq(180)
      expect(result[:wind_speed]).to eq(27.0)
      expect(result[:wind_unit]).to eq('MPS')
    end

    it 'parses wind info with gusts' do
      result = command.execute('18027G40MPS')
      expect(result[:wind_direction]).to eq(180)
      expect(result[:wind_speed]).to eq(27.0)
      expect(result[:wind_gust]).to eq(40.0)
      expect(result[:wind_unit]).to eq('MPS')
    end

    it 'raises an error for invalid wind direction' do
      expect { command.execute('36127MPS') }.to raise_error(MetarErrors::InvalidWindInfoError)
    end

    it 'raises an error for invalid wind speed' do
      expect { command.execute('180XXMPS') }.to raise_error(MetarErrors::InvalidWindInfoError)
    end
  end
end
