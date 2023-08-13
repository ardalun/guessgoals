class Api::NotifsController < ApiController
  before_action :require_auth, only: [:index, :get_board_notifs, :mark_as_seen]

  RECORDS_PER_PAGE = 10

  def index
    all_notifs = Notif
      .where(user_id: @current_user_id)
      .order(created_at: :desc)

    notifs = all_notifs
      .offset((params[:page].to_i - 1) * RECORDS_PER_PAGE)
      .limit(RECORDS_PER_PAGE)
      .serialize(NotifSerializer)
      
    render(
      status: 200, 
      json: { 
        notifs: notifs,
        current_page: params[:page].to_i,
        records_per_page: RECORDS_PER_PAGE,
        total_records: all_notifs.count
      }
    )
  end

  def get_board_notifs
    result = Notif
      .where(user_id: @current_user_id)
      .order(Arel.sql('CASE WHEN seen IS false THEN 1 WHEN seen IS null THEN 2 else 3 end ASC'))
      .order(created_at: :desc)
      .limit(5)
      .serialize(NotifSerializer)
    render(status: 200, json: { notifs: result })
  end

  def mark_as_seen
    raise AppError::InvalidRequest if !params[:ids].is_a?(Array)

    not_owned_notif_ids = Notif
      .where(id: params[:ids])
      .where.not(user_id: @current_user_id)
      .pluck(:id)

    raise AppError::PermissionDenied if not_owned_notif_ids.present?

    found_target_ids = Notif.where(id: params[:ids]).pluck(:id)
    raise AppError::NotifNotFound if found_target_ids.count != params[:ids].count

    Db.atomically do
      Notif.where(id: params[:ids]).update_all(seen: true)
      updated_unseen_notifs = Notif.where(seen: false, user_id: @current_user_id).count
      User.where(id: @current_user_id).update_all(unseen_notifs: updated_unseen_notifs)
    end
    head 200
  rescue AppError::NotifNotFound => e
    render(status: 404, json: { error_code: 'notif_not_found' })
  rescue AppError::InvalidRequest => e
    render(status: 422, json: { error_code: 'invalid_request' })
  rescue AppError::PermissionDenied => e
    render(status: 403, json: { error_code: 'permission_denied' })
  end

end
