class Component < ActiveRecord::Base
  belongs_to :amount
  has_many :component_tags
  has_many :tags, :through => :component_tags

  validates_presence_of :name
  validates_presence_of :amount_id
  validate :spares_allowed
  validate :must_have_amount_value
  
  def as_json(options = {})
    super.merge({ tags: tags.map(&:name) })
  end

  def add_tag(tag_name)
    tag = Tag.find_by_norm(tag_name.norm)
    if !tag
      tag = Tag.create(name: tag_name)
    end
    component_tags.create(tag_id: tag.id)
  end
  
  def clear_tags
    component_tags.delete_all
  end
  
  private
  def spares_allowed
    errors.add(:spares, "not allowed for low value amounts") if spares && !amount.can_have_spares
  end
  
  def must_have_amount_value
    return if !amount # Handled by another validator
    errors.add(:amount_value, "needed for fixed amount") if amount_value.blank? && amount.must_have_value
  end
end
