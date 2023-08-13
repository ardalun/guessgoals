class Auth
                
  def self.rsa_private
    if Rails.env.production?
      private_key = ENV['AUTH_PRIVATE_KEY'].gsub('\\n', "\n")
    else
      private_key = "-----BEGIN RSA PRIVATE KEY-----\nMIICWwIBAAKBgQDABPB6mUXRjG/h0NvI3ch0WakF+pb+ZDpsT0BhDmOY4Mhg12yi\nyty3LTS4kRe/6jh/5ZJkmn+6hREbQA0qYOCuUg6vrskcJ7e+Bogmt9zZoIPIVdy4\nqWBJcW/4Ywcych9W1hYbKr9aM9LIZKgQAlinQryyC37yGoR2Z4SfCw95+wIDAQAB\nAoGATp/3JAwspYAes9VEmXwOv22TIyqXtzStI3pT/ynYKFoqUlUDW6k7NRoik0x9\n8Axk9CG5js4gbOxds83HVkny1Ve8Ku/u4WysgcnkuAB41g2oOCsHm2s6Lrg1QXKk\nrPk0mUtXHQQxah9Cesd6S+YrPIdg2QBT2RJOd1NJSwSRtWECQQD0lX57qniUix11\nXSDpTewyYHU3TOUKL+rT4jxjYArSWhEYUsArKcneOR2wyKU2cIQBX0CaCvI0to5Q\nibrzJyNRAkEAyPtbJ5jtDfYkIFiE1jX0V4Q9sM8NUeunsitamTQ+A921ZTrlIaf9\n3Rtqv5PKr5nY/efXt61IPIGZ9hmdn9U9iwJAVb8TWMeq/mjHKx47K4/l/sNSVNDg\ne3HRIfdutGg3YwewdpaMSJWd8AqWHiQ5x5wqq1B5lYfA4joeKp4erKBMAQJAcT/5\n2HE6utBFARkAGTij66Cvpm61ocC5aRM25PdkLoeCzH0IWhOwYCQv3a3o21REyqYW\njwCMoNOiruM2R7dACwJAHbcLAqWpBti5iUfaBhMc93EQPVov4QdzaSBVZLV6lXSF\nXAljS1UJ0ApXQziT2lBIdUd88NU/J7+a2HZzgCBiWA==\n-----END RSA PRIVATE KEY-----"
    end
  	return OpenSSL::PKey::RSA.new(private_key)
  end

  def self.rsa_public
  	return self.rsa_private.public_key
  end
  
  def self.get_id_token(user)
    key = {
      id:       user[:id],
      username: user[:username],
      email:    user[:email]
    }
    JWT.encode key, Auth.rsa_private, 'RS256'
  end

  def self.decode_token(id_token)
    JWT.decode(id_token, Auth.rsa_public, true, {algorithm: 'RS256'})[0] rescue nil
  end
end