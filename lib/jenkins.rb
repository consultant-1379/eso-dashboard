require 'net/http'
require 'json'
require File.expand_path('../logging', __FILE__)

class JenkinsConnectionException < StandardError
end

class Jenkins
  # Takes a full url for Jenkins json api, does authentication and gets JSON.
  # Please pass full URI: 
  # e.g. https://fem105-eiffel004.lmera.ericsson.se:8443/jenkins/job/ap-data-model-macro_PreCodeReview/api/json
  def retrieve_json(full_url)
    begin
      uri = URI.parse(full_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth(ENV['DASHBOARD_USER'], ENV['DASHBOARD_PASS'])
      response = http.request(request)
      json = JSON.parse(response.body)
      return json
    rescue => e
      raise JenkinsConnectionException, "Could not get json from Jenkins #{full_url}, details: #{e}"
    end
  end
  
  # Takes a full url for Jenkins job, including build number
  # Please pass full URI: 
  # e.g. https://fem105-eiffel004.lmera.ericsson.se:8443/jenkins/job/ap-data-model-macro_PreCodeReview/200/
  # will return TRUE for building (ongoing) and false otherwise.
  def is_jenkins_build_ongoing(individual_job_url)
    self.retrieve_json(individual_job_url + "/api/json?tree=building")["building"]
  end
  
  # Takes a full url for Jenkins job, including build number
  # Please pass full URI: 
  # e.g. https://fem105-eiffel004.lmera.ericsson.se:8443/jenkins/job/ap-data-model-macro_PreCodeReview/200/
  # will return "FAILURE", "ABORTED", "SUCCESS" etc
  def get_job_result(individual_job_url)
    retrieve_json(individual_job_url + "api/json?tree=result")['result']
  end
  
  # Takes a full url for Jenkins job, NOT including build number
  # Please pass full URI: 
  # e.g. https://fem105-eiffel004.lmera.ericsson.se:8443/jenkins/job/ap-data-model-macro_PreCodeReview/
  # will return a list of builds, with number and URL of build:
  # {"number":287,"url":"https://fem114-eiffel004.lmera.ericsson.se:8443/jenkins/job/RFA_Job/287/"},{"number":286,"url":"https://fem114-eiffel004.lmera.ericsson.se:8443/jenkins/job/RFA_Job/286/"},{"number":285,"url":"https://fem114-eiffel004.lmera.ericsson.se:8443/jenkins/job/RFA_Job/285/"}
  # etc etc
  def list_of_builds(job_url)
    retrieve_json(job_url + "/api/json?tree=builds%5Bnumber,url%5D")['builds']
  end

  def filtered_list_of_builds(job_url, key, expected_value)
    all_builds = retrieve_json(job_url + "/api/json?tree=builds[number,url]")['builds']

    valid_builds = []
    all_builds.each do |build|
      #status = get_result_from_allure_report(build['url'])
      job_json = retrieve_json(build['url'] + "/api/json?pretty&tree=actions[parameters[name,value]]")
      retrieved_value = get_value_from_json_object(job_json, key)
      if retrieved_value == expected_value
        valid_builds << build
      end
    end
    return valid_builds
  end
  
  #############################################################################
  ### COMMON JSON ACTIONS
  #############################################################################
  
  # Takes json object from a Jenkins job and sorts through it to find Allure URL
  def get_allure_report_url(json)
    for obj in json['actions']
      if obj.has_key?('parameters')
        for p in obj['parameters']
          if p.has_key?('name')
            if p['name'].to_s == 'TE_ALLURE_LOG_URL'.to_s || p['name'].to_s == 'Allure_URL'.to_s
              if p['value'].to_s.start_with?("http")
                allure_url = p['value']
                return allure_url
              end
            end
          end
        end
      end
    end
    return nil
  end
  
  def get_value_from_json_object(json, key)
      for obj in json['actions']
        if obj.has_key?('parameters')
          for o in obj['parameters']
            if o['name'].casecmp(key) == 0
                return o['value']
            end
          end
        end
      end
    raise "Cannot get the value for #{key} from Jenkins json"
  end
end
