require 'date'

# select id, date(arrivalDate) as arrivalDate, date(departureDate) as departureDate from PersonBO where transitionState = 'Client' and arrivalDate is not null and departureDate is not null order by arrivalDate asc, departureDate asc;

index = []

dates = File.readlines(File.dirname(__FILE__) + "/dates.txt")
dates.each do |l|
  (id, arrival, departure) = l.split("\t")
  if !arrival.nil? && !departure.nil?
    idx = {
      "id" => id,
      "arrival" => Date.parse(arrival),
      "departure" => Date.parse(departure),
      "arrivalWeek" => Date.parse(arrival).cweek(),
      "arrivalYear" => Date.parse(arrival).year(),
      "arrivalDay" => Date.parse(arrival).yday(),
      "departureWeek" => Date.parse(departure).cweek(),
      "departureYear" => Date.parse(departure).year(),
      "departureDay" => Date.parse(departure).yday()
    }
    index.push idx
  end
end

values = {}
week_data = {}

puts "\nStart\tEnd\tPeople at Camp"

(2011..2013).each do |year|
  values[year] = []
  
  (1..52).each do |week|
    next if year == 2011 && week <= 23
    #next if year == 2013 && week >= 45
    next if year == Date.today.year && week > Date.today.cweek

    #monday = 1
    sunday = Date.commercial(year, week, 1) - 1
    saturday = Date.commercial(year, week, 6)
    
    matches = index.select { |line| 
      !line["arrival"].nil? && !line["departure"].nil? && 
      line["arrival"] <= saturday && line["departure"] >= sunday
    }

    week_data["#{sunday} to #{saturday}"] = matches

    puts "%s\t%s\t%s" % [sunday, saturday, matches.length]
    
    values[year].push matches.length
  end
end

week_data.each do |key,value|
  vals = value.map { |v| {"id" => v["id"], "arrival" => v["arrival"], "departure" => v["departure"]} }
  puts "\nRaw data for #{key}"
  puts "Counter\tID\tArrival\tDeparture"
  vals.each_with_index do |v, i| 
    puts "#{i+1}\t#{v['id']}\t#{v['arrival']}\t#{v['departure']}"
  end
end

(2011..2013).each do |year|
  arr = values[year]
  sum = arr.inject { |sum, el| sum + el }
  mean = sum.to_f / arr.size
  max = arr.max
  min = arr.min
  puts "\n#{year} weekly average: %.00f" % [mean]
  puts "#{year} max: %.00f" % [max]
  puts "#{year} min: %.00f" % [min]
end