class Component < ActiveRecord::Base
  ASSET_FILES=["Datasheet", "Document", "Image"]
  belongs_to :amount
  has_many :component_tags
  has_many :tags, :through => :component_tags
  has_many :asset_data, class: AssetData

  validates_presence_of :name
  validates_presence_of :amount_id
  validate :spares_allowed
  validate :must_have_amount_value
  
  def as_json(options = {})
    data = {
      tags: tags.map(&:name).sort_by(&:norm),
      files: files
    }
    super.merge(data)
  end

  def files
    file_grouped = {}
    asset_data.each do |data|
      next if !ASSET_FILES.include?(data.asset_data_type.name)
      file_group = data.asset_data_type.name.tableize
      file_grouped[file_group] ||= []
      file_grouped[file_group] << data
    end
    file_grouped
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
  
  def self.search(query)
    return [] if query.blank?
    result = Component.all
    name_result = result.where("lower(name) LIKE ?", "%#{query.downcase}%").pluck(:id)
    description_result = result.where("lower(description) LIKE ?", "%#{query.downcase}%").pluck(:id)
    matching_tags = Tag.select(:id).where(norm: query)
    tag_result = ComponentTag.where(tag_id: matching_tags).pluck(:component_id)
    combined_result = name_result + description_result + tag_result
    result.where(id: combined_result.uniq)
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
