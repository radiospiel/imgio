class RootController < Radio::Controller
  def params
    request.params
  end
  
  def process
    if request.get? 
      case request.path
      when %r{/fit(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)}
        captures = $~.captures

        _,format,quality,_,width,_,height,url,_ = *captures
        return process_img_io :fit, format, quality, width, height, url

      when %r{/fill(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)}
        captures = $~.captures

        _,format,quality,_,width,_,height,url,_ = *captures
        return process_img_io :fill, format, quality, width, height, url

      when %r{(/(jpg|png)([0-9]{1,3})?)?(/([0-9]{1,4})(/([0-9]{1,4}))?)/((http|https)://.*)} 
        captures = $~.captures

        _,format,quality,_,width,_,height,url,_ = *captures
        return process_img_io :scale_down, format, quality, width, height, url
      end
    end

    error404
  end

  def error404
    self.status = 404
    "Don't know how to handle #{request.path}"
  end

  def process_img_io(mode, format, quality, width, height, url)
    # set defaults
    format ||= "jpg"
    quality ||= 85

    blob = Magick.process mode, format, quality, width, height, url

    content_type mime_type_for(format)
    content_length blob.length
    expires TIME_TO_LIVE, :public

    blob
  end
end
