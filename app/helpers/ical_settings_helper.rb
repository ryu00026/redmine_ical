module IcalSettingsHelper
  def generate_url(token)
    "#{request.protocol}#{request.host_with_port}/exports/#{token}"
  end

end
