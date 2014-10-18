class User < ActiveRecord::Base
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :password
  validates_presence_of :name

  before_save :encrypt_password
  
  def authenticate(provided_password)
    pass = BCrypt::Password.new(self.password)
    if(pass == provided_password)
      generate_token
      return true
    end
    false
  end

  def generate_token
    update_attributes({
                        token: SecureRandom.hex,
                        token_expire: Time.now + 1.day
                      })
  end
  
  def clear_token
    update_attributes({ token: nil, token_expire: nil })
  end
  
  def validate_token(provided_token)
    if self.token_expire < Time.now
      clear_token
      return false
    end
    provided_token == self.token
  end

  def as_json(options = {})
    {
      username: username,
      name: name
    }
  end
  
  private
  def encrypt_password
    self.password = BCrypt::Password.create(self.password) unless BCrypt::Password.valid_hash?(self.password)
  end
end
