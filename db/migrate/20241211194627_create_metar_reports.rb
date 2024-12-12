class CreateMetarReports < ActiveRecord::Migration[7.1]
  def change
    create_table :metar_reports do |t|
      t.string :icao_code
      t.datetime :timestamp
      t.integer :wind_direction
      t.float :wind_speed
      t.float :wind_gust
      t.string :wind_unit

      t.timestamps
    end
  end
end
