class RemoveUsersForPublicPortfolio < ActiveRecord::Migration[8.1]
  def up
    drop_table :users, if_exists: true
  end

  def down
    # Public portfolio app: user accounts are intentionally not recreated.
  end
end
