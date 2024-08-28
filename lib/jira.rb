require 'jira'
require 'logger'


class JiraConnectionException < StandardError
end

class Jira

  def initialize()
    @client = connect_to_jira()
  end

  def query_using_filter(filter_number)
    query_result = @client.Issue.jql("filter in (\"#{filter_number}\")")
    return query_result
  end

  def query_using_jql(jql_query)
    return @client.Issue.jql(jql_query)
  end

  def connect_to_jira
    jira_options = {
      :username => ENV['DASHBOARD_USER'],
      :password => ENV['DASHBOARD_PASS'],
      :context_path => URI.parse(ENV['JIRA_URL']).path,
      :site => URI.parse(ENV['JIRA_URL']).scheme + "://" + URI.parse(ENV['JIRA_URL']).host,
      :auth_type => :basic,
      :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
      :use_ssl => URI.parse(ENV['JIRA_URL']).scheme == 'https' ? true : false
    }
    return JIRA::Client.new(jira_options)
  end

  def retrieve_json(jql)
    begin
      full_url = ENV['JIRA_URL'] + "/rest/api/2/search?jql=" + jql
      uri = URI.parse(full_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(ENV['DASHBOARD_USER'], ENV['DASHBOARD_PASS'])
      response = http.request(request)
      json = JSON.parse(response.body)
      return json
    rescue => e
      raise JiraConnectionException, "Could not get json from Jira #{full_url}, details: #{e}"
    end
  end
end
