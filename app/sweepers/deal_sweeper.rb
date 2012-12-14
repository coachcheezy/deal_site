class DealSweeper < ActionController::Caching::Sweeper
  observe Deal
  
  def sweep(deal)
    expire_page deals_path
    expire_page deal_path(deal)
    expire_page "/"
    FileUtils.rm_rf "#{page_cache_directory}/deals/page"
  end   
  
  alias_method :after_update, :sweep 
  alias_method :after_create, :sweep 
  alias_method :after_destroy, :sweep
end