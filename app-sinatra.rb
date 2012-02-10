require "#{File.dirname(__FILE__)}/config"
require "#{File.dirname(__FILE__)}/lib/magick_processor"

# --- URL parsing -------------------------------------------------------------

#
# Say hi!
get '/' do
  'Hello, world!'
end

get %r{/fit(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  dlog params[:captures].inspect

  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :fit, format, quality, width, height, url
end

get %r{/fill(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :fill, format, quality, width, height, url
end

get %r{(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} do
  # get parameters
  _,format,quality,_,width,_,height,url,_ = *params[:captures]
  process :scale_down, format, quality, width, height, url
end

# -----------------------------------------------------------------------------

# --- various helpers ---------------------------------------------------------

helpers do
  def process(mode, format, quality, width, height, url)
    # set defaults
    format ||= "jpg"
    quality ||= 85

    blob = Magick.process mode, format, quality, width, height, url

    content_type mime_type_for(format)
    response['Content-Length'] = blob.length.to_s

    # see http://devcenter.heroku.com/articles/http-caching
    expires TIME_TO_LIVE, :public

    blob
  end
end

# -----------------------------------------------------------------------------
