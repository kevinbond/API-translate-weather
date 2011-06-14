%w(rubygems openssl rest_client uri json net/http).each{|lib| require lib}

API_KEY='AIzaSyBLdWjIzKp0h__mgjPJxKQKUtlFFNfGRx4'

test_langs = {

    :english =>{:voices=>{:male=> "victor", :female=>"vanessa"}},
    :chinese => {:bing=>"zh-CN",:voices=>{:male =>'linlin',:female=>'lisheng'}},
    :danish => {:bing=>"da", :voice=>{:male=>'magnus',:female=>'frida'}},
    :dutch => {:bing=>"nl", :voices=>{:male=>'willem',:female=>'saskia'}},
    :french => {:bing=>"fr", :voices=>{:male=>'florence',:female=>'juliette'}},
    :galician => {:bing=>"gl", :voices=>{:female=>'carmela'}},    
    :german => {:bing=>"de",:voices=>{:male=>'stefan',:female=>'katrin'}},    
    :greek => {:bing=>"el", :voices=>{:male=>'nikos',:female=>'afroditi'}},    
    :italian => {:bing=>"it",:voices=>{:male=>'marcello',:female=>'paola'}},    
    :norwegian => {:bing=>"no",:voices=>{:male=>'henrik',:female=>'vilde'}},    
    :polish => {:bing=>"pl",:voices=>{:male=>'krzysztof',:female=>'zosia'}},
    :portuguese => {:bing=>"pt",:voices=>{:male=>'felipe',:female=>'fernanda'}},
    :russian => {:bing=>"ru",:voices=>{:male=>'dmitri',:female=>'olga'}},
    :spanish => {:bing=>"es",:voices=>{:male=>'carlos',:female=>'carmen'}},
    :swedish => {:bing=>"sv",:voices=>{:male=>'sven',:female=>'annika'}}

}

def translate(msg, to)
  #translation_result = RestClient.get("https://www.googleapis.com/language/translate/v2?key=#{API_KEY}&q=#{URI.encode(opt[:msg])}&source=#{opt[:from]}&target=#{opt[:to]}")
  #JSON.parse(translation_result)["data"]["translations"][0]["translatedText"]
  url = 'http://api.bing.net/json.aspx?AppId=14CC47476DC757F57687BB3CF8CD5447538540E4&Query=' + URI.encode(msg) + '&Sources=Translation&Version=2.2&Market=en-us&Options=EnableHighlighting&Translation.SourceLanguage=en&Translation.TargetLanguage='+ to +'&JsonType=raw'
  response = Net::HTTP.get_response(URI.parse(url))
  JSON.parse(response.body)['SearchResponse']['Translation']['Results'][0]['TranslatedTerm']
end

def fetch_weather(zip)
  yahoo_url = 'http://query.yahooapis.com/v1/public/yql?format=json&q='
  query = "SELECT * FROM weather.forecast WHERE location = " + zip
  url = URI.encode(yahoo_url + query)
  weather_data = JSON.parse(RestClient.get(url))
  weather_result = weather_data["query"]["results"]["channel"]["item"]["forecast"][0]
  return "Today will be #{weather_result["text"]} with a high of #{weather_result["high"]} and a low of #{weather_result["low"]}"
end
          
speaker_gender = ask "Welcome to the Weather Update! Would you prefer to speak to a weather male or female", {
     :choices => "male(male, guy, dude, man, weather male, whatever, yes), female(female, girl, women, weather female, lady)",
     :voice => "#{test_langs[:english][:voices][:male]}",
     :attempts => 10,
     :onChoice => lambda { |event|
        say "You chose to speak to a weather #{event.value}", {:voice => "#{test_langs[:english][:voices][event.value.to_sym]}"}
     }
}

zip_code = ask "Please enter your zip code and press pound",{
    :choices => "[5-9 DIGITS]",
    :attempts => 10,
    :timeout => 30.0,
    :terminator => '#',
    :voice => "#{test_langs[:english][:voices][speaker_gender.value.to_sym]}"
}      

say "#{fetch_weather(zip_code.value)}", {:voice => "#{test_langs[:english][:voices][speaker_gender.value.to_sym]}"}
say "Now that you know the weather in english, ", {:voice =>"#{test_langs[:english][:voices][speaker_gender.value.to_sym]}"}

get_another_language = true
language = ask ""
while get_another_language
  
    wrong_entry = true
    if language.value == 'exit'
        get_another_language = false
    else
        if language.value == 'keywords'
            say "The languages that are available are chinese, danish, dutch, french, galician, german, greek, italian, norwegian, polish, portuguese, russian, spanish, swedish", {
                :voice =>  "#{test_langs[:english][:voices][speaker_gender.value.to_sym]}"
            }
            language = ask "What language would you like to hear now? Say keywords to hear what languages are available again Or say exit to leave.", {
                :choices => "chinese, danish, dutch, french, galician, german, greek, italian, norwegian, polish, portuguese, russian, spanish, swedish, exit, keywords",
                :voice =>"#{test_langs[:english][:voices][speaker_gender.value.to_sym]}",
                :attempts => 10
            }
        else
            language = ask "What language would you like to hear now? Say keywords to hear what languages are available Or say exit to leave.", {
                :choices => "chinese, danish, dutch, french, galician, german, greek, italian, norwegian, polish, portuguese, russian, spanish, swedish, exit, keywords",
                :voice =>"#{test_langs[:english][:voices][speaker_gender.value.to_sym]}",
                :attempt => 10
            }
        end
        if language.value != 'keywords' and language.value != 'exit'
            say translate("#{fetch_weather(zip_code.value)}", "#{test_langs[language.value.to_sym][:bing]}"), 
                {:voice =>"#{test_langs[language.value.to_sym][:voices][speaker_gender.value.to_sym]}"}
        end
    end  
end
say"Thank you for using Weather Update! GoodBye.", {:voice =>"#{test_langs[:english][:voices][speaker_gender.value.to_sym]}"}