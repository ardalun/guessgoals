FactoryBot.create :league,
                  sm_id: 3
                  name: 'Champions League',
                  handle: 'champions-league',
                  seasons_count: 1, 
                  teams_per_season: 2, 
                  matches_per_season: 1
leagues = League.create! [
  {
    sm_id:      2,
    name:       'Champions League',
    handle:     'champions-league',
    logo_url:   'league_logos/champions-league.svg',
    sort_order: 1
  },
  {
    sm_id:      8,
    name:       'Premier League',
    handle:     'premier-league',
    logo_url:   'league_logos/premier-league.svg',
    sort_order: 2
  },
  {
    sm_id:      564,
    name:       'La Liga',
    handle:     'la-liga',
    logo_url:   'league_logos/la-liga.svg',
    sort_order: 3
  },
  {
    sm_id:      82,
    name:       'Bundesliga',
    handle:     'bundesliga',
    logo_url:   'league_logos/bundesliga.svg',
    sort_order: 4
  },
  {
    sm_id:      384,
    name:       'Serie A',
    handle:     'serie-a',
    logo_url:   'league_logos/serie-a.svg',
    sort_order: 5
  },
  {
    sm_id:      301,
    name:       'Ligue 1',
    handle:     'ligue-1',
    logo_url:   'league_logos/ligue-1.svg',
    sort_order: 6
  }
]

# User.create!(
#   username:        "meysam", 
#   email:           "me.feghhi@gmail.com", 
#   password:        "dingdong",
#   admin:           true,
#   active:          true
# )