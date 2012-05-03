class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  if FileTest.exists?("#{Rails.root}/config/parametri.yml") then
    logger.debug "FILE CARICATO CORRETTAMENTE" 
    $Init = YAML.load_file("#{Rails.root}/config/parametri.yml")
  else
    logger.debug "FILE NON PRESENTE" 
  end
end
