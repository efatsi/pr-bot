namespace :robo_requests do
  desc 'Backfill token counts and costs for existing RoboRequests'
  task backfill_token_counts_and_costs: :environment do
    RoboRequest.find_each do |request|
      request.calculate_token_usage_and_cost
    end
  end
end
