class AddTokenCountAndCostToRoboRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :robo_requests, :prompt_token_count, :integer
    add_column :robo_requests, :response_token_count, :integer
    add_column :robo_requests, :cost, :decimal, precision: 8, scale: 2
  end
end
