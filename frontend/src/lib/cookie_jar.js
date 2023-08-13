export default class CookieJar {
  
  static getDocumentCookie(name) {
    if (typeof document !== 'undefined') {
      var v = document.cookie.match('(^|;) ?' + name + '=([^;]*)(;|$)');
      return v ? v[2] : null;
    } else {
      console.log('document is undefined');
      return null;
    }
  }

  static setDocumentCookie(name, value, days) {
    if (typeof document !== 'undefined') {
      var d = new Date;
      d.setTime(d.getTime() + 24 * 60 * 60 * 1000 * days);
      document.cookie = name + "=" + value + ";path=/;expires=" + d.toGMTString();
    } else {
      console.log('document is undefined');
    }
  }

  static deleteDocumentCookie(name) {
    this.setDocumentCookie(name, '', -1);
  }

  static findCookie(cookieString, name) {
    var v = cookieString.match('(^|;) ?' + name + '=([^;]*)(;|$)');
    return v ? v[2] : null;
  }
}