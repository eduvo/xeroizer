require 'dalli'

module Temporize
  extend self

  def check_and_wait
    stamp = dalli.get "#{key}-stamp"
    if stamp
      diff = Time.now.to_i - stamp
      if diff < 60
        count = dalli.get("#{key}-stamp").to_i
        if count >= 60
          sleep diff
          check_and_wait
        else
          dalli.incr "#{key}-count"
          return
        end
      end
    end
    dalli.set "#{key}-stamp", Time.now.to_i
    dalli.set "#{key}-count", 1
  end

  def dalli
    options = { :namespace => Rails.application.class.name}
    @__dalli ||= Dalli::Client.new('localhost:11211', options)
  end

  def key
    @__key ||= YAML.load_file("#{Rails.root}/config/xero.yml")[Rails.env]["key"]
  end

end
