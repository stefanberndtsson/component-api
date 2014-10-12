class Component < ActiveRecord::Base
  belongs_to :amount
  has_many :component_tags
  has_many :tags, :through => :component_tags

  validates_presence_of :name
  validates_presence_of :amount_id
  validate :spares_allowed
  validate :must_have_amount_value

  after_validation :create_or_replace_tags
  
  attr_accessor :delete_tags
  attr_accessor :add_tags
  
  def as_json(options = {})
    super.merge({ tags: component_tags.map(&:tag_id) })
  end

  private
  def spares_allowed
    errors.add(:spares, "not allowed for low value amounts") if spares && !amount.can_have_spares
  end
  
  def must_have_amount_value
    return if !amount # Handled by another validator
    errors.add(:amount_value, "needed for fixed amount") if amount_value.blank? && amount.must_have_value
  end
  
  def create_or_replace_tags
    if @delete_tags
      self.component_tags.delete_all
    end
    done_tags = []
    @add_tags ||= []
    @add_tags.count.times do |i|
      tag_id = @add_tags.shift
      next if done_tags.include?(tag_id)
      next if !Tag.find_by_id(tag_id)
      done_tags << tag_id
      self.component_tags.build(tag_id: tag_id)
    end
  end
end
