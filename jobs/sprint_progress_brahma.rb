# Display story count for current sprint for team Anvil

require File.expand_path('../../lib/jira', __FILE__)

SCHEDULER.every '10m', :first_in => 0 do
  begin
    jira = Jira.new()
    # Get number of all stories in current sprint
    total_story_count = jira.retrieve_json("sprint in Opensprints() and sprint not in FutureSprints()
       and project=\"#{ENV['JIRA_PROJECT']}\" and \"SM Team Name\" = 'Brahma' and issuetype=\"Story\"&fields=total")['total']
    # Get number of closed stories in current sprint
    closed_story_count = jira.retrieve_json("sprint in Opensprints() and sprint not in FutureSprints()
      and project=\"#{ENV['JIRA_PROJECT']}\" and \"SM Team Name\" = 'Brahma' and issuetype=\"Story\" and status=\"Done\"&fields=total")['total']
    # Get number of stories in progress, in current sprint
    in_progress_story_count = jira.retrieve_json("sprint in Opensprints() and sprint not in FutureSprints()
      and project=\"#{ENV['JIRA_PROJECT']}\" and \"SM Team Name\" = 'Brahma' and issuetype=\"Story\" and status=\"In Progress\"&fields=total")['total']

    percentage_finished = ''
    stories_progressing = ''
    stories_finished = ''

    if total_story_count.zero?
      percentage_finished = 0
      stories_progressing = 'No sprint currently in progress'
    else
      percentage_finished = ((closed_story_count.to_f / total_story_count.to_f) * 100).round
      stories_progressing = "#{in_progress_story_count} out of #{total_story_count} stories are in progress"
      stories_finished = "#{closed_story_count} out of #{total_story_count} stories are finished"
    end
    send_event('BrahmaSprintProgress', title: "Team Brahma's Sprint Progress", min: 0, value: percentage_finished,
               max: 100, storiesProgressing: stories_progressing, storiesFinished: stories_finished)
  end
end