#!/usr/bin/env ruby

require 'csv'
require 'date'

# read in reimbursement rates from csv
# { 'low': { 'travel': 0.00, 'full': 0.00 }, ... }
rates = {}
CSV.foreach('data/rates.csv', headers: true, converters: %i[numeric]) do |row|
  rates[row['cost_type']] = Hash['travel', row['travel_rate'], 'full', row['full_rate']]
end

# build a hash of days worked from csv with date keys and project cost type as value
# { 2020-01-01: 'high', 2020-01-04: 'low', ... }
def read_project_dates(filepath)
  project_dates = {}
  CSV.foreach(filepath, headers: true, converters: %i[integer date]) do |row|
    (row['start_date']..row['end_date']).each do |work_date|
      project_dates[work_date] = if project_dates[work_date] == 'high'
                                   # let 'high' rates supersede 'low' in case of conflict
                                   'high'
                                 else
                                   row['cost_type']
                                 end
    end
  end
  project_dates
end

# compute reimbursement total for all project data files
Dir.glob('data/project-set-*.csv').each do |dataset|
  timeline = read_project_dates(dataset)
  reimbursement = 0
  timeline.each_key do |work_date|
    reimbursement += if timeline.key?(work_date - 1) && timeline.key?(work_date + 1)
                       rates[timeline[work_date]]['full']
                     else
                       rates[timeline[work_date]]['travel']
                     end
  end
  puts "#{dataset}: #{reimbursement}"
end
