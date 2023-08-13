class ApiController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :set_session_variables
  before_action :redirect_www
  rescue_from Exception, :with => :render_500

  def set_session_variables
    Raven.extra_context(params: params.to_unsafe_h, url: request.url) if Rails.env.production?
    @timezone = request.headers['Timezone'] || 'UTC'

    id_token = request.headers['Authorization']
    decoded = Auth.decode_token(id_token)
    if decoded
      @current_user_id = decoded['id']
      Raven.user_context(id: decoded['id']) if Rails.env.production?
    end
  end

  def require_auth
    if @current_user_id.nil?
      render(status: 403, json: {error_code: 'auth_required_but_failed'}) and return
    end
  end

  def redirect_www
    if request.host == 'www.api.guessgoals.com'
      redirect_to 'https://api.guessgoals.com' + request.fullpath, status: 301
    end
  end

  def render_500(exception)
    @exception = exception
    app_traces = exception
      .backtrace
      .select { |line| line.include?('/app') }
      .map { |line| line[line.index('/app')..-1] }
    
    backtrace = [ exception.message ] + app_traces
    if Rails.env.development?
      puts backtrace.join("\n")
    end
    if Rails.env.production?
      Raven.capture_exception(exception)
    end
    render(status: 500, json: { error_code: 'server_crash', backtrace: backtrace })
  end
end
