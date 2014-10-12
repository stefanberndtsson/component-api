class ComponentTag < ActiveRecord::Base
  belongs_to :component
  belongs_to :tag

  validates_uniqueness_of :tag_id, scope: [:component_id]
end
