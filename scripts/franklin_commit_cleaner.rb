#!/usr/bin/env ruby
input_string = ARGV[0]
franklin_project_id = 1

if input_string.nil?
  puts "Usage: franklin_commit_cleaner.rb <input_string>"
  exit 1
end

puts "Creating robo job..."
response = HTTParty.post("http://localhost:3069/api/robo_jobs",
  headers: { "Content-Type" => "application/json" },
  body: {
    input_string: input_string,
    project_id: franklin_project_id,
  }.to_json
)

build_event = RoboEvent.find(response["build_event"])

puts "Job created: http://localhost:3069/robo_jobs/#{response["robo_job"]}"
puts "  - generating actions"

start_time = Time.now
action_count = 0
# give it 30 seconds to create actions
while action_count == 0 && Time.now - start_time < 30.seconds
  action_count = build_event.actions.count
end

if action_count > 0
  # give it a little more time
  sleep(1)
  action_count = build_event.actions.count

  puts
  ellapsed_seconds = (Time.now - start_time).to_i
  puts "#{action_count} actions were created in #{ellapsed_seconds}s. Firing now..."

  build_event.actions.pending.each_with_index do |action, i|
    print "#{i + 1}: #{action.summary}"
    begin
      action.fire!
      puts " - ✅"
    rescue
      puts " - ❌"
    end

    sleep(0.1)
  end

  puts "All actions have fired."
  # go back and open up `gitx` for review
  system("cd -")
  system("gitx")
else
  puts "No actions were created. Check at http://localhost:3069/robo_jobs/#{response["robo_job"]}"
  exit 1
end
