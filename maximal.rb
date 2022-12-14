#!/usr/bin/env ruby

require 'csv'
require './lib/bursar'
require './lib/timeline'

# read in reimbursement rates from csv
rates = CSV.read('data/rates.csv', headers: true, converters: %i[numeric])

# process all project data sets
Dir.glob('data/project-set-*.csv').each do |dataset|
  timeline = Timeline.new
  bursar = Bursar.new(timeline)

  rates.each { |r| bursar.set_reimbursement_rate r['cost_type'], r['travel_rate'], r['full_rate'] }

  CSV.foreach(dataset, headers: true, converters: %i[integer date]) do |row|
    bursar.set_project_type row['project_id'], row['cost_type']
    (row['start_date']..row['end_date']).each { |dt| timeline.add dt, row['project_id'] }
  end

  puts "#{dataset}: #{bursar.full_payment}"
end
