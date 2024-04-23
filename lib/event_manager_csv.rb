# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def format_phone_number(phone_number)
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number[1..phone_number.length]
  else
    "Phone num is not right #{phone_number}"
  end
end

def time_targeting(reg_date)
  reg_date_arr = reg_date.to_s.split(' ')
  date_arr = reg_date_arr[0].split('/')
  time_arr = reg_date_arr[1].split(':')
  new_time = Time.new(date_arr[2].rjust(4, '20'), date_arr[0], date_arr[1], time_arr[0], time_arr[1])
  new_time.strftime('%d/%m/%Y %I:%M %p %A')
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = format_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  reg_date = time_targeting(row[:regdate])
  puts reg_date
  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
