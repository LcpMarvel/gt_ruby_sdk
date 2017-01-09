require 'gt_ruby_sdk/version'
require 'gt_ruby_sdk/remote_server'
require 'gt_ruby_sdk/local_server'

module GtRubySdk
  class Base
    attr_reader :captcha_id, :private_key, :response

    RESPONSE_STATUS = {
      success: 1,
      failure: 0
    }.freeze

    # 构造函数
    def initialize(captcha_id, private_key)
      @captcha_id = captcha_id
      @private_key = private_key
    end

    # 预处理接口: 判断极验服务器是否down机
    def pretreat(user_id = nil)
      challenge = GtRubySdk::RemoteServer.register(captcha_id, user_id)

      return failed_pretreatment if challenge.size != 32

      successful_pretreatment(challenge)
    rescue Faraday::Error::ClientError
      failed_pretreatment
    end

    # 获取预处理结果的接口
    def response_json
      return if response.blank?

      JSON.generate(response)
    end

    # 极验服务器状态正常的二次验证接口
    def remote_validate(challenge, pin_code, seccode, user_id = nil)
      return false unless pin_code_validated?(challenge, pin_code)

      data = {
        seccode: seccode,
        sdk: GtRubySdk::VERSION
      }

      data[:user_id] = user_id if user_id.present?

      GtRubySdk::RemoteServer.validate(data) == Digest::MD5.hexdigest(seccode)
    end

    # 极验服务器状态宕机的二次验证接口
    def local_validate(challenge, pin_code, seccode)
      GtRubySdk::LocalServer.validate(challenge, pin_code, seccode)
    end

    private

    def failed_pretreatment
      challenge = GtRubySdk::LocalServer.register

      @response = build_response(false, challenge)

      RESPONSE_STATUS[:failure]
    end

    def successful_pretreatment(challenge)
      encrypted_challenge = Digest::MD5.hexdigest([challenge, private_key].join)

      @response = build_response(true, encrypted_challenge)

      RESPONSE_STATUS[:success]
    end

    def build_response(success, challenge)
      {
        success: success ? RESPONSE_STATUS[:success] : RESPONSE_STATUS[:failure],
        gt: captcha_id,
        challenge: challenge
      }
    end

    def pin_code_validated?(challenge, pin_code)
      return false if pin_code.size != 32

      Digest::MD5.hexdigest([private_key, 'geetest'.freeze, challenge].join) == pin_code
    end
  end
end
