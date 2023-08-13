class Admin::AuthController < AdminController
  def login_form
    if cookies.encrypted[:admin_id].present?
      redirect_to "/admin/logout"
    end
  end

  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user.present? && user.authenticate(params[:password]) && user.admin?
      cookies.encrypted[:admin_id] = user.id
      head :ok
      return
    end
    render json: { error_code: 'auth_failed' }, status: 401
  end

  def logout
    cookies.delete :admin_id
    redirect_to "/admin/login"
  end
end