ROOT = File.dirname(__FILE__)

#
# Verbosity: spit out more messages when set
VERBOSE=true

#
# TTL value ins seconds for Caching headers
TIME_TO_LIVE = 24 * 3600                      # default expiration time: 1 day

require "#{ROOT}/lib/logging.rb"
require "#{File.dirname(__FILE__)}/lib/magick_processor"
require "#{File.dirname(__FILE__)}/lib/mimes_types"
