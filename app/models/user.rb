# app/model/user

class User < ActiveRecord::Base
  has_many :o_auth2_credentials, dependent: :destroy
end
