require 'json'
require 'time'
require 'nokogiri'
require 'faraday'
require 'faraday_middleware'
require 'faraday-cookie_jar'
require 'faraday/detailed_logger'
require 'csv'

# MFP Raper - Connect to undocumented API, plunder some data and whatnot, and create a csv that contains a daily sum of each nutrient

login = 'FUUUUUUUUUUUU@gmail.com'  # your MFP login
password = 'putindid911'    # your MFP password

if (ARGV.length == 1 || ARGV.length == 2) && ARGV[0] =~ /\d\d\d\d-\d\d-\d\d/ && DateTime.parse(ARGV[0]) && DateTime.parse(ARGV[0]) <= DateTime.now && (ARGV.length == 1 || (ARGV[1] =~ /\d\d\d\d-\d\d-\d\d/ && DateTime.parse(ARGV[1]) && DateTime.parse(ARGV[1]) <= DateTime.now))
  from_date = DateTime.parse(ARGV[0])
  if ARGV.length == 2
    thru_date = DateTime.parse(ARGV[1])
  else
    thru_date = from_date
  end
else
  puts "Usage: #{$0} <from_date> [thru_date]\nDates must be in the form YYYY-MM-DD.  [thru_date] is optional, and if omitted will be set to the same as <from_date>"
  exit
end


conn = Faraday.new(:url => "https://www.myfitnesspal.com") do |builder|
  builder.use :cookie_jar
  builder.request :url_encoded
  #builder.response :detailed_logger
  builder.adapter Faraday.default_adapter
end

page = Nokogiri::HTML(conn.get('/account/login').body)
#token = page.xpath("//form[contains(@action, 'account/login')]/input[@name='authenticity_token']/@value")[0].to_s
token = page.xpath("//meta[contains(@name, 'csrf-token')]/@content")[0].to_s


login = conn.post('/account/login', {"utf8": '✓', "authenticity_token": token, "username": login, "password": password})
if login.body =~ /Incorrect username or password/
  puts "Incorrect username or password"
  exit
end


auth = conn.get('/user/auth_token', {'refresh': 'true'})
if auth.status == 200
  #puts "#{auth.body}"
  auth = JSON.parse(auth.body)
else
  puts "Couldn't call /user/auth_token.  Status = #{auth.status}"
  exit
end

api = Faraday.new(:url => "https://api.myfitnesspal.com") do |builder|
  builder.use :cookie_jar
  builder.request :url_encoded
  #builder.response :detailed_logger
  builder.adapter Faraday.default_adapter
end

api.headers['Authorization'] = "Bearer #{auth['access_token']}"
api.headers['mfp-client-id'] = "mfp-main-js"
api.headers['mfp-user-id'] = "#{auth['user_id']}"

dat = api.get("/v2/users/#{auth['user_id']}", {'fields' => ['diary_preferences','goal_preferences','unit_preferences','paid_subscriptions','account','goal_displays','location_preferences','system_data','profiles','step_sources','app_preferences']})
if dat.status == 200
  #puts "#{dat.body}"
  dat = JSON.parse(dat.body)
else
  puts "Couldn't call /v2/users/#{auth['user_id']}  Status = #{dat.status}"
  exit
end

nutrients = ["fat","saturated_fat","polyunsaturated_fat","monounsaturated_fat","trans_fat","cholesterol","sodium","potassium","carbohydrates","fiber","sugar","protein","vitamin_a","vitamin_c","calcium","iron","added_sugars","vitamin_d","sugar_alcohols"]

CSV.open('./food_data.csv', "wb") do |csv|
  csv << ["entry_date", "calories"] + nutrients
  
  from_date.upto(thru_date) do |x|
    puts "Downloading data for #{x.strftime("%Y-%m-%d")}"

    # other 'types':  ,exercise_entry,steps_aggregate
    day = api.get("/v2/diary", {'fields' => ['nutritional_contents'], 'entry_date' => x.strftime("%Y-%m-%d"), 'types' => 'food_entry'})
    if day.status != 200
      puts "Couldn't call /v2/diary for day #{x.strftime("%Y-%m-%d")}, Status = #{dat.status}"
      exit
    end

    day = JSON.parse(day.body)

    csv << [
      x.strftime("%Y-%m-%d"),
      day['items'].map{|x| x['nutritional_contents']['energy']['value'] || 0}.inject(0){|sum,x| sum + x }
    ] +
    nutrients.map{|nutrient| day['items'].map{|x| x['nutritional_contents'][nutrient] || 0}.inject(0){|sum,x| sum + x }}
  end

end
