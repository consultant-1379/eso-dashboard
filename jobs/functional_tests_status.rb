require 'csv'
require 'open-uri'
require File.expand_path('../../lib/jenkins', __FILE__)

# Get csv file
def parse_csv(build_number)
  buildNotFinished = true
  count = 0
  csv_file = '/tmp/csvfile.txt'

  while buildNotFinished do
    full_url = "#{ENV['JENKINS_MAIN_URL']}/job/SO_baseline_Staging/#{build_number - count}/allure/data/suites.csv"
    uri = URI.parse(full_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    csv_response = response.body.to_s
    if csv_response.include? 'Not found'
      count += 1
    else
      buildNotFinished = false
      File.open(csv_file, 'w') { |file| file.write(csv_response) }
    end
  end

  results = []
  CSV.foreach(csv_file) do |test|
    testName = test[1].sub(/.*(\.)/, '')
    testName = testName.remove("test")
    chars = testName.split('')
    testName = ""
    chars.each do |c|
      if(/[[:upper:]]/.match(c))
        testName += " " + c
      else
        testName += c
      end
    end
    status = test[0]
    if (status == 'Status')
      next
    elsif (status == 'passed')
      result = 1
      arrow = 'icon-ok-sign'
      color = 'green'
    elsif (status == 'failed')
      result = 0
      arrow = 'icon-warning-sign'
      color = "red"
    else
      result = -1
      arrow = 'icon-question-sign'
      color = 'red'
    end
    results.push(label: testName, value: result, arrow: arrow, color: color)
  end
  return results
rescue => e
  return results
end

SCHEDULER.every '10m', :first_in => 0 do
  jenkins_url = ENV['JENKINS_MAIN_URL']
  jenkins = Jenkins.new
  build_info = jenkins.list_of_builds(jenkins_url + '/job/' + 'SO_baseline_Staging')
  results = parse_csv(build_info.first['number'])
  widget_title = ''
  if(results == nil)
    widget_title = "No Recent Allure Reports Found in SO_baseline_Staging"
  else
    widget_title = 'Status of Functional Tests'
  end
  send_event('tests_status', items: results, title: widget_title)
end
