def lorem_ipsum
  text = ''
  File.open(lorem_ipsum_path) { |f| text = f.read }
  text
end

def json_response
  JSON.parse((response || last_response).body)
end
