class Deal < ActiveRecord::Base
  belongs_to :advertiser

  validates_presence_of :advertiser, :value, :price, :description, :start_at, :end_at
  
  def self.search(search)
    if search
      joins(:advertiser => :publisher).where('advertisers.name LIKE ? or publishers.name LIKE ? or proposition LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      scoped
    end
  end

  def over?
    Time.zone.now > end_at
  end

  def savings_as_percentage
    0.5
  end

  def savings
    20
  end
end
