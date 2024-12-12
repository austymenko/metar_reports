# frozen_string_literal: true

RSpec.describe 'Api::V1::MetarReports', type: :request do
  let(:repository) { MetarReportRepository.new }

  before do
    allow(MetarReportRepository).to receive(:new).and_return(repository)
  end

  describe 'POST /api/v1/metar_reports' do
    let(:valid_params) { { report: 'KJFK 122201Z 18027MPS' } }
    let(:invalid_params) { { report: 'INVALID REPORT' } }

    context 'with valid parameters' do
      it 'processes a new METAR report' do
        post '/api/v1/metar_reports', params: valid_params
        expect(response).to have_http_status(:created)

        body = JSON.parse(response.body)
        expect(body['status']).to eq('Report processed successfully')
        expect(body['icao_code']).to eq('KJFK')
        expect(body['wind_speed']).to eq(27.0)
        expect(body['timestamp']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post '/api/v1/metar_reports', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key('error')
      end
    end
  end

  describe 'GET /api/v1/metar_reports/running_average/:icao_code' do
    before do
      repository.update('KJFK', 10)
      repository.update('KJFK', 20)
      repository.update('KJFK', 30)
    end

    it 'returns the average and current wind speed' do
      get '/api/v1/metar_reports/running_average/KJFK'
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['icao_code']).to eq('KJFK')
      expect(body['average_wind_speed']).to be_within(0.01).of(20.0)
      expect(body['current_wind_speed']).to eq(30.0)
    end

    it 'returns zero values for non-existent ICAO code' do
      get '/api/v1/metar_reports/running_average/XXXX'
      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body['icao_code']).to eq('XXXX')
      expect(body['average_wind_speed']).to eq(0.0)
      expect(body['current_wind_speed']).to eq(0.0)
    end
  end
end
