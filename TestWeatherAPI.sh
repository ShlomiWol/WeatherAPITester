#!/bin/bash

# This script tests the OpenWeatherMap API.
# Shows the current location weather to the user.

# Author: Shlomi Wolman

appid_key='266c459ea57a799c3948e18df59d448a'
url='http://api.openweathermap.org/data/2.5/weather'

# Checks if there is an error in the page
function error_404()
{
   var=$1
   if [[ $var == '{"cod":"404"'* || $var == '400'* ]]
   then
       echo "error"
   else
       echo "no error"
   fi
}

# Shows the weather in readable mode
function show_data()
{
  var=$1
  json=`curl -s "$url?$var&appid=$appid_key"`
  echo $json | sed -e 's/[{}]/''/g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' > /tmp/weather_data.tmp
  city_name=`cat /tmp/weather_data.tmp | grep "name" | awk -F: '{print $2}' | tr '"' ' '`
  id=`cat /tmp/weather_data.tmp | grep '^"id"' | awk -F: '{print $2}'`
  country=`cat /tmp/weather_data.tmp | grep "country" | awk -F: '{print $2}' | tr '"' ' '`
  main=`cat /tmp/weather_data.tmp | grep "main" |grep -v temp | awk -F: '{print $2}' | tr '"' ' '`
  description=`cat /tmp/weather_data.tmp | grep "description" | awk -F: '{print $2}' | tr '"' ' '`
  lon=`cat /tmp/weather_data.tmp | grep "lon" | awk -F: '{print $3}'`
  lat=`cat /tmp/weather_data.tmp | grep "lat" | awk -F: '{print $2}'`
  temp=`cat /tmp/weather_data.tmp | grep "main" | grep "temp" | awk -F: '{print $3}'`
  temp_min=`cat /tmp/weather_data.tmp | grep "temp_min" | awk -F: '{print $2}'`
  temp_max=`cat /tmp/weather_data.tmp | grep "temp_max" | awk -F: '{print $2}'`
  pressure=`cat /tmp/weather_data.tmp | grep "pressure" | awk -F: '{print $2}'`
  humidity=`cat /tmp/weather_data.tmp | grep "humidity" | awk -F: '{print $2}'`
  sea_level=`cat /tmp/weather_data.tmp | grep "sea_level" | awk -F: '{print $2}'`
  grnd_level=`cat /tmp/weather_data.tmp | grep "grnd_level" | awk -F: '{print $2}'`
  wind=`cat /tmp/weather_data.tmp | grep "wind" | awk -F: '{print $3}'`
  sunrise=`cat /tmp/weather_data.tmp | grep "sunrise" | awk -F: '{print $2}'`
  sunset=`cat /tmp/weather_data.tmp | grep "sunset" | awk -F: '{print $2}'`
  echo "---- This is the weather in $city_name($id) $country ----"
  echo "---- $main, $description"
  echo "---- The geographic coordinates are: lon: $lon lat: $lat"
  echo "---- The Temprature is: $temp, max temp: $temp_max mintemp: $temp_min"
  echo "---- The pressure is: $pressure, humidity: $humidity and wind is: $wind"
  echo "---- The sea level is: $sea_level, ground level: $grnd_level"
  echo "---- The sunrise is at: `date -d @$sunrise +%T` and sunset at: `date -d @$sunset +%T`"
  rm -f /tmp/weather_data.tmp > /dev/null
}

# Prints the weather output in one of the foramts(json,xml,html)
function show_format()
{
  format=$1
  var=$2
  if [ $format == "json" ]
  then
      curl -s "$url?$var&appid=$appid_key"
  elif [ $format == "xml" ]
  then
      curl -s "$url?$var&mode=xml&appid=$appid_key"
  elif [ $format == "html" ]
  then
      curl -s "$url?$var&mode=html&appid=$appid_key"
  else
      echo "No format"
  fi
}

# Run the menu
while :
do
  clear

  # Menu
  echo "----- Welcome to the Shlomi's Tester -----"
  echo ""
  echo "----- Choose one of this options to get current weather data by: "
  echo "----- 1. City name"
  echo "----- 2. City ID"
  echo "----- 3. Geographic Coordinates"
  echo "----- 4. ZIP code"
  echo "----- 5. Exit"
  
  # The choice
  read -p "Insert the number you choose: " choice
  
  # Checking all the cases
  case $choice in
      1)
        read -p "Insert the City Name (Without space, for example: New York=NewYork): " cname

        # Checking if the input is correct
        result=`curl -s "$url?q=$cname&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
        else

            # Show weather to the user
            show_data "q=$cname"
            
            # Check if the user want the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format "q=$cname" 
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      2)
        read -p "Insert the City ID: " cID
        
        # Checking if the input is correct
        result=`curl -s "$url?id=$cID&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
        else
            
            # Show weather to the user
            show_data "id=$cID"
            
	    # Check if the user wants the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format "id=$cID"
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      3)
        read -p "Insert lat: " clat
        read -p "Insert lon: " clon

	# Checking if the input is correct
        result=`curl -s "$url?lat=$clat&lon=$clon&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
        else

            # Show weather to the user
            show_data "lat=$clat&lon=$clon"

            # Check if the user wants the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format "lat=$clat&lon=$clon"
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      4)
        read -p "Insert ZIP code[{zip code},{country code}]: " cZIP
        
	# Checking if the input is correct
        result=`curl -s "$url?zip=$cZIP&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
	else
            
            # Show weather to the user
            show_data "zip=$cZIP"

            # Check if the user want the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format "zip=$cZIP"
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      5)
        echo "Bye Bye"
        exit
        ;;
  esac
done
