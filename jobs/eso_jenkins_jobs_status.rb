# Display last 5 Jenkins jobs and their status i.e. successful or failed

require File.expand_path('../../lib/jenkins', __FILE__)
require 'logger'

ESO_JOBS = [
  {
    'url' => ENV['JENKINS_MAIN_URL'],
    'jobs' => [
      {
        'actual_name' => 'SO_baseline_Staging',
        'short_name' => 'Baseline Staging'
      },
      {
        'actual_name' => 'SO_baseline_Release',
        'short_name' => 'Baseline Release'
      }
    ]
  }
]

ESO_HISTORY_LIMIT = 5
# Trim thresholds (widget display)
RFA_MAX_FILENAME_LENGTH = 40
RFA_FILENAME_TAIL_LENGTH = 40

SCHEDULER.every '5m', :first_in => 0 do
  getJobStatus
end

def getJobStatus
  build_status_history = {}
  jenkins_job_entries = []
  logger =  Logger.new('/proc/1/fd/1')
  ESO_JOBS.each do |info|

    jenkins_url = info['url']
    info['jobs'].each do |job|
      begin
        jenkins = Jenkins.new
        build_info = jenkins.list_of_builds(jenkins_url + '/job/' + job['actual_name'])
        job_history_entry = {}
        job_history_entry['job_name'] = trim_filename(job['short_name'])
        job_status_entries = []

        build_info.first(ESO_HISTORY_LIMIT).each do |build|
          status = get_eso_build_status(build['url'])
          job_status_entries << { 'build_no' => build['number'], 'status' => status }
        end

        job_history_entry['build_status'] = job_status_entries
        jenkins_job_entries << job_history_entry
      end
    end
  end
  unless jenkins_job_entries.empty?
    build_status_history['jenkins_jobs'] = jenkins_job_entries
    send_event('esoJobsHistory', build_status_history)
    end
end



def get_eso_build_status(build_url)
  jenkins = Jenkins.new
  status = get_result_from_eso_console(build_url)
  if jenkins.is_jenkins_build_ongoing(build_url)
    if status.nil?
      status = 'building' # ONGOING Build
    end
  end
  status
end

def get_result_from_eso_console(job_url)
  status = ''
  uri = URI.parse(job_url + 'consoleText')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth(ENV['DASHBOARD_USER'], ENV['DASHBOARD_PASS'])
  response = http.request(request)
  result = response.body.match(/(Finished: )\w+/).to_s.split(": ")[1]
  if result.eql? 'FAILURE'
    status = 'failure'
  elsif result.eql? 'SUCCESS'
    status = 'success'
  elsif result.eql? 'ABORTED'
    status = 'aborted'
  end
  status
end

def trim_filename(filename)
  filename_length = filename.length
  if filename_length > RFA_MAX_FILENAME_LENGTH
    filename = filename.to_s[0..RFA_MAX_FILENAME_LENGTH] + '...' + filename.to_s[(filename_length - RFA_FILENAME_TAIL_LENGTH)..filename_length]
  end
  filename
end