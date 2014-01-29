class Settings < Settingslogic
  source "config/settings.yml"
  namespace ENV['RACK_ENV'] || "development"
end