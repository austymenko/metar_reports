# frozen_string_literal: true

# app/controllers/api/v1/metar_reports_controller.rb

module Api
  module V1
    class MetarReportsController < ApplicationController
      include MetarErrors

      def create
        raw_report = params[:report]
        parser = MetarParserService.new
        report_data = parser.parse(raw_report)

        repository.update(report_data[:icao_code], report_data[:wind_speed])

        render json: {
          status: 'Report processed successfully',
          icao_code: report_data[:icao_code],
          wind_speed: report_data[:wind_speed],
          timestamp: report_data[:timestamp]
        }, status: :created
      rescue MetarErrors::InvalidFormatError,
             MetarErrors::InvalidIcaoCodeError,
             MetarErrors::InvalidTimestampError,
             MetarErrors::InvalidWindInfoError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
      end

      def running_average
        icao_code = params[:icao_code]
        average = repository.get_average(icao_code)
        current_speed = repository.get_current_speed(icao_code)

        render json: {
          icao_code: icao_code,
          average_wind_speed: average,
          current_wind_speed: current_speed
        }
      rescue StandardError => e
        render json: { error: "An unexpected error occurred: #{e.message}" }, status: :internal_server_error
      end

      private

      def repository
        @repository ||= MetarReportRepository.new
      end
    end
  end
end
