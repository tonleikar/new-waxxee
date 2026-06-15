class OptimizeIndexesOnFollowersAndPersonas < ActiveRecord::Migration[8.1]
  def change
    # 1. Fix the followers table indexes
    # Remove the old, non-unique single indexes
    remove_index :followers, :followed_id, name: 'index_followers_on_followed_id'
    remove_index :followers, :follower_id, name: 'index_followers_on_follower_id'

    # Add the new unique composite index (prevents duplicate follows)
    add_index :followers, %i[follower_id followed_id], unique: true

    # Also add back a single index on followed_id for performance on inverse lookups
    # (e.g., finding all followers of a specific user)
    add_index :followers, :followed_id

    # 2. Fix the personas table index
    # Remove the old non-unique index
    remove_index :personas, :user_id, name: 'index_personas_on_user_id'

    # Add the partial unique index (enforces only ONE primary profile per user)
    add_index :personas, :user_id, unique: true, where: 'primary_profile = true',
                                   name: 'index_personas_on_user_id_primary'

    # Add back a standard index for non-primary profiles so lookups by user_id stay fast
    add_index :personas, :user_id, name: 'index_personas_on_user_id'
  end
end
