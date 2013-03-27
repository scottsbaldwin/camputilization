require 'date'

# select id, date(arrivalDate) as arrivalDate, date(departureDate) as departureDate from PersonBO where transitionState = 'Client' and arrivalDate is not null and departureDate is not null order by arrivalDate asc, departureDate asc;

index = []

dates = File.readlines(File.dirname(__FILE__) + "/dates.txt")
dates.each do |l|
  (id, arrival, departure) = l.split("\t")
  if !arrival.nil? && !departure.nil?
    idx = {
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

(2011..2013).each do |year|
  values[year] = []
  
  (1..52).each do |week|
    next if year == 2011 && week <= 23
    next if year == 2013 && week >= 45
    next if year == Date.today.year && week > Date.today.cweek
    
    matches = index.select { |line| 
      !line["arrivalYear"].nil? && !line["arrivalWeek"].nil? &&
      line["arrivalYear"] <= year && line["arrivalWeek"] <= week && 
      !line["departureYear"].nil? && !line["departureWeek"].nil? &&
      line["departureYear"] >= year && line["departureWeek"] >= week
    }

    #monday = 1
    sunday = Date.commercial(year, week, 1) - 1
    saturday = Date.commercial(year, week, 6)
    
    puts "%s\t%s\t%s\t%s" % [sunday, saturday, matches.length, week]
    
    values[year].push matches.length
  end
end

(2011..2013).each do |year|
  arr = values[year]
  sum = arr.inject { |sum, el| sum + el }
  mean = sum.to_f / arr.size
  max = arr.max
  min = arr.min
  puts "#{year} weekly average: %.00f" % [mean]
  puts "#{year} max: %.00f" % [max]
  puts "#{year} min: %.00f" % [min]
end