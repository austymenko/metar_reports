namespace :metar do
  desc "Generate random METAR reports"
  task :generate_reports, [:count] => :environment do |t, args|
    count = (args[:count] || 100_000).to_i

    count.times do
      icao = ('A'..'Z').to_a.sample(4).join
      timestamp = Time.now.strftime("%d%H%M") + "Z"
      direction = sprintf("%03d", rand(360))
      speed = rand(100)
      unit = ['KT', 'MPS'].sample
      gust = rand < 0.3 ? "G#{sprintf("%02d", speed + rand(20))}" : ""

      puts "#{icao} #{timestamp} #{direction}#{sprintf("%02d", speed)}#{gust}#{unit}"
    end
  end
end