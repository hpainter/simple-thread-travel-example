require 'date'
#
# Timeline objects represent days worked on a set of projects.  Allows for
# iterative construction while remaining sorted, and provides methods to
# determine if a given day is considered a 'full' or 'travel' date.
#
# Usage example:
#
# t = Timeline.new
# t.add '2021-02-05', 'Project X'
# t.add '2021-02-01', 'Project X'
# t.add '2021-02-05', 'Project Y'
#
# t.full_day? Date.new(2021,02,05) # true
# t.full_day? '2021-02-02'         # false
# t.travel_day? '2021-02-02'       # true
#
class Timeline
  include Enumerable

  def initialize
    # @dates contains data hashes in time order, eg:
    # [ {date: 2021-01-02, projects: ['foo','bar']},
    #   {date: 2021-01-03, projects: ['bar']},
    #   ... ]
    @dates = []
  end

  # Add a new project day worked to current Timeline.
  #
  # params:
  # - date:    day worked as Date object or Date parseable string
  # - project: optional project identifier
  def add(date, project = nil)
    # initialize a new data hash or add to existing
    current_data = on(date)
    project_data = if current_data.nil?
                     { date: coerced_date(date), projects: [] }
                   else
                     current_data
                   end
    project_data[:projects] << project

    # insert/replace relevant @dates entry
    replaced = false
    @dates.each_with_index do |data, idx|
      next unless data[:date] == project_data[:date]

      # replace existing
      @dates[idx] = project_data
      replaced = true
    end
    @dates << project_data unless replaced
    @dates = @dates.sort { |a, b| a[:date] <=> b[:date] }
  end

  # Remove a project day worked from current Timeline.
  #
  # NOTE: Not implemented here since there is no need, but gonna stub it anyway
  # for the sake of symmetry.
  #
  # params:
  # - date:    day worked as Date object or Date parseable string
  # - project: optional project identifier
  # def remove(date, project = nil); end

  # Enumerable requires an :each method
  def each(&block)
    return enum_for(:each) unless block_given?

    @dates.each(&block)
    self
  end

  # Return data hash for param date
  def on(date)
    project_date = coerced_date(date)
    @dates.find { |d| d[:date] == project_date }
  end

  # Return unique project identifiers in @dates
  def projects
    project_list = @dates.map { |d| d[:projects] }
    project_list.flatten.uniq
  end

  # Determine if date is considered a travel day
  #
  # params:
  # - date: Date or date parseable string
  def travel_day?(date)
    project_date = on(date)
    return false if project_date.nil?

    check_date = coerced_date(date)
    prev_date = on(check_date - 1)
    next_date = on(check_date + 1)

    return true if prev_date.nil? || next_date.nil?

    false
  end

  # Determine if date is considered a full day
  #
  # params:
  # - date: Date or date parseable string
  def full_day?(date)
    project_date = on(date)
    return false if project_date.nil?

    check_date = coerced_date(date)
    prev_date = on(check_date - 1)
    next_date = on(check_date + 1)

    return true if !prev_date.nil? && !next_date.nil?

    false
  end

  # Return first date in Timeline, optionally filtered by specific project id
  #
  # params:
  # - project: optional project identifier
  def start_date(project = nil)
    return @dates.first[:date] if project.nil?

    project_date = @dates.find { |d| d[:projects].include? project }
    project_date[:date]
  end

  # Return last date in Timeline, optionally filtered by specific project id
  #
  # params:
  # - project: optional project identifier
  def end_date(project = nil)
    return @dates.last[:date] if project.nil?

    project_date = @dates.reverse.find { |d| d[:projects].include? project }
    project_date[:date]
  end

  protected

  # utility method to cast parameter value to Date object as needed
  def coerced_date(date)
    date.is_a?(Date) ? date : Date.parse(date.to_s)
  end
end
