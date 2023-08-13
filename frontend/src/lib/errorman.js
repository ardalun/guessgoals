import { deepRead } from 'lib/helpers';
import { alertError } from 'lib/alert';

const translate = (code) => {
  
  const dict = {
    default: "An unexpected error has occurred! We were notified and will work on it to get it fixed as soon as possible.",
    account_not_active: "Your account is not yet activated",
    match_not_found: "We cannot seem to find that match",
    credentials_invalid: "Invalid email and password combination",
    auth_required_but_failed: "We were unable to authenticate your request. Try logging in.",
    user_already_played: "You have already entered this pool",
    permission_denied: "You do not have permission for this action",
    invalid_request: "We could not validate your request",
    notif_not_found: "We cannot seem to find that notification",
    pool_is_closed: "Sorry, this match is no longer open for betting",
    no_funds_available_for_payout: "It seems that you do not have any funds available for payout. You can always ask our support team for help."
  }

  if (code in dict)
    return dict[code];
  else
    return dict.default;
}

export const handleBackendError = (error) => {
  if (process.env.NODE_ENV !== 'production') {
    const backtrace = deepRead(error, 'response.data.backtrace');
    if (backtrace) { 
      alertError(backtrace); 
    } else {
      console.log(deepRead(error, 'response.data'));
    }
    if (typeof document === 'undefined') {
      console.log(error);
    }
  }

  const errorCode = deepRead(error, 'response.data.error_code');
  alertError(translate(errorCode));
}