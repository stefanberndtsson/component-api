class User < ActiveRecord::Base
  DEFAULT_TOKEN_EXPIRE = 1.day
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :password
  validates_presence_of :name

  has_many :access_tokens

  before_save :encrypt_password
  
  def authenticate(provided_password, force_authenticated = false)
    if force_authenticated
      token_object = generate_token
      return token_object.token
    end

    pass = BCrypt::Password.new(self.password)
    if(pass == provided_password)
      token_object = generate_token
      return token_object.token
    end
    false
  end

  def generate_token
    access_tokens.create(token: SecureRandom.hex, token_expire: Time.now + DEFAULT_TOKEN_EXPIRE)
  end
  
  def clear_expired_tokens
    access_tokens.where("token_expire < ?", Time.now).destroy_all
  end
  
  def validate_token(provided_token)
    clear_expired_tokens
    token_object = access_tokens.find_by_token(provided_token)
    return false if !token_object
    token_object.update_attribute(:token_expire, Time.now + DEFAULT_TOKEN_EXPIRE)
    true
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
