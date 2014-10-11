class Amount < ActiveRecord::Base
  validates_presence_of :name
  validates_inclusion_of :can_have_spares, in: [true, false]
  validates_inclusion_of :must_have_value, in: [true, false]
end
