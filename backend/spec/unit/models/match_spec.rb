# == Schema Information
#
# Table name: matches
#
#  id               :bigint(8)        not null, primary key
#  _away_team       :jsonb
#  _home_team       :jsonb
#  _league          :jsonb
#  away_score       :integer          default(0)
#  estimated_chance :float            default(0.0)
#  estimated_prize  :float            default(0.0)
#  formation_synced :boolean          default(FALSE)
#  goals            :jsonb
#  home_score       :integer          default(0)
#  hotness_rank     :integer          default(10000)
#  pool_size        :integer          default(0)
#  pool_status      :integer          default("betting_closed")
#  prize_share      :float            default(0.0)
#  real_chance      :float            default(0.0)
#  real_prize       :float            default(0.0)
#  stadium          :string
#  starts_at        :datetime
#  status           :integer          default("not_started")
#  ticket_fee       :float            default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  away_team_id     :integer
#  home_team_id     :integer
#  league_id        :integer
#  prize_rule_id    :integer
#  season_id        :integer
#  sm_id            :string
#
# Indexes
#
#  index_matches_on_away_team_id   (away_team_id)
#  index_matches_on_home_team_id   (home_team_id)
#  index_matches_on_league_id      (league_id)
#  index_matches_on_prize_rule_id  (prize_rule_id)
#  index_matches_on_season_id      (season_id)
#

require 'rails_helper'

RSpec.describe Match, type: :model do
  
  describe '.estimate_chance' do
    it 'works fine with pool_size = 0' do
      match = create(:match, pool_size: 0)
      expect(match.estimated_chance).to eq(50)
    end

    it 'works fine with pool_size = 1' do
      match = create(:match, pool_size: 1)
      expect(match.estimated_chance).to eq(50)
    end

    it 'works fine with pool_size = 10' do
      match = create(:match, pool_size: 10)
      expect(match.estimated_chance).to eq(9)
    end

    it 'works fine with pool_size = 500' do
      match = create(:match, pool_size: 500)
      expect(match.estimated_chance).to eq(0.2)
    end

    it 'works fine with pool_size = 56754' do
      match = create(:match, pool_size: 56754)
      expect(match.estimated_chance).to eq(0.002)
    end
  end

  describe '.calc_real_chance' do
    it 'works fine with pool_size = 0' do
      match = create(:match, pool_size: 0)
      expect(match.real_chance).to eq(0)
    end

    it 'works fine with pool_size = 1' do
      match = create(:match, pool_size: 1)
      expect(match.real_chance).to eq(100)
    end

    it 'works fine with pool_size = 10' do
      match = create(:match, pool_size: 10)
      expect(match.real_chance).to eq(10)
    end

    it 'works fine with pool_size = 500' do
      match = create(:match, pool_size: 500)
      expect(match.real_chance).to eq(0.2)
    end

    it 'works fine with pool_size = 56754' do
      match = create(:match, pool_size: 56754)
      expect(match.real_chance).to eq(0.002)
    end
  end

  describe '.estimate_prize' do
    it 'calculates prize with 2 pool_size if pool_size < 2' do
      match = build(:match, pool_size: 1)
      expect(match.prize_rule).to receive(:calculate_prize).with(2, match.ticket_fee)
      match.estimate_prize
    end

    it 'calculates prize with 1 more bettor if pool_size >= 2' do
      match = build(:match, pool_size: 2)
      expect(match.prize_rule).to receive(:calculate_prize).with(3, match.ticket_fee)
      match.estimate_prize
    end
  end

  describe '.calc_real_prize' do
    it 'calculates prize with real pool_size value when pool_size < 2' do
      match = build(:match, pool_size: 1)
      expect(match.prize_rule).to receive(:calculate_prize).with(1, match.ticket_fee)
      match.calc_real_prize
    end

    it 'calculates prize with real pool_size value when pool_size >= 2' do
      match = build(:match, pool_size: 2)
      expect(match.prize_rule).to receive(:calculate_prize).with(2, match.ticket_fee)
      match.calc_real_prize
    end
  end
  
  describe '.increment_pool_size!' do 
    it 'increments pool size and updates real and estimated chances and prizes' do
      match = create(:match, pool_size: 1)
      expect(match).to receive(:estimate_chance).and_return(50)
      expect(match).to receive(:calc_real_chance).and_return(33)
      expect(match).to receive(:estimate_prize).and_return(0.002)
      expect(match).to receive(:calc_real_prize).and_return(0.001)
      
      match.increment_pool_size!

      expect(match.pool_size).to        eq(2)
      expect(match.estimated_chance).to eq(50)
      expect(match.real_chance).to      eq(33)
      expect(match.estimated_prize).to  eq(0.002)
      expect(match.real_prize).to       eq(0.001)
    end

    it 'does not place play of ai if pool_size becomes anything other than 1' do
      match = create(:match, pool_size: 5)
      match.increment_pool_size!
      expect(match.pool_size).to eq(6)
    end

    it 'places play of ai if pool_size becomes 1' do
      match = create(:match, pool_size: 0)
      expect(match).to receive(:place_play_of_ai!)
      match.increment_pool_size!
    end
  end

  describe '.place_play_of_ai!' do
    it 'creates a play for ai on the match' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 5
      match  = league.season.matches.first
      match.update!(pool_size: 2)
      match.place_play_of_ai!
      expect(match.plays.count).to eq(1)
      ai_play = match.plays.last
      expect(ai_play.user).to eq(User.ai)
    end

    it 'raises error if ai has already played' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 5
      match  = league.season.matches.first
      match.update!(pool_size: 2)
      match.place_play_of_ai!
      expect {
        match.place_play_of_ai!
      }.to raise_error(AppError::AiAlreadyPlayed)
    end
  end

  describe '.start!' do
    it 'raises error if status is unknown' do
      match = create(:match, status: :unknown)
      expect {
        match.start!
      }.to raise_error(AppError::MatchMustBeInProgressOrFinished)
    end

    it 'raises error if status is not_started' do
      match = create(:match, status: :not_started)
      expect {
        match.start!
      }.to raise_error(AppError::MatchMustBeInProgressOrFinished)
    end

    it 'raises error if match already started' do
      match = create(:match, status: :in_progress, pool_status: :pending_outcome)
      expect {
        match.start!
      }.to raise_error(AppError::MatchAlreadyStarted)
    end

    it 'checks unconfirmed transactions of users whose plays have not been confirmed' do
      user = create(:user)
      confirmed_transfer = create(
        :transfer,
        confirmations: 1,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      unconfirmed_transfer = create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      play = build(:play, user_id: user.id)
      play.match.update!(pool_size: 2, status: :in_progress, ticket_fee: 0.002)
      play.save!

      expect(Bitcoin).to receive(:check_transaction).with(unconfirmed_transfer.txid)
      expect(Bitcoin).not_to receive(:check_transaction).with(confirmed_transfer.txid)
      play.match.start!
    end

    it 'marks not yet accepted plays late and schedules them to be declined' do
      user = create(:user)
      unconfirmed_transfer = create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      play = build(:play, user_id: user.id)
      play.match.update!(pool_size: 2, status: :in_progress, ticket_fee: 0.001)
      play.save!

      expect(Bitcoin).to receive(:check_transaction).with(unconfirmed_transfer.txid)
      expect(DeclinePlayWorker).to receive(:perform_async).with(play.id)
      play.match.start!
      play.reload
      expect(play.late?).to be(true)
    end

    it 'schedules accepted plays to be notified of the match start' do
      user = create(:user)
      unconfirmed_transfer = create(
        :transfer,
        confirmations: 0,
        details: [
          {
            category: 'receive',
            address:  user.wallet.addresses.last.code,
            amount:   '0.001',
            fee:      '0.0000001'
          }
        ]
      )
      play_1 = build(:play, user_id: user.id)
      match  = play_1.match
      match.update!(pool_size: 2, status: :in_progress, ticket_fee: 0.001)
      play_1.save!
      expect(Bitcoin).to receive(:check_transaction).with(unconfirmed_transfer.txid) do
        unconfirmed_transfer.receive_confirmation!(1)
      end

      play_2 = build(:play, match_id: match.id)
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      expect(DeclinePlayWorker).not_to receive(:perform_async)
      expect(NotifyMatchStartedWorker).to receive(:perform_async).with(play_1.id)
      expect(NotifyMatchStartedWorker).to receive(:perform_async).with(play_2.id)
      match.start!
      play_1.reload
      expect(play_1.accepted?).to be(true)
    end

    it 'changes pool_status to pending_outcome' do
      match = create(:match, status: :in_progress)
      match.start!
      expect(match.pending_outcome?).to be(true)
    end

    it 'schedules checking match has finished' do
      match = create(:match, status: :in_progress)
      expect(CheckMatchFinishedWorker).to receive(:perform_at)
      match.start!
    end
  end

  describe '.rank_plays!' do
    it 'raises error if match is not yet finished' do
      match = create(:match, status: :in_progress)
      expect {
        match.rank_plays!
      }.to raise_error(AppError::MatchMustBeFinished)
    end

    it 'raises error if match already finalized' do
      match = create(:match, status: :finished, pool_status: :finalized)
      expect {
        match.rank_plays!
      }.to raise_error(AppError::MatchAlreadyFinalized)
    end

    it 'ranks everyone first if no one survives winner team step' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1], 
        home_score: 1, 
        away_score: 0
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'away',
        home_score: 0,
        away_score: 1,
        home_scorers: [],
        away_scorers: [away_player_1],
        team_goals: ['away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!


      play_2 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 0,
        away_score: 0,
        home_scorers: [],
        away_scorers: [],
        team_goals: []
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(false)
      expect(play_1.goals_off).to              be(nil)
      expect(play_1.correct_scorers).to        be(nil)
      expect(play_1.correct_team_goals).to     be(nil)

      expect(play_2.rank).to                   eq(1)
      expect(play_2.winner_team_is_correct).to eq(false)
      expect(play_2.goals_off).to              be(nil)
      expect(play_2.correct_scorers).to        be(nil)
      expect(play_2.correct_team_goals).to     be(nil)
    end

    it 'knocks out plays with wrong winner team' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [], 
        home_score: 0, 
        away_score: 0
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'away',
        home_score: 0,
        away_score: 1,
        home_scorers: [],
        away_scorers: [away_player_1],
        team_goals: ['away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 0,
        away_score: 0,
        home_scorers: [],
        away_scorers: [],
        team_goals: []
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 0,
        away_score: 0,
        home_scorers: [],
        away_scorers: [],
        team_goals: []
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(2)
      expect(play_1.winner_team_is_correct).to eq(false)
      expect(play_1.goals_off).to              be(nil)
      expect(play_1.correct_scorers).to        be(nil)
      expect(play_1.correct_team_goals).to     be(nil)

      expect(play_2.rank).to                       eq(1)
      expect(play_2.winner_team_is_correct).to     eq(true)
      expect(play_2.goals_off).to                  be(0)
      expect(play_2.correct_scorers).to            be(0)
      expect(play_2.correct_team_goals).to         be(0)

      expect(play_3.rank).to                       eq(1)
      expect(play_3.winner_team_is_correct).to     eq(true)
      expect(play_3.goals_off).to                  be(0)
      expect(play_3.correct_scorers).to            be(0)
      expect(play_3.correct_team_goals).to         be(0)
    end

    it 'finds the winner in winner team step' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1], 
        home_score: 1, 
        away_score: 0
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 1,
        away_score: 0,
        home_scorers: [home_player_1],
        away_scorers: [],
        team_goals: ['home']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 0,
        away_score: 0,
        home_scorers: [],
        away_scorers: [],
        team_goals: []
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              be(nil)
      expect(play_1.correct_scorers).to        be(nil)
      expect(play_1.correct_team_goals).to     be(nil)

      expect(play_2.rank).to                   eq(2)
      expect(play_2.winner_team_is_correct).to eq(false)
      expect(play_2.goals_off).to              be(nil)
      expect(play_2.correct_scorers).to        be(nil)
      expect(play_2.correct_team_goals).to     be(nil)
    end

    it 'knocks out plays with not the best goal diffs' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1, home_player_1, away_player_1, away_player_1], 
        home_score: 3, 
        away_score: 2
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 2,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['away', 'home', 'home']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              eq(1)
      expect(play_1.correct_scorers).to        eq(4)
      expect(play_1.correct_team_goals).to     eq(4)

      expect(play_2.rank).to                   eq(1)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              eq(1)
      expect(play_2.correct_scorers).to        eq(4)
      expect(play_2.correct_team_goals).to     eq(4)

      expect(play_3.rank).to                   eq(2)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              eq(2)
      expect(play_3.correct_scorers).to        be(nil)
      expect(play_3.correct_team_goals).to     be(nil)
    end

    it 'finds the winner in team scores step' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1, home_player_1], 
        home_score: 3, 
        away_score: 0
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 0,
        home_scorers: [home_player_1, home_player_1, home_player_1],
        away_scorers: [],
        team_goals: ['home', 'home', 'home']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 2,
        away_score: 0,
        home_scorers: [home_player_1, home_player_1],
        away_scorers: [],
        team_goals: ['home', 'home']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 1,
        away_score: 0,
        home_scorers: [home_player_1],
        away_scorers: [],
        team_goals: ['home']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              be(0)
      expect(play_1.correct_scorers).to        be(nil)
      expect(play_1.correct_team_goals).to     be(nil)

      expect(play_2.rank).to                   eq(2)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              be(1)
      expect(play_2.correct_scorers).to        be(nil)
      expect(play_2.correct_team_goals).to     be(nil)

      expect(play_3.rank).to                   eq(3)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              be(2)
      expect(play_3.correct_scorers).to        be(nil)
      expect(play_3.correct_team_goals).to     be(nil)
    end

    it 'knocks out plays with not the most correct scorers' do 
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1, home_player_1, away_player_1, away_player_1], 
        home_score: 3, 
        away_score: 2
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_2],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              eq(1)
      expect(play_1.correct_scorers).to        eq(4)
      expect(play_1.correct_team_goals).to     eq(4)

      expect(play_2.rank).to                   eq(1)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              eq(1)
      expect(play_2.correct_scorers).to        eq(4)
      expect(play_2.correct_team_goals).to     eq(4)

      expect(play_3.rank).to                   eq(2)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              eq(1)
      expect(play_3.correct_scorers).to        be(3)
      expect(play_3.correct_team_goals).to     be(nil)
    end

    it 'finds the winner in scorers step' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1], 
        home_score: 2, 
        away_score: 0
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 2,
        away_score: 0,
        home_scorers: [home_player_1, home_player_1],
        away_scorers: [],
        team_goals: ['home', 'home']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 2,
        away_score: 0,
        home_scorers: [home_player_1, home_player_2],
        away_scorers: [],
        team_goals: ['home', 'home']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 2,
        away_score: 0,
        home_scorers: [home_player_2, home_player_2],
        away_scorers: [],
        team_goals: ['home', 'home']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              be(0)
      expect(play_1.correct_scorers).to        be(2)
      expect(play_1.correct_team_goals).to     be(nil)

      expect(play_2.rank).to                   eq(2)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              be(0)
      expect(play_2.correct_scorers).to        be(1)
      expect(play_2.correct_team_goals).to     be(nil)

      expect(play_3.rank).to                   eq(3)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              be(0)
      expect(play_3.correct_scorers).to        be(0)
      expect(play_3.correct_team_goals).to     be(nil)
    end

    it 'knocks out plays with not the most correct team goals' do
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1, away_player_1, away_player_1], 
        home_score: 2, 
        away_score: 2
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 2,
        away_score: 2,
        home_scorers: [home_player_1, home_player_1], 
        away_scorers: [away_player_1, away_player_1],
        team_goals: ['home', 'home', 'away', 'away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 2,
        away_score: 2,
        home_scorers: [home_player_1, home_player_1], 
        away_scorers: [away_player_1, away_player_1],
        team_goals: ['home', 'away', 'home', 'away']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'draw',
        home_score: 2,
        away_score: 2,
        home_scorers: [home_player_1, home_player_1], 
        away_scorers: [away_player_1, away_player_1],
        team_goals: ['away', 'away', 'home', 'home']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              eq(0)
      expect(play_1.correct_scorers).to        eq(4)
      expect(play_1.correct_team_goals).to     eq(4)

      expect(play_2.rank).to                   eq(2)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              eq(0)
      expect(play_2.correct_scorers).to        eq(4)
      expect(play_2.correct_team_goals).to     eq(2)

      expect(play_3.rank).to                   eq(3)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              eq(0)
      expect(play_3.correct_scorers).to        be(4)
      expect(play_3.correct_team_goals).to     be(0)
    end

    it 'finds the winner in team goals step' do 
      league = create :league, seasons_count: 1, teams_per_season: 2, matches_per_season: 1, players_per_team: 2
      match  = league.season.matches.first
      home_player_1, home_player_2 = match.home_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'home'} }
      away_player_1, away_player_2 = match.away_team.players.serialize(PlayerSerializer).map { |record| {id: record[:id], name: record[:name], player_sm_id: record[:sm_id], team: 'away'} }
      match.update!(
        ticket_fee: 0.001, 
        goals: [home_player_1, home_player_1, home_player_1, away_player_1, away_player_1], 
        home_score: 3, 
        away_score: 2
      )
      expect(match).to receive(:place_play_of_ai!)
      
      play_1 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'home', 'away']
      )
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'away', 'home']
      )
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(
        :play,
        match: match,
        winner_team: 'home',
        home_score: 3,
        away_score: 1,
        home_scorers: [home_player_1, home_player_1, home_player_1], 
        away_scorers: [away_player_1],
        team_goals: ['home', 'home', 'away', 'home']
      )
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.update!(status: :finished)
      match.rank_plays!

      play_1.reload
      play_2.reload
      play_3.reload

      expect(play_1.rank).to                   eq(1)
      expect(play_1.winner_team_is_correct).to eq(true)
      expect(play_1.goals_off).to              eq(1)
      expect(play_1.correct_scorers).to        eq(4)
      expect(play_1.correct_team_goals).to     eq(4)

      expect(play_2.rank).to                   eq(2)
      expect(play_2.winner_team_is_correct).to eq(true)
      expect(play_2.goals_off).to              eq(1)
      expect(play_2.correct_scorers).to        eq(4)
      expect(play_2.correct_team_goals).to     eq(2)

      expect(play_3.rank).to                   eq(2)
      expect(play_3.winner_team_is_correct).to eq(true)
      expect(play_3.goals_off).to              eq(1)
      expect(play_3.correct_scorers).to        be(4)
      expect(play_3.correct_team_goals).to     be(2)
    end
  end

  describe '.deliver_prizes!' do
    it 'delivers prizes to winner wallets and profit to master wallet' do
      match = create(:match, ticket_fee: 0.001)
      expect(match).to receive(:place_play_of_ai!)

      play_1 = build(:play, match: match, rank: 1)
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(:play, match: match, rank: 2)
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(:play, match: match, rank: 3)
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.wallet.reload
      total_available_funds = match.wallet.confirmed

      match.deliver_prizes!

      play_1.user.wallet.reload
      play_2.user.wallet.reload
      play_3.user.wallet.reload
      match.wallet.reload

      expect(play_1.user.wallet.confirmed).to eq(match.real_prize)
      prize_transfer_entry = play_1.user.wallet.ledger_entries.find_by(kind: :prize_transfer)
      expect(prize_transfer_entry).not_to           be(nil)
      expect(prize_transfer_entry.is_confirmed?).to be(true)
      expect(play_2.user.wallet.confirmed).to       eq(0)
      expect(play_3.user.wallet.confirmed).to       eq(0)
      expect(match.wallet.confirmed).to             eq(0)
      expect(Wallet.master.confirmed).to            eq(Calc.sub(total_available_funds, match.real_prize))
      revenue_transfer_entry = Wallet.master.ledger_entries.find_by(kind: :revenue_transfer)
      expect(revenue_transfer_entry).not_to           be(nil)
      expect(revenue_transfer_entry.is_confirmed?).to be(true)
    end

    it 'does not pay profit to master wallet if there is none' do
      match = create(:match, ticket_fee: 0.001)
      expect(match).to receive(:place_play_of_ai!)

      play_1 = build(:play, match: match, rank: 1)
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(:play, match: match, rank: 2)
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      match.wallet.reload
      total_available_funds = match.wallet.confirmed

      match.deliver_prizes!

      play_1.user.wallet.reload
      play_2.user.wallet.reload
      match.wallet.reload

      expect(play_1.user.wallet.confirmed).to       eq(match.real_prize)
      prize_transfer_entry = play_1.user.wallet.ledger_entries.find_by(kind: :prize_transfer)
      expect(prize_transfer_entry).not_to           be(nil)
      expect(prize_transfer_entry.is_confirmed?).to be(true)
      expect(play_2.user.wallet.confirmed).to       eq(0)
      expect(match.wallet.confirmed).to             eq(0)
      expect(Wallet.master.confirmed).to            eq(0)
    end
  end

  describe '.make_final_notifs!' do
    it 'makes all notifs for winners and losers' do
      match = create(:match, ticket_fee: 0.001)
      expect(match).to receive(:place_play_of_ai!)

      play_1 = build(:play, match: match, rank: 1)
      play_1.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_1.save!

      play_2 = build(:play, match: match, rank: 1)
      play_2.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_2.save!

      play_3 = build(:play, match: match, rank: 2)
      play_3.user.wallet.update!(total: 0.001, confirmed: 0.001)
      play_3.save!

      match.make_final_notifs!
      notif_1 = play_1.user.notifs.find_by(kind: :pool_won)
      notif_2 = play_2.user.notifs.find_by(kind: :pool_won)
      notif_3 = play_3.user.notifs.find_by(kind: :pool_lost)

      expect(notif_1.present?).to be(true)
      expect(notif_2.present?).to be(true)
      expect(notif_3.present?).to be(true)
      expect(notif_3.data['play_rank']).to eq(2)
    end
  end

  describe '.finalize!' do
    it 'raises error if match is not finished' do
      match = create(:match, status: :in_progress)
      expect {
        match.finalize!
      }.to raise_error(AppError::MatchMustBeFinished)
    end

    it 'raises error if match already finalized' do
      match = create(:match, status: :finished, pool_status: :finalized)
      expect {
        match.finalize!
      }.to raise_error(AppError::MatchAlreadyFinalized)
    end

    it 'finalizes the match' do
      match = create(:match, status: :finished)
      expect(match).to receive(:rank_plays!)
      expect(match).to receive(:deliver_prizes!)
      expect(match).to receive(:make_final_notifs!)
      match.finalize!
      expect(match.finalized?).to be(true)
    end

  end

  describe '.count_correct_scorers' do
    let!(:match) { build(:match) }

    it 'counts correctly if predicted no goals correctly' do
      expect(match.count_correct_scorers([1, 2, 3], [4, 5, 6])).to eq(0)
    end

    it 'counts correctly if predicted less goals for scorers' do
      expect(match.count_correct_scorers([1, 2, 2, 3], [1, 2, 6])).to eq(2)
    end

    it 'counts correctly if predicted exat number of goals for scorers' do
      expect(match.count_correct_scorers([1, 2, 2, 3], [1, 2, 2, 6])).to eq(3)
    end

    it 'counts correctly if predicted more goals for scorers' do
      expect(match.count_correct_scorers([1, 2, 2, 3], [1, 2, 2, 2, 6])).to eq(3)
    end
  end

  describe '.count_correct_team_goals' do
    let!(:match) { build(:match) }

    it 'counts correctly if play predicted 0 goals' do
      expect(match.count_correct_team_goals(['home', 'away', 'away'], [])).to eq(0)
    end

    it 'counts correctly if play predicted less than match goals' do
      expect(match.count_correct_team_goals(['home', 'away', 'away'], ['home', 'away'])).to eq(2)
    end

    it 'counts correctly if play predicted more than match goals' do
      expect(match.count_correct_team_goals(['home', 'away'], ['home', 'away', 'away'])).to eq(2)
    end

    it 'counts correctly if play predicted no goals correctly' do
      expect(match.count_correct_team_goals(['home', 'away', 'away'], ['away', 'home', 'home'])).to eq(0)
    end

    it 'counts correctly if play predicted some goals correctly' do
      expect(match.count_correct_team_goals(['home', 'away', 'away'], ['away', 'away', 'home'])).to eq(1)
    end

    it 'counts correctly if play predicted all goals correctly' do
      expect(match.count_correct_team_goals(['home', 'away', 'away'], ['home', 'away', 'away'])).to eq(3)
    end
  end

end