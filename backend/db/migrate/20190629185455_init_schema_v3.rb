class InitSchemaV3 < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string   :username, index: { unique: true }
      t.string   :email, index: { unique: true }
      t.string   :password_digest
      t.boolean  :admin, default: false
      t.boolean  :active, default: false
      t.string   :activation_token
      t.string   :pass_reset_token
      t.datetime :pass_reset_last_sent
      t.integer  :unseen_notifs, default: 0
      
      t.timestamps
    end

    create_table :addresses do |t|
      t.string  :code
      t.boolean :used, default: false
      t.boolean :internal, default: true
      t.integer  :wallet_id, index: true
      
      t.timestamps
    end
  
    create_table :plays do |t|
      t.integer :payment_status, default: 0
      t.integer :home_score, default: 0
      t.integer :away_score, default: 0
      t.integer :winner_team, default: 0
      t.jsonb   :home_scorers, default: []
      t.jsonb   :away_scorers, default: []
      t.jsonb   :team_goals, default: []
      t.boolean :winner_team_is_correct
      t.integer :goals_off
      t.integer :correct_scorers
      t.integer :correct_team_goals
      t.integer :rank
      t.integer :user_id, index: true
      t.integer :match_id, index: true
      t.integer :ledger_entry_id, index: true

      t.timestamps
    end
  
    create_table :leagues do |t|
      t.string  :sm_id
      t.string  :handle
      t.string  :name
      t.boolean :active, default: false
      t.integer :sort_order, default: 1000
      t.string  :logo_url
      t.integer  :season_id, index: true

      t.timestamps
    end
  
    create_table :matches do |t|
      t.string   :sm_id
      t.datetime :starts_at
      t.string   :stadium
      t.integer  :hotness_rank, default: 10000
      t.integer  :status, default: 0
      t.integer  :home_score, default: 0
      t.integer  :away_score, default: 0
      t.jsonb    :goals, default: []
      t.boolean  :formation_synced, default: false
      t.boolean  :check_started_scheduled, default: false
      t.integer  :pool_status, default: 0
      t.float    :ticket_fee, default: 0.0
      t.integer  :pool_size, default: 0
      t.float    :real_prize, default: 0.0
      t.float    :real_chance, default: 0.0
      t.float    :estimated_prize, default: 0.0
      t.float    :estimated_chance, default: 0.0
      t.float    :prize_share, default: 0.0
      t.jsonb    :_league, default: {}
      t.jsonb    :_home_team, default: {}
      t.jsonb    :_away_team, default: {}
      t.integer  :league_id, index: true
      t.integer  :home_team_id, index: true
      t.integer  :away_team_id, index: true
      t.integer  :season_id, index: true
      t.integer  :prize_rule_id, index: true

      t.timestamps
    end
  
    create_table :notifs do |t|
      t.integer :kind, default: 0
      t.boolean :seen, default: false
      t.jsonb   :data, default: {}
      t.integer :user_id, index: true

      t.timestamps
    end
  
    create_table :players do |t|
      t.string  :sm_id
      t.string  :name
      t.integer :number
      t.integer :position, default: 0
      t.string  :image_url
      t.float   :goals_per_min, default: 0.0
      t.integer :team_id, index: true

      t.timestamps
    end
  
    create_table :prize_rules do |t|
      t.string  :name
      t.boolean :active, default: true
      t.jsonb   :rules, default: {}

      t.timestamps
    end
  
    create_table :seasons do |t|
      t.string  :sm_id
      t.integer :year
      t.string  :stage
      t.boolean :current, default: false
      t.integer :league_id, index: true

      t.timestamps
    end
  
    create_table :seasons_teams, id: false do |t|
      t.integer :season_id, null: false
      t.integer :team_id, null: false
      t.index   [:team_id, :season_id]
    end
  
    create_table :teams do |t|
      t.string  :sm_id
      t.string  :handle
      t.string  :name
      t.string  :code
      t.string  :logo_url
      t.integer :rank, default: 1000
      t.string  :formation
      t.jsonb   :formation_players, default: []
      
      t.timestamps
    end
  
    create_table :transfers do |t|
      t.string   :txid, index: { unique: true }
      t.datetime :performed_at
      t.float    :amount
      t.float    :fee
      t.jsonb    :details, default: []
      t.integer  :confirmations, default: 0
      
      t.timestamps
    end

    create_table :ledger_entries do |t|
      t.integer  :kind, default: 0
      t.integer  :status, default: 0
      t.float    :total
      t.float    :confirmed
      t.float    :locked
      t.string   :description
      t.boolean  :acceptable, default: true
      t.integer  :wallet_id, index: true
      t.integer  :transfer_id, index: true
      t.integer  :inverse_ledger_entry_id, index: true
      t.integer  :address_id, index: true
      
      t.timestamps
    end

    create_table :refunds do |t|
      t.integer :transfer_id, index: true
      t.integer :ledger_entry_id, index: true

      t.timestamps
    end
  
    create_table :wallets do |t|
      t.boolean :is_master, default: false
      t.float   :total, default: 0.0
      t.float   :confirmed, default: 0.0
      t.float   :locked, default: 0.0
      t.integer :owner_id
      t.string  :owner_type
      t.index   [:owner_id, :owner_type]

      t.timestamps
    end
  end
end
