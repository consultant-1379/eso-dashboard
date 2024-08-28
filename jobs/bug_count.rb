# Displays bugs count based on a Jira jql query

require File.expand_path('../../lib/jira', __FILE__)

SCHEDULER.every '5m', :first_in => 0 do
  begin
    jira = Jira.new
    fetched = jira.retrieve_json("filter=#{ENV['JIRA_FILTER_NUM']}&fields=total")
    bug_status = fetched['total']
    status = case bug_status
      when 0..3 then 'ok'
      when 4..7 then 'danger'
      when 8..20 then 'warning'
      else 'warning'
    end
    send_event('bugs', current: bug_status, status: status, emoji: '🐞')
  end
end