# I427 Fall 2015, Assignment 3
#   Code authors: Jeffery Gough(jvgough), Shaowen Ren(shaoren) 
#   
#   based on skeleton code by D Crandall
# encoding: utf-8
require "rubygems"
require "fast_stemmer"
require "nokogiri"

#PLEASE DOWNLOAD THE STEMMER 
#TYPE "gem fetch fast-stemmer" (yes, that's a dash, not underscore), into the command line
=begin
This program creates 2 dictionaries. The first one, invindex.dat, records occurrences
of words by the pages in which they show up. It keeps track of every unique word, 
where you can find each word, and the number of times the word appears on each page. 
The second dictionary is called docs.dat. This dictionary simply keeps statistics
on every stored page. For every page filename a few things are stored: the number of tokens on the page, the page's title, and the URL for the page.
The simple explanation of this program is that it first finds all of the words an 
html document, parses them into simple tokens (shortens words into their simplest 
parts), then creates a 3 dimensional dictionary sorted by word, then by page
to keep track of word appearance. 
To do this, the words in each document are inserted into a preliminary 
dictionary to avoid duplicates. Each word key has a blank value. 
That dictionary is saved and stored for later. Then, the words in the dictionary are
looped through, and for each word, the program searches through every HTML file
(don't worry, every word in the HTML files are saved into a separate dictionary 
called htmlDict, allowing for FAST searching of words. {"1.html"=>["word", "word", "word"....]}. This dictionary's key is an html file,and the value is a 
list of all tokens, duplicates allowed, of course) and runs a 
simple count method on the dictionary key's list to find the 
count for the word. A new dictionary, 
subHash, is constructed for every word, and the count of each word in htmlDict's value list goes toward that page's value. 

Quick explanation of every hash:
htmlDict: {"1.html"=>["all", "the", "tokens"....], "2.html"=>["more", "tokens"...]}
^Created during the initial HTML token parsing loop allowing fast searches

subHash: {"1.html" => 2, "2.html" => 3} 
^New one created after every word. Appended to superHash

superHash: {"informatic => {"1.html" => 2, "2.html" => 3"}}
^initially blank to kill duplicates. populated later in the program 

At first, constructing this dictionary took about one second per word because
the program needs to sort through every html file token per unique word. given
about 11,400 unique words, this program would have taken about 190 minutes!
We had an idea that we could speed it up by storing all of the tokens per html
page in a dictionary. The tokenization loop is already going to be run, so we figured
adding the tokens to a dictionary wouldn't cost too much time. The dictionary proved
beneficial because it allowed us to keep track of the tokens outside of the loop, 
rather than dealing with them inside the loop on the fly. Also, it sped up 
the process to taking less than 5 minutes because dictionaries are very quick.

docs.dat is a simple document that was made possible with the nokogiri gem. 
It is a dictionary with filenames as keys and a list of information as 
the value. First, it simply counts the values in the htmlDict list for the length,
uses nokogiri on the appropriately titled html file to find the HTML title, 
and uses the index.dat file to find the URL. Everything was pretty much plug and play
for us at this point and constructing this file didn't take long. 

Main hurdles: dictionary manipulation, speed 
Figuring out how to construct the main dictionary was 
difficult. It is easy to conceptualize and easy to understand, but it is 
actually more difficult to make than it seems. Also, speed was a hurdle that we 
tackled once we had the final dictionary structure figured out. 

=end


# This function writes out a hash or an array (list) to a file.
#
def write_data(filename, data)
  file = File.open(filename, "w")
  file.puts(data)
  file.close
end


# function that takes the name of a file and loads in the stop words from the file.
#  You could return a list from this function, but a hash might be easier and more efficient.
#
def load_stopwords_file(file) 
  file = File.open(file, "r")
  data = file.read().split()
  file.close()
  return data
end


# function that takes the name of a directory, and returns a list of all the filenames in that
# directory.
def list_files(dir)
  filenames = Dir.entries(dir)
  
  #delete some hidden useless file
  filenames.delete('.')
  filenames.delete('..')
  filenames.delete('.DS_Store')
  return filenames
end


# function that takes the *name of an html file stored on disk*, and returns a list
#  of tokens (words) in that file. 
#
def find_tokens(filename)
  data = ""
  page = Nokogiri::HTML(open(filename))
  
  
# each loop below, is to extracting the specific text content
# of ('...') in the HTML file. 
  
  page.css('title').each do |line| #extracting <title>
    data += line.to_s
    data += " "
  end
  
  page.css('h1').each do |line| #extracting <h1>
    data += line.to_s
    data += " "
  end
  
  page.css('h2').each do |line| #extracting <h2>
    data += line.to_s
    data += " "
  end
  
  page.css('h3').each do |line| #extracting <h3>
    data += line.to_s
    data += " "
  end
  
  page.css('h4').each do |line| #extracting <h4>
    data += line.to_s
    data += " "
  end
 
  page.css('li').each do |line| #extracting <li>
    data += line.to_s
    data += " "
  end
  
  page.css('p').each do |line| #extracting <p>
    data += line.to_s
    data += " "
  end
  
  wordList = []
  for thing in data.split(/\W/)
    if thing != ""
      wordList << thing.downcase
    end
  end

  return wordList

end


# function that takes a list of tokens, and a list (or hash) of stop words,
#  and returns a new list with all of the stop words removed
#
def remove_stop_tokens(tokens, stop_words)
  
  stop_words.each do |stop|
    tokens.delete(stop)
  end

  return tokens
end


# function that takes a list of tokens, runs a stemmer on each token,
#  and then returns a new list with the stems
#
def stem_tokens(tokens)
  stem_list = []  
  for word in tokens
      stem_list << word.strip().stem
    end
  return stem_list
end


#makes the embedded hash under the intial hash per html
def make_counter_hash(doc_name, stem_tokens)
  #main hash already created. this function spits out a sub hash
    subHash = Hash.new 0
    for token in stem_tokens #per html file
      #print token
      print "\n"
      subHash[doc_name] += 1
    end

  return subHash
end        





#################################################
# Main program. We expect the user to run the program like this:
#
#   ruby index.rb pages_dir/ index.dat
#################################################

# check that the user gave us 2 command line parameters
if ARGV.size != 2
  abort "Command line should have 2 parameters."
end

# fetch command line parameters
(pages_dir, index_file) = ARGV


# read in list of stopwords from file
stop_words = load_stopwords_file("stop.txt")

# get the list of files in the specified directory
file_list = list_files(pages_dir + "pages")



superHash = {}
htmlDict = {}
pageHash = {}
docDict = {}

#docsDict = {}
file = open(pages_dir + index_file, "r")
pageNames = file.read()
pageNames = pageNames.split("\n")
pageNames.each do |page|
	page_and_URL_list = page.split()
	pageHash[page_and_URL_list[0]] = page_and_URL_list[1]
end



# scan through the documents one-by-one
#main loop of the program
print "Initializing pages"
file_list.each do |doc_name|
	print "."
	#print doc_name + "\n"
    path = pages_dir + "pages\/" + doc_name
    tokens = find_tokens(path)
    tokens = remove_stop_tokens(tokens, stop_words)
    tokens = stem_tokens(tokens)
	
	#outside dictionary for the words
	#initiates the outside dictionary 
	#because we want to exclude duplicate words 
    for token in tokens
        superHash[token] = ""
    end
	
	#separate dictionary, unrelated to words dictionary
	#stores every word from every HTML file
	#{"1.html"=>["word", "word", "word"....], "2.html" => [""""]}
	htmlDict[doc_name] = tokens
	
	############################
    #here, we are going to deal with docs.dat
	#we want: file length in tokens, title, URL
	#{"0.html" => ["FileLength", "title",URL]}
	webPage = Nokogiri::HTML(open(path))
	
	docDict[doc_name] = [tokens.count(), webPage.css("title").text.strip().delete('Â'), pageHash[doc_name]] 
	############################
	
end
#the second main loop of the program
puts ""
print "Counting...please wait\n"
term_count = superHash.keys.count
print "Constructing dictionary...please wait\n"
for word in superHash.keys
#		if term_count % 100 == 0
			print "\r #{term_count} unique words left"
#		end
		subHash = {} #restart this hash after every word 
		
		htmlDict.each do |htmldoc, wordlist| #key, value
			if wordlist.include?(word)
				subHash[htmldoc] = wordlist.grep(word).size #number of times the word appears in the list
				#example {"1.html" => 2, "2.html" => 3}
			end
		end
		superHash[word] = subHash
		#example: {"informatic => {"1.html" => 2, "2.html" => 3"}}
		term_count -= 1
end


# save the hashes to the correct files
write_data(pages_dir + "invindex.dat", superHash)
write_data(pages_dir + "docs.dat", docDict)
print "Data written to invindex.dat and docs.dat\n"

# done!
print "Indexing complete!\n";
puts ""

