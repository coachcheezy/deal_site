namespace :import do
  desc "Import Deal Data. Pass in Publisher Name & location of data file in relation to Rails Root directory. i.e. rake import:deals['Publisher Name', 'script/data/data_file.txt']"
  task :deals, [:publisher, :data_file_location] => :environment do |t, args|
    Publisher.transaction do
      publisher = Publisher.create(:name => args[:publisher], :theme => args[:publisher].downcase.tr(' ', '-'))
      count = 0
      File.readlines("#{Rails.root}/#{args[:data_file_location]}").map do |line|
        unless count == 0
          merchant, start_date, end_date, deal, price, value = line.split("\t")
          advertiser = Advertiser.create(:name => merchant, :publisher_id => publisher.id)
          
          # Handle the scenario where either the end date or start date is not set
          # NOTE: Ideally we'd want require this data in the data file, but we will keep it as such for this exercise
          deal_dates = handle_empty_dates(start_date, end_date)          
          deal = Deal.create(:advertiser_id => advertiser.id, :proposition => deal, :value => value, :price => price, :start_at => parse_date(deal_dates[:start_date]), :end_at => parse_date(deal_dates[:end_date]), :description => deal)
        end  
        count = count + 1
      end
    end
  end
  
  def parse_date(date_string)
    if date_string.empty?
      return nil
    else
      month, day, year = date_string.split("/")
      DateTime.parse("#{day}/#{month}/#{year}")
    end  
  end
  
  def handle_empty_dates(start_date, end_date)
    dates = {:start_date => "", :end_date => ""}
    if start_date.empty? and end_date.empty?
      dates[:start_date] = Date.today.strftime("%m/%d/%Y")
      dates[:end_date] = Date.today.strftime("%m/%d/%Y")
    elsif start_date.empty? and !end_date.empty?
      dates[:start_date] = end_date
      dates[:end_date] = end_date
    elsif end_date.empty? and !start_date.empty? 
      dates[:start_date] = start_date
      dates[:end_date] = start_date
    else 
      dates[:start_date] = start_date
      dates[:end_date] = end_date
    end
    return dates
  end
end
