# Bursar objects use stored project types and reimbursement rates to compute
# payments for a Timeline.  The cost types for each project id in the timeline
# must be provided to the Bursar, as well as the travel/full reimbursement
# rates for each cost type.  Provides methods for retrieving payment amounts
# for individual dates or the entire timeline.
#
# Usage example:
#
# t = Timeline.new
# t.add '2021-01-01', 'Project X'
# t.add '2021-01-02', 'Project Y'
#
# b = Bursar.new(t)
# b.set_reimbursement_rate('low', 5.00, 10.00)
# b.set_reimbursment_rate('high', 20.00, 40.00)
# b.set_project_type('Project X', 'low')
# b.set_project_type('Project Y', 'high')
#
# b.payment_on '2021-01-01'   # 5.00
# b.payment_on '2021-01-02'   # 20.00
# b.full_payment              # 25.00
#
class Bursar
  # If multiple project types are worked on a single date, the reimbursement rate
  # used is determined by the order below.  This allows for additional cost types to
  # be added and their priority preferences to be updated with minimal code changes.
  COST_TYPE_PRIORITIES = %i[high low].freeze

  attr_accessor :timeline
  attr_reader :project_types, :reimbursement_rates

  # Constructor.  Accepts optional Timeline instance as parameter.
  def initialize(timeline = nil)
    @timeline = timeline
    @project_types = {}
    @reimbursement_rates = {}
  end

  # Set reimbursement rates for a project cost type.
  #
  # params:
  # - cost_type: Cost type, one of COST_TYPE_PRIORITIES
  # - travel_rate: Travel rate payment amount
  # - full_rate: Full rate payment amount
  def set_reimbursement_rate(cost_type, travel_rate, full_rate)
    @reimbursement_rates[cost_type.to_sym] = { travel_rate: travel_rate, full_rate: full_rate }
  end

  # Set cost type for a project.
  #
  # params:
  # - project_id: Project identifier
  # - cost_type: Project cost type, one of COST_TYPE_PRIORITIES
  def set_project_type(project_id, cost_type)
    @project_types[project_id.to_s.to_sym] = cost_type.to_sym
  end

  # Return total reimbursement amount for entire timeline.
  def full_payment
    payment_amount = 0
    (@timeline.start_date..@timeline.end_date).each do |dt|
      payment_amount += payment_on(dt)
    end
    payment_amount
  end

  # Return reimbursement amount for a given date.
  #
  # params:
  # - date: Date or date parseable string
  def payment_on(date)
    rate_type = rate_type_on(date)
    return 0 if rate_type.nil?

    return @reimbursement_rates[rate_type][:travel_rate] if @timeline.travel_day? date

    return @reimbursement_rates[rate_type][:full_rate] if @timeline.full_day? date

    0 # date is not a valid work date in the timeline
  end

  # Returns cost type in effect for a given timeline date.
  #
  # params:
  # - date: Date or date parseable string
  def rate_type_on(date)
    work_data = @timeline.on(date)
    return nil if work_data.nil?

    effective_type = nil
    work_data[:projects].each do |p|
      project_type = @project_types[p.to_s.to_sym]
      if effective_type.nil?
        effective_type = project_type
        next
      end

      effective_priority = COST_TYPE_PRIORITIES.index effective_type
      project_priority = COST_TYPE_PRIORITIES.index project_type
      effective_type = project_type if project_priority < effective_priority
    end
    effective_type
  end
end
