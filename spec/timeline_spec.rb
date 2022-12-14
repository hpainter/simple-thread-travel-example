require 'timeline'

# rubocop:disable Metrics/BlockLength
describe Timeline do
  it 'initializes with empty dates list' do
    t = Timeline.new
    expect(t.count).to eq(0)
  end

  it 'stores unique project dates' do
    t = Timeline.new
    t.add Date.new(2000, 1, 1)
    t.add '2000-01-01'
    expect(t.count).to eq(1)
  end

  it 'stores unique project identifiers' do
    t = Timeline.new
    t.add '2000-01-01', 'foo'
    t.add '2000-01-02', 'foo'
    t.add '2000-01-03', 'bar'
    expect(t.projects).to eq(%w[foo bar])
  end

  it 'returns project data for single date' do
    t = Timeline.new
    project_data = {
      date: Date.new(2000, 1, 1),
      projects: ['foo']
    }
    t.add '2000-1-1', 'foo'
    t.add '2000-1-2', 'foo'
    expect(t.on('2000-01-01')).to eq(project_data)
  end

  it 'sorts project dates' do
    date_list = [
      Date.new(2020, 1, 1),
      Date.new(1999, 1, 1),
      Date.new(2003, 12, 31)
    ]
    t = Timeline.new
    date_list.each do |d|
      t.add d
    end
    timeline_dates = t.map { |d| d[:date] }
    expect(timeline_dates[0]).to eq(date_list[1])
    expect(timeline_dates[1]).to eq(date_list[2])
    expect(timeline_dates[2]).to eq(date_list[0])
  end

  it 'identifies full days' do
    t = Timeline.new
    t.add '2020-01-01', 'foo'
    t.add '2020-01-02', 'bar'
    t.add '2020-01-03', 'bar'

    expect(t.full_day?('2020-01-01')).to be false
    expect(t.full_day?('2020-01-02')).to be true
    expect(t.full_day?(Date.new(2020, 1, 3))).to be false
  end

  it 'identifies travel days' do
    t = Timeline.new
    t.add '2020-01-01', 'foo'
    t.add '2020-01-02', 'bar'
    t.add '2020-01-03', 'bar'

    expect(t.travel_day?('2020-01-01')).to be true
    expect(t.travel_day?('2020-01-02')).to be false
    expect(t.travel_day?(Date.new(2020, 1, 3))).to be true
  end

  it 'returns start dates by project' do
    t = Timeline.new
    t.add '2020-01-01', 'foo'
    t.add '2019-01-01', 'bar'
    t.add '2020-01-03', 'bar'
    t.add '2020-06-01', 'foo'

    expect(t.start_date('foo')).to eq(Date.new(2020, 1, 1))
    expect(t.start_date('bar')).to eq(Date.new(2019, 1, 1))
    expect(t.start_date).to eq(Date.new(2019, 1, 1))
  end

  it 'returns end dates by project' do
    t = Timeline.new
    t.add '2020-01-01', 'foo'
    t.add '2019-01-01', 'bar'
    t.add '2020-01-03', 'bar'
    t.add '2020-06-01', 'foo'

    expect(t.end_date('foo')).to eq(Date.new(2020, 6, 1))
    expect(t.end_date('bar')).to eq(Date.new(2020, 1, 3))
    expect(t.end_date).to eq(Date.new(2020, 6, 1))
  end
end
# rubocop:enable Metrics/BlockLength
