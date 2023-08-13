class Api::AuthController < ApiController

  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user.nil? || !user.authenticate(params[:password])
      render(status: 401, json: {error_code: 'credentials_invalid'})
    elsif !user.active?
      render(status: 412, json: {error_code: 'account_not_active'}) 
    else
      resp_hash = { user: DataFactory.make_user(user), id_token: Auth.get_id_token(user) }
      render(status: 200, json: resp_hash)
    end
  end

  def create_session
    decoded = Auth.decode_token(params[:id_token])
    if decoded.nil?
      render(status: 401, json: {error_code: 'token_invalid'}) and return
    end

    user = User.find_hash_by(id: decoded['id'])
    if user.nil?
      render(status: 401, json: {error_code: 'token_invalid'}) and return
    end

    resp_hash = { user: DataFactory.make_user(user), id_token: Auth.get_id_token(user) }
    render(status: 200, json: resp_hash)
  end

  def signup
    user = User.new(user_params)
    if user.save
      AccountMailer.activate_your_account(user.id).deliver_later
      resp_hash = { message: "User created. Check your #{user.email} for activation." }
      render(status: 200, json: resp_hash)
    else
      resp_hash = {
        error_code: 'validation_failed', 
        validation_errors: ValidationHelper.format_errors(user.errors.messages)
      }
      render(status: 422, json: resp_hash)
    end
  end

  def activate
    user = User.find_by(activation_token: params[:token]) if params[:token].present?
    if user && user.update(active: true, activation_token: nil)
      head :ok
    else
      render(status: 422, json: { error_code: 'token_invalid' })
    end
  end

  def send_reset_link
    user = User.find_by(email: params[:email].to_s.downcase) if params[:email].present?
    if user && user.active?
      user.set_new_pass_reset_token!
      AccountMailer.reset_your_password(user.id).deliver_later
    end
    head :ok
  end

  def validate_pass_reset_token
    valid = params[:token].present? && User.where(pass_reset_token: params[:token]).pluck(:id).any?
    render(status: 200, json: { token_is_valid: valid })
  end

  def reset_password
    user = User.find_by(pass_reset_token: params[:token]) if params[:token].present?
    
    if user.nil?
      render(status: 422, json: { error_code: 'token_invalid' }) and return
    end
    errors = {
      password: [],
      password_repeat: []
    }
    new_user = User.new(password: params[:password])
    errors[:password] = new_user.errors.messages[:password] if !new_user.valid?
    errors[:password_repeat] << 'does not match' if params[:password] != params[:password_repeat]
  
    if errors[:password].empty? && errors[:password_repeat].empty? 
      user.update!(password: params[:password], pass_reset_token: nil)
      head :ok
    else
      resp_hash = { error_code: 'validation_failed', validation_errors: ValidationHelper.format_errors(errors) }
      render(status: 422, json: resp_hash)
    end
  end

  private 

  def user_params
    params.permit(:username, :email, :password)
  end
end
