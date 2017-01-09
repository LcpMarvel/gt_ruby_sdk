require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'gt_ruby_sdk'
require 'json'

CAPTCHA_ID = 'b46d1900d0a894591916ea94ea91bd2c'.freeze
PRIVATE_KEY = '36fc3fe98530eea08dfc6ce76e3d24c4'.freeze
MOBILE_CAPTCHA_ID = '7c25da6fe21944cfe507d2f9876775a9'.freeze
MOBILE_PRIVATE_KEY = 'f5883f4ee3bd4fa8caec67941de1b903'.freeze

enable :sessions

get '/' do
  erb :index
end

get '/register' do
  content_type :json

  user_id = 'test'
  status = gt_client.pretreat(user_id)
  session['gtserver'] = status
  session['user_id'] = user_id

  gt_client.response_json
end

post '/validate' do
  content_type :json

  user_id = session['user_id']
  result = false

  if session['gtserver'] == 1
    result = gt_client.remote_validate(
      params[:geetest_challenge],
      params[:geetest_validate],
      params[:geetest_seccode],
      user_id
    )
  else
    result = gt_client.local_validate(
      params[:geetest_challenge],
      params[:geetest_validate],
      params[:geetest_seccode]
    )
  end

  { status: result ? 'success' : 'fail' }.to_json
end

def gt_client
  @gt_client ||= if params[:type] == 'pc'
                   GtRubySdk::Base.new(CAPTCHA_ID, PRIVATE_KEY)
                 else
                   GtRubySdk::Base.new(MOBILE_CAPTCHA_ID, MOBILE_PRIVATE_KEY)
                 end
end
