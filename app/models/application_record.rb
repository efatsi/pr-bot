class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :by_id, -> { order(id: :asc) }
  scope :newest_first, -> { order(created_at: :desc) }

  def self.array_field(name, alphabetize: false)
    define_method("#{name}=") do |files|
      if files.is_a?(String)
        if alphabetize
          super(files.split("\n").sort)
        else
          super(files.split("\n"))
        end
      else
        super(files)
      end
    end
  end
end
