class CreateOAuth2Credentials < ActiveRecord::Migration
  def change
    create_table :o_auth2_credentials do |t|
      t.string :name
      t.references :user, index: true
      t.string :signet

      t.timestamps
    end
  end
end
