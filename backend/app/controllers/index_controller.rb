class IndexController < ActionController::Base

  def landing
    render plain: 'API is live ;)'
  end

  def sitemap
    @leagues = League.all
  end

  def notify
    Bitcoin.delay.check_transaction(params[:txid])
    head 200
  end
end