ROOT = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{ROOT}/lib"

#
# Verbosity: spit out more messages when set
VERBOSE=true

#
# TTL value ins seconds for Caching headers
TIME_TO_LIVE = 24 * 3600                      # default expiration time: 1 day

#
# 
ASYNC=defined?(Goliath)

require "logging"
require "magick_processor"
require "mime_types"
require "http"
