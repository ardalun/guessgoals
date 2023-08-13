import Api from 'api/api';

export default class AuthApi {

  static login(formData) {
    return Api.frontendSend({
      method: 'post',
      url: '/login',
      data: formData
    });
  }

  static createSession(idToken) {
    return Api.frontendSend({
      method: 'post',
      url: '/sessions',
      data: {
        id_token: idToken
      }
    });
  }

  static signup(formData) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/signup',
      data: formData
    });
  }

  static sendResetLink(formData) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/send_reset_link',
      data: formData
    });
  }

  static activateAccount(token) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/activate',
      data: {
        token: token
      }
    })
  }

  static validatePassResetToken(token) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/validate_pass_reset_token',
      data: {
        token: token
      }
    })
  }

  static resetPassword(token, formData) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/reset_password',
      data: {
        token: token,
        ...formData
      }
    })
  }

  static activateAccount(token) {
    return Api.backendSend({
      method: 'post',
      url: '/auth/activate',
      data: {
        token: token
      }
    })
  }
}