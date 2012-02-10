MIME_TYPES = {
  'jpg'  => 'image/jpeg',
  'gif'  => 'image/gif',
  'png'  => 'image/png'
}

def mime_type_for(format)
  MIME_TYPES[format] || "application/octet-stream"
end
