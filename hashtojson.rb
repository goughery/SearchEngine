require "fileutils"


def read_data(file_name)
  file = File.open(file_name,"r")
  object = eval(file.gets)
  file.close()
  return object
end

dictData = read_data("pagedata\/dict.dat") #http://cnn.com=>[page, page, page]
indexData = File.open("pagedata\/index.dat", "r").read() #1.html http://cnn.com

linksnet = read_data("pagedata\/linksnet.dat")
#docs = read_data("pagedata\/docs.dat") #put this in later

#print docs

#print linksnet

json = "{"
json << "\"nodes\":["
for key in linksnet.keys
  json << "{"
  json << "\"name\":\"#{key}\","
  json << "\"id\":#{key.split(".")[0]}"
  json << "},"  
end

json << "],"

json << "\"links\": ["
print "nodes stored. forming relationships..."

for key in linksnet.keys
  
  for link in linksnet[key]
    json << "{"
    json << "\"source\":#{key.split(".")[0]},"
    json << "\"target\":#{link.split(".")[0]},"
    json << "\"value\":1"
    json << "},"
  end
    
end


json << "]"
json << "}"

#need to filter out the last comma after each last element. },] -> should be no comma

place = json.index("]")
json[place-1] = ""

#find the second occurence of this happening

place = json.length-json.reverse.index("]")-1
#print place
#print json[place]
#print json[place-1]
json[place-1] = ""


jsonFile = File.open("../../../../cgi-pub/i427/links.json", "w")

jsonFile.write(json)

jsonFile.close()











#
#for key in linksnet.keys
#  json << "{"
#  json << "\"name\":\"#{key}\","
#  json << "\"id\":\"#{key.split(".")[0]}\""
#  json << "},"  
#end
#
#json << "],"
#
#json << "\"links\": ["
#print "nodes stored. forming relationships..."
#
#for key in linksnet.keys
#  
#  for link in linksnet[key]
#    json << "{"
#    json << "\"source\":\"#{key.split(".")[0]}\","
#    json << "\"target\":\"#{link.split(".")[0]}\","
#    json << "\"value\":1"
#    json << "},"
#  end
#    
#end

