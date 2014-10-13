class Tag < ActiveRecord::Base
  has_many :component_tags
  has_many :components, :through => :component_tags
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :norm
  before_validation :generate_normalized_name
  
  private
  def generate_normalized_name
    self.norm = self.name.norm
  end
end
