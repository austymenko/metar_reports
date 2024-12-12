# frozen_string_literal: true

RSpec.describe MetarStreamProcessor do
  let(:processor) { described_class.new }

  it 'processes a stream of reports without failure' do
    reports = generate_test_reports(100)
    expect { processor.process_stream(StringIO.new(reports), silent: true) }.not_to raise_error
  end

  it 'correctly processes and stores data' do
    reports = generate_test_reports(10)
    processor.process_stream(StringIO.new(reports), silent: true)
    stats = processor.get_stats
    expect(stats).not_to be_empty
    expect(stats.first).to have_key(:icao_code)
    expect(stats.first).to have_key(:average_speed)
    expect(stats.first).to have_key(:current_speed)
  end

  private

  def generate_test_reports(count)
    reports = String.new  # Use String.new instead of '' to create a mutable string
    count.times do
      icao = ('A'..'Z').to_a.sample(4).join
      timestamp = "#{Time.now.strftime('%d%H%M')}Z"
      direction = format('%03d', rand(360))
      speed = rand(100)
      unit = %w[KT MPS].sample
      gust = rand < 0.3 ? "G#{format('%02d', speed + rand(20))}" : ''
      reports << "#{icao} #{timestamp} #{direction}#{format('%02d', speed)}#{gust}#{unit}\n"
    end
    reports
  end
end