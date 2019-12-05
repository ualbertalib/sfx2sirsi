# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :local_rake, "cd :path && rake :task --silent :output"

#every 30.days, :at => '1:00 am' do
#  local_rake "full_update"
#end

every :weekday, :at => '1:00 am' do
  local_rake "nightly_update"
end

every :weekday, :at => '10:00 pm' do
  local_rake "copy_data"
end
