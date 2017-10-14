require 'base64'
require 'net/http'
require 'json'

module PumaWorkerKiller
  class HerokuWrapper
    attr_accessor :heroku_api_token, :app_name

    def initialize(app_name, heroku_api_token)
      self.app_name = app_name
      self.heroku_api_token = heroku_api_token
    end

    def create_log_session
      uri = URI(log_sessions_url)
      req = Net::HTTP::Post.new(uri.path)
      req['Authorization'] = authorization
      req['Content-type'] = content_type
      req['Accept'] = accept
      req.set_form_data(
        {
          tail: true,
          source: 'heroku',
          dyno: ENV['DYNO'] || 'web.1'
        }
      )
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == "https")) {|http| http.request(req)}
      JSON.parse(res.body)['logplex_url']
    end

    def authorization
      "Basic " + Base64.encode64(":#{heroku_api_token}").gsub("\n", '')
    end

    private
    def content_type
      "application/json"
    end

    def accept
      "application/vnd.heroku+json; version=3"
    end

    def log_sessions_url
      "https://api.heroku.com/apps/#{app_name}/log-sessions"
    end
  end
end
