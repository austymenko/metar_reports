# frozen_string_literal: true

RSpec.describe MetarReportRepository do
  let(:repository) { described_class.new }

  describe '#update and #get_average' do
    describe '#update and #get_average' do
      it 'calculates the running average correctly' do
        repository.update('KJFK', 10)
        repository.update('KJFK', 20)
        repository.update('KJFK', 30)

        expect(repository.get_average('KJFK')).to be_within(0.01).of(20.0)
        expect(repository.get_current_speed('KJFK')).to eq(30.0)
      end

      it 'returns zero for non-existent ICAO code' do
        expect(repository.get_average('XXXX')).to eq(0.0)
        expect(repository.get_current_speed('XXXX')).to eq(0.0)
      end
    end

    it 'prunes old data' do
      repository.instance_variable_set(:@prune_threshold, 1.hour)

      repository.update('KJFK', 10)
      repository.update('KLAX', 20)

      travel 2.hours do
        repository.update('KJFK', 15)
        repository.send(:prune_old_data)

        expect(repository.get_average('KJFK')).to be_within(0.01).of(12.5)
        expect(repository.get_average('KLAX')).to eq(0.0)
      end
    end
  end
end
