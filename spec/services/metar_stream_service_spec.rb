# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MetarStreamService do
  let(:parser) { instance_double(MetarParserService) }
  let(:repository) { MetarReportRepository.new }
  let(:service) { described_class.new(parser: parser, repository: repository) }

  describe '#process_report' do
    it 'updates the repository with parsed data' do
      expect(parser).to receive(:parse).with('KJFK 122201Z 18027MPS').and_return({
                                                                                   icao_code: 'KJFK',
                                                                                   wind_speed: 27.0
                                                                                 })

      service.process_report('KJFK 122201Z 18027MPS')

      stats = service.get_stats
      expect(stats).to include(
        {
          icao_code: 'KJFK',
          average_speed: 27.0,
          current_speed: 27.0
        }
      )
    end

    it 'correctly calculates running average' do
      expect(parser).to receive(:parse).with('KJFK 122201Z 18020MPS').and_return({
                                                                                   icao_code: 'KJFK',
                                                                                   wind_speed: 20.0
                                                                                 })
      expect(parser).to receive(:parse).with('KJFK 122202Z 18030MPS').and_return({
                                                                                   icao_code: 'KJFK',
                                                                                   wind_speed: 30.0
                                                                                 })

      service.process_report('KJFK 122201Z 18020MPS')
      service.process_report('KJFK 122202Z 18030MPS')

      stats = service.get_stats
      expect(stats).to include(
        {
          icao_code: 'KJFK',
          average_speed: 25.0,
          current_speed: 30.0
        }
      )
    end
  end
end
