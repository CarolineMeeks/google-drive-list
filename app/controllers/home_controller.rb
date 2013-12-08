# app/controllers/home_controller.rb

#require 'open-uri'  # I don't think I need this because I use the Google API to get the file.
require 'nokogiri'

class HomeController < ApplicationController
  def index
    if logged_in?
      auth = Signet::Rails::Factory.create_from_env :google, request.env
      client = Google::APIClient.new
      client.authorization = auth

      #CM adding code here to try to access drive
      drive = client.discovered_api('drive', 'v2')
      drive_files_list = client.execute(
                                  :api_method => drive.files.list,
                                  :parameters => {},
                                  :headers => {'Content-Type' => 'application/json'}
                                  )
      files = drive_files_list.data
      @files_result1 = files
      result = Array.new
      @files_result = result.concat(files.items)
      

      #Here we iterate through the files and get the size of each. This is horribly ineffiecient. This is for this demo only. What we need to do is.

# 1. Probably let the teachers pick a folder and just worry about that folder.
# 2. Only look at files that have been recently modified.
# 3. Look at changes and not the total file size.

      recent_range = ((Date.today - 30).to_date..Date.today.to_date)
      @files_result.each_with_index do |f, index|
        
        if recent_range === f.modifiedDate.to_date 
          url = f.selfLink
        

          file = client.execute(
                                :uri => url
                                )
          file_html = Nokogiri::HTML(file.body)
          file_text  = file_html.at('body').inner_text
          file_size = file_text.length
          file_size = 0 if file_size.nil?

          @files_result[index]["size"] = file_size
          #Next add it into files_result.
 
      else
        @files_result[index]["size"] = "Not recently modified"
       end 
     end
#      binding.pry


    end
  end
end
