require "fileutils"

def read_data(file_name)
  file = File.open(file_name,"r")
  object = eval(file.gets)
  file.close()
  return object
end

dictData = read_data("pagedata\/dict.dat") #http://cnn.com=>[page, page, page]
indexData = File.open("pagedata\/index.dat", "r").read() #1.html http://cnn.com
#print dictData.keys
#dictionary = Hash.new(dictData)
#for key in dictData.keys
#  if not "http".match(key)
#    print key 
#    print "\n"
#  end
#end
#print indexData

indexData = indexData.split("\n") #1.html http://cnn.com
indexDict = {}

#make a simple dictionary from the index.dat to refer back to later
#http://cnn.com=>1.html

iterlist = []
for line in indexData
  line = line.split(" ")
  indexDict[line[1]] = line[0]
  iterlist << line[1]
end
#print iterlist

prDict = Hash.new{|h, k| h[k] = []}
#print dictData["http://www.huffingtonpost.com/2015/12/09/ridiculously-romantic-wedding-instas_n_8763338.html?ir=Weddings"]

for key in iterlist

  #if dictData[key].length == 0
  thisPage = indexDict[key] #match http://cnn.com to 1.html
    #print thisPage 
  prDict[thisPage] = []
  #end

  
  for link in dictData[key]
    if indexDict.keys.include?(link)
      thisPage = indexDict[key]
      #print thisPage + "\n"
      linkedPage = indexDict[link]
      if not prDict[thisPage].include?(linkedPage)
        prDict[thisPage] << linkedPage
      end
    end
    if dictData[key].length == 0
      thisPage = indexDict[key]
      prDict[thisPage] = []
    end
  end
#  if not prDict[thisPage.split(".")[0]][-1].include?("#")
#    linkCount = dictData[key].length()
#    prDict[thisPage.split(".")[0]] << "#" + linkCount.to_s()
#  end
end
#print prDict

prFile = File.open("pagedata\/linksnet.dat", "w")
#prData = ""

#for key in prDict.keys
#  prData += key.split(".")[0] + ":"
#  for link in prDict[key]
#    prData += " " + link.split(".")[0]
#  end
#  prData += "\n"
#end

prFile.write(prDict)
prFile.close()

puts ""
puts "complete links net!"
puts ""