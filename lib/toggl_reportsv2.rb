require 'faraday'
require 'oj'
require 'uri'

require 'logger'
require 'awesome_print' # for debug output

require_relative 'togglv8'

# require_relative 'toggl_reportsv2/weekly'
require_relative 'toggl_reportsv2/detailed'
require_relative 'toggl_reportsv2/summary'
# require_relative 'toggl_reportsv2/dashboard'

# mode: :compat will convert symbols to strings
Oj.default_options = { mode: :compat }

module TogglReportsV2
  TOGGL_REPORTS_API_URL = 'https://www.toggl.com/reports/api/'

  class API
    TOGGL_REPORTS_API_V2_URL = TOGGL_REPORTS_API_URL + 'v2/'
    API_TOKEN = 'api_token'
    TOGGL_FILE = '.toggl'

    attr_reader :conn
    attr_accessor :user_agent, :workspace_id

    def initialize(username=nil, password=API_TOKEN, opts={})
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::WARN

      if username.nil? && password == API_TOKEN
        toggl_api_file = File.join(Dir.home, TOGGL_FILE)
        if FileTest.exist?(toggl_api_file) then
          username = IO.read(toggl_api_file)
        else
          raise "Expecting\n" +
            " 1) api_token in file #{toggl_api_file}, or\n" +
            " 2) parameter: (api_token), or\n" +
            " 3) parameters: (username, password).\n" +
            "\n\tSee https://github.com/toggl/toggl_api_docs/blob/master/chapters/authentication.md"
        end
      end
      
      standard_api = TogglV8::API.connection(username, password, opts)
      user = Oj.load(standard_api.get("me").body)
      @user_agent = user["data"]["email"]
      @workspace_id = user["data"]["default_wid"]
      puts @workspace_id
      @conn = TogglReportsV2::API.connection(username, password, opts)
    end

  #---------#
  # Private #
  #---------#

  private

    attr_writer :conn

    def self.connection(username, password, opts={})
      # Setting some sensible defaults for user_agent and workspace_id
      Faraday.new(url: TOGGL_REPORTS_API_V2_URL, ssl: {verify: true}) do |faraday|
        faraday.request :url_encoded
        faraday.response :logger, Logger.new('faraday.log') if opts[:log]
        faraday.adapter Faraday.default_adapter
        faraday.headers = { "Content-Type" => "application/json" }
        faraday.basic_auth username, password
      end
    end


    def requireParams(params, fields=[])
      raise ArgumentError, 'params is not a Hash' unless params.is_a? Hash
      return if fields.empty?
      errors = []
      for f in fields
        errors.push("params[#{f}] is required") unless params.has_key?(f)
      end
      raise ArgumentError, errors.join(', ') if !errors.empty?
    end


    def get(resource)
      @logger.debug("GET #{resource}")
      full_resp = self.conn.get(resource)
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)

      return resp['data'] if resp.respond_to?(:has_key?) && resp.has_key?('data')
      resp
    end

    def post(resource, data='')
      @logger.debug("POST #{resource} / #{data}")
      full_resp = self.conn.post(resource, Oj.dump(data))
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def put(resource, data='')
      @logger.debug("PUT #{resource} / #{data}")
      full_resp = self.conn.put(resource, Oj.dump(data))
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429
      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      resp = Oj.load(full_resp.body)
      resp['data']
    end

    def delete(resource)
      @logger.debug("DELETE #{resource}")
      full_resp = self.conn.delete(resource)
      # @logger.ap(full_resp.env, :debug)

      raise 'Too many requests in a given amount of time.' if full_resp.status == 429

      raise Oj.dump(full_resp.env) unless full_resp.success?
      return {} if full_resp.body.nil? || full_resp.body == 'null'

      full_resp.body
    end
  end
end
