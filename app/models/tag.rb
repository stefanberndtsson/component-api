class Tag < ActiveRecord::Base
  has_many :component_tags
  has_many :components, :through => :component_tags
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :norm
  before_validation :generate_normalized_name
  
  private
  def generate_normalized_name
    return if self.name.nil? # Tested elsewhere
    decomposed = Unicode.nfkd(self.name)
    downcased = Unicode.downcase(decomposed)
    self.norm = downcased
  end
end
