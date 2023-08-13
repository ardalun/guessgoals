class Api::LeaguesController < ApiController
  def index
    indexed_leagues = League.enabled.order(:sort_order).indexed_serialize(LeagueSerializer)
    render(status: 200, json: { leagues:  indexed_leagues })
  end
end
