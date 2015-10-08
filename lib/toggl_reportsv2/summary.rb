module TogglReportsV2
  class API

    ##
    # ---------
    # :section: Summary 
    #
    # https://github.com/toggl/toggl_api_docs/blob/master/reports/summary.md
    #
    # description  : (string, strongly suggested to be used)
    # user_agent   : string, required, the name of your application or your email address so we can get in touch in case you're doing something wrong
    # workspace_id : integer, required. The workspace whose data you want to access
    # since        : string, ISO 8601 date (YYYY-MM-DD), by default until - 6 days
    # until        : string, ISO 8601 date (YYYY-MM-DD), by default today
    #
    # created_with : the name of your client app (string, required)
    # tags         : a list of tag names (array of strings, not required)
    # duronly      : should Toggl show the start and stop time of this time entry? (boolean, not required)
    # at           : timestamp that is sent in the response, indicates the time item was last updated

    def get_summary_report(params = {})
      params["user_agent"] = self.user_agent unless params["user_agent"]
      params["workspace_id"] = self.workspace_id unless params["workspace_id"]
      puts params
      get "summary%s" % [params.nil? ? "" : "?#{URI.encode_www_form(params)}"]
    end
  end
end
