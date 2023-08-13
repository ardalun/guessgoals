class AdminController < ActionController::Base
  skip_before_action :verify_authenticity_token
  rescue_from Exception, :with => :render_500

  layout 'application'

  def require_admin_auth
    if cookies.encrypted[:admin_id]
      @user_id, @username, user_is_admin = User.where(id: cookies.encrypted[:admin_id]).pluck(:id, :username, :admin).first
    end

    redirect_to '/admin/login' if user_is_admin.blank?
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
    render(status: 500, json: { error_code: 'server_crash', message: exception.message, backtrace: backtrace })
  end
end