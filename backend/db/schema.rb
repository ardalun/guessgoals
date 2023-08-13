# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_29_001654) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "code"
    t.boolean "used", default: false
    t.boolean "internal", default: true
    t.integer "wallet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_addresses_on_wallet_id"
  end

  create_table "highlights", force: :cascade do |t|
    t.string "uuid"
    t.integer "transfer_status", default: 0
    t.string "original_link"
    t.string "file_id"
    t.integer "match_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_highlights_on_match_id"
  end

  create_table "leagues", force: :cascade do |t|
    t.string "sm_id"
    t.string "handle"
    t.string "name"
    t.boolean "active", default: false
    t.integer "sort_order", default: 1000
    t.string "logo_url"
    t.integer "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_leagues_on_season_id"
  end

  create_table "ledger_entries", force: :cascade do |t|
    t.integer "kind", default: 0
    t.integer "status", default: 0
    t.float "total"
    t.float "confirmed"
    t.float "locked"
    t.string "description"
    t.boolean "acceptable", default: true
    t.integer "wallet_id"
    t.integer "transfer_id"
    t.integer "inverse_ledger_entry_id"
    t.integer "address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_ledger_entries_on_address_id"
    t.index ["inverse_ledger_entry_id"], name: "index_ledger_entries_on_inverse_ledger_entry_id"
    t.index ["transfer_id"], name: "index_ledger_entries_on_transfer_id"
    t.index ["wallet_id"], name: "index_ledger_entries_on_wallet_id"
  end

  create_table "matches", force: :cascade do |t|
    t.string "sm_id"
    t.datetime "starts_at"
    t.string "stadium"
    t.integer "hotness_rank", default: 10000
    t.integer "status", default: 0
    t.integer "home_score", default: 0
    t.integer "away_score", default: 0
    t.jsonb "goals", default: []
    t.boolean "formation_synced", default: false
    t.boolean "check_started_scheduled", default: false
    t.integer "pool_status", default: 0
    t.float "ticket_fee", default: 0.0
    t.integer "pool_size", default: 0
    t.float "real_prize", default: 0.0
    t.float "real_chance", default: 0.0
    t.float "estimated_prize", default: 0.0
    t.float "estimated_chance", default: 0.0
    t.float "prize_share", default: 0.0
    t.jsonb "_league", default: {}
    t.jsonb "_home_team", default: {}
    t.jsonb "_away_team", default: {}
    t.integer "league_id"
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "season_id"
    t.integer "prize_rule_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "highlights_synced", default: false
    t.boolean "pushed_to_social_media", default: false
    t.index ["away_team_id"], name: "index_matches_on_away_team_id"
    t.index ["home_team_id"], name: "index_matches_on_home_team_id"
    t.index ["league_id"], name: "index_matches_on_league_id"
    t.index ["prize_rule_id"], name: "index_matches_on_prize_rule_id"
    t.index ["season_id"], name: "index_matches_on_season_id"
  end

  create_table "notifs", force: :cascade do |t|
    t.integer "kind", default: 0
    t.boolean "seen", default: false
    t.jsonb "data", default: {}
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifs_on_user_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "sm_id"
    t.string "name"
    t.integer "number"
    t.integer "position", default: 0
    t.string "image_url"
    t.float "goals_per_min", default: 0.0
    t.integer "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_players_on_team_id"
  end

  create_table "plays", force: :cascade do |t|
    t.integer "payment_status", default: 0
    t.integer "home_score", default: 0
    t.integer "away_score", default: 0
    t.integer "winner_team", default: 0
    t.jsonb "home_scorers", default: []
    t.jsonb "away_scorers", default: []
    t.jsonb "team_goals", default: []
    t.boolean "winner_team_is_correct"
    t.integer "goals_off"
    t.integer "correct_scorers"
    t.integer "correct_team_goals"
    t.integer "rank"
    t.integer "user_id"
    t.integer "match_id"
    t.integer "ledger_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_entry_id"], name: "index_plays_on_ledger_entry_id"
    t.index ["match_id"], name: "index_plays_on_match_id"
    t.index ["user_id"], name: "index_plays_on_user_id"
  end

  create_table "prize_rules", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: true
    t.jsonb "rules", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.integer "transfer_id"
    t.integer "ledger_entry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ledger_entry_id"], name: "index_refunds_on_ledger_entry_id"
    t.index ["transfer_id"], name: "index_refunds_on_transfer_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "sm_id"
    t.integer "year"
    t.string "stage"
    t.boolean "current", default: false
    t.integer "league_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["league_id"], name: "index_seasons_on_league_id"
  end

  create_table "seasons_teams", id: false, force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "team_id", null: false
    t.index ["team_id", "season_id"], name: "index_seasons_teams_on_team_id_and_season_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "sm_id"
    t.string "handle"
    t.string "name"
    t.string "code"
    t.string "logo_url"
    t.integer "rank", default: 1000
    t.string "formation"
    t.jsonb "formation_players", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transfers", force: :cascade do |t|
    t.string "txid"
    t.datetime "performed_at"
    t.float "amount"
    t.float "fee"
    t.jsonb "details", default: []
    t.integer "confirmations", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["txid"], name: "index_transfers_on_txid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin", default: false
    t.boolean "active", default: false
    t.string "activation_token"
    t.string "pass_reset_token"
    t.datetime "pass_reset_last_sent"
    t.integer "unseen_notifs", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.boolean "is_master", default: false
    t.float "total", default: 0.0
    t.float "confirmed", default: 0.0
    t.float "locked", default: 0.0
    t.integer "owner_id"
    t.string "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id", "owner_type"], name: "index_wallets_on_owner_id_and_owner_type"
  end

end
