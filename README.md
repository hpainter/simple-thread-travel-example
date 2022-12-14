# SimpleThread Travel Reimbursement Exercise

Solution for SimpleThread sample exercise in two flavors: a minimal script that tries solve in as few lines of code possible, and a more realistic maximal version that uses testable/maintainable objects.

## Setup + Requirements

- Requires a relatively recent ruby version, > 2.3
- Install rspec if needed with `bundle install`
- Test suite can be run with rspec, eg `rspec -f d`
- Run either script, `./minimal.rb` or `./maximal.rb` to receive (hopefully) identical output.

## Design Choices

In general I wanted to avoid using external dependencies here as much as possible.  To that end, I converted the input data for the exercise into a set of basic CSV files, stored under `/data`.  This seemed like a fairly straightforward way to mock an external data store, but you could equally well use something like SQLite to create a small relational database.

I also decided to stop short of creating any kind of UI for this solution, but would be more than happy to add a CLI or browser-based UI if anyone is interested.

## Minimal Version

`minimal.rb` contains the code golf solution version, and should output the total reimbursement for each project data set when invoked with `./minimal.rb`.  By my count this is 31 lines of code total, but could certainly be lower at the expense of it's already poor readability.  I'm tempted to claim that I included this script in order to illustrate a larger point, perhaps something about how strictly meeting technical requirements with no regard for logical modeling or readability results in brittle and unmaintainable code.  But honestly I just wanted to initially do a quick-and-dirty run through of the problem, and decided to leave it afterwards.

## Maximal Version

Treating the problem as more of an actual application, I wanted to model it with objects that isolated what I see as two logically distinct concerns.  The first business need is simply to track which days have been worked on which projects, which is handled here by the Timeline class.  Assuming that the number of records in our data store could potentially be very large, the Timeline is designed to allow for adding individual project days as you would if you were iterating over thousands of records.  Logic for de-duplicating entries, keeping entries sorted by date regardless of the order they were added, and for retrieving date boundaries for individual projects are included in the Timeline.  It also implements the Enumerable interface so that it's sanitized work history can be iterated over by consuming code.

The other business concern in the application is the reimbursement calculations, modeled here by the Bursar class.  It would be overwhelmingly likely that the designations for what cost type a particular project has or the reimbursement rates that are used would be things the business will be updating relatively frequently.  Keeping these changes isolated from the otherwise unrelated work history seems appropriate.  A good example is provided by an ambiguity in the problem description: when both a low and high cost project day coincide, there is no instruction as to which set of reimbursement rates should take precedence.  So the Bursar here makes an assumption that the business in question is not greedy (unwarranted optimism obvs), and that the high cost rates should apply in that case.  But if that assumption is wrong or needs to be changed, there is a class constant that can be updated to change the application behavior.  

The `maximal.rb` script stands in for our application here, generating a Timeline instance for each set of project data, adding the reimbursement rates and project types to a Bursar instance, and then using the Bursar to calculate payment amounts by iterating over the Timeline entries.

## Potential Improvements

- If the data to be added to a Timeline is very large, memory consumption would become an issue under the current implementation.  A real world app would want to migrate to using an external data store.
- I would want a more production-ready version of this to include a Rakefile or Makefile to encapsulate the CLI commands and provide some options for specifying arbitrary input files or reimbursement rates.  
- There is an implied third logical object in this application, the Project. It is not modeled here because there is no special behavior to model outside of a project identifier and a cost type.  

## Original Problem Description

You have a set of projects, and you need to calculate a reimbursement amount for the set. Each project has a start date and an end date. The first day of a project and the last day of a project are always "travel" days. Days in the middle of a project are "full" days. There are also two types of cities a project can be in, high cost cities and low cost cities.

A few rules:
 - First day and last day of a project, or sequence of projects, is a travel day.
 - Any day in the middle of a project, or sequence of projects, is considered a full day.
 - If there is a gap between projects, then the days on either side of that gap are travel days.
 - If two projects push up against each other, or overlap, then those days are full days as well.
 - Any given day is only ever counted once, even if two projects are on the same day.
 - A travel day is reimbursed at a rate of 45 dollars per day in a low cost city.
 - A travel day is reimbursed at a rate of 55 dollars per day in a high cost city.
 - A full day is reimbursed at a rate of 75 dollars per day in a low cost city.
 - A full day is reimbursed at a rate of 85 dollars per day in a high cost city.

Given the following sets of projects, provide code that will calculate the reimbursement for each.

Set 1:
 - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/3/15

Set 2:
 - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
 - Project 2: High Cost City Start Date: 9/2/15 End Date: 9/6/15
 - Project 3: Low Cost City Start Date: 9/6/15 End Date: 9/8/15

Set 3:
 - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/3/15
 - Project 2: High Cost City Start Date: 9/5/15 End Date: 9/7/15
 - Project 3: High Cost City Start Date: 9/8/15 End Date: 9/8/15

Set 4:
 - Project 1: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
 - Project 2: Low Cost City Start Date: 9/1/15 End Date: 9/1/15
 - Project 3: High Cost City Start Date: 9/2/15 End Date: 9/2/15
 - Project 4: High Cost City Start Date: 9/2/15 End Date: 9/3/15
