puts 'Event Manager Initialized!'

filename = './event_attendees.csv'

# It is prefered to check if file exists first
# contents = File.exist?(filename) ? File.read(filename) : 'No such file was found'

lines = File.readlines(filename)
lines.each_with_index do |line, index|
  # one way to skip header
  # next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
  next if index.zero?

  columns = line.split(',')
  # printing out only first_name col
  name = columns[2]
  puts name
end

# puts contents
