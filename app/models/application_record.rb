class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :by_id, -> { order(id: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }

  def self.array_field(name)
    define_method("#{name}=") do |files|
      if files.is_a?(String)
        super(files.split("\n").sort)
      else
        super(files.sort)
      end
    end
  end
end
