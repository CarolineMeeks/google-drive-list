# app/model/o_auth2_credential

class OAuth2Credential < ActiveRecord::Base
  belongs_to :user
  serialize :signet, Hash
  validates_uniqueness_of :name, scope: :id
end
