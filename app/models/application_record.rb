class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :by_id, -> { order(id: :asc) }
end
