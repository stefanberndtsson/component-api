class Component < ActiveRecord::Base
  belongs_to :amount

  validates_presence_of :name
  validates_presence_of :amount_id
  validate :spares_allowed
  validate :must_have_amount_value
  
  private
  def spares_allowed
    errors.add(:spares, "not allowed for low value amounts") if spares && !amount.can_have_spares
  end
  
  def must_have_amount_value
    return if !amount # Handled by another validator
    errors.add(:amount_value, "needed for fixed amount") if amount_value.blank? && amount.must_have_value
  end
end
