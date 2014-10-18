# No need for millisecond precision in JSON DateTime representation
# See http://www.software-thoughts.com/2014/04/removing-milliseconds-in-json-under.html
ActiveSupport::JSON::Encoding.time_precision = 0
