require 'timeline'
require 'bursar'

# rubocop:disable Metrics/BlockLength
describe Bursar do
  before(:example) do
    @timeline = Timeline.new
    @timeline.add '2000-01-01', 'Project A'
    @timeline.add '2000-01-02', 'Project A'
    @timeline.add '2000-01-03', 'Project A'
    @timeline.add '2000-01-03', 'Project B'
    @timeline.add '2000-01-03', 'Project C'

    @bursar = Bursar.new(@timeline)
  end

  it 'stores project cost types' do
    @bursar.set_project_type 'Project A', 'low'
    @bursar.set_project_type 'Project B', 'high'
    expected = {
      "Project A": :low,
      "Project B": :high
    }
    expect(@bursar.project_types).to eq expected
  end

  it 'stores reimbursement rates' do
    @bursar.set_reimbursement_rate 'low', 1, 2
    @bursar.set_reimbursement_rate 'high', 3, 4
    expected = {
      low: { travel_rate: 1, full_rate: 2 },
      high: { travel_rate: 3, full_rate: 4 }
    }
    expect(@bursar.reimbursement_rates).to eq expected
  end

  it 'applies cost types in priority order' do
    @bursar.set_reimbursement_rate 'low', 1, 2
    @bursar.set_reimbursement_rate 'high', 3, 4
    @bursar.set_project_type 'Project A', 'low'
    @bursar.set_project_type 'Project B', 'high'
    @bursar.set_project_type 'Project C', 'low'

    expect(@bursar.rate_type_on('2000-01-03')).to eq :high
  end

  it 'returns payment for single dates' do
    @bursar.set_reimbursement_rate 'low', 1, 2
    @bursar.set_reimbursement_rate 'high', 3, 4
    @bursar.set_project_type 'Project A', 'low'
    @bursar.set_project_type 'Project B', 'high'
    @bursar.set_project_type 'Project C', 'low'

    expect(@bursar.payment_on('2000-01-03')).to eq 3
  end

  it 'returns payment for full timeline' do
    @bursar.set_reimbursement_rate 'low', 1, 2
    @bursar.set_reimbursement_rate 'high', 3, 4
    @bursar.set_project_type 'Project A', 'low'
    @bursar.set_project_type 'Project B', 'high'
    @bursar.set_project_type 'Project C', 'low'

    expect(@bursar.full_payment).to eq 6
  end
end
# rubocop:enable Metrics/BlockLength
