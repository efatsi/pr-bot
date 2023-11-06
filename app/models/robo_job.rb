class RoboJob < ApplicationRecord
end

# == Schema Information
#
# Table name: robo_jobs
#
#  id                     :bigint           not null, primary key
#  feature_request        :text             not null
#  filepath               :string           not null
#  generated_instructions :text
#  project_context        :text
#  relevant_files         :string           default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
