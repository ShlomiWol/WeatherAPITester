#!/bin/bash

# This script tests the OpenWeatherMap API. This is the best practices, search city according to his ID.
# Shows the current location weather to the user.

# Author: Shlomi Wolman

appid_key='266c459ea57a799c3948e18df59d448a'
url='http://api.openweathermap.org/data/2.5/weather'

# Download the city list from OpenWeatherAPI
echo "The Shlomi's Tester API - according to OpenWeatherMap best practices (search according to ID)"
echo "Please Wait..... Loading the city list......"
wget -q "http://bulk.openweathermap.org/sample/city.list.json.gz" -O /tmp/city.list.json.gz
gzip -df /tmp/city.list.json.gz

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

# Find City ID
function find_id()
{
  name=$1
  parameter=$2
  lon=$3
  lat=$4
  
  # Check in which mode we have to search the id
  if [ $parameter == "name" ]
  then
      # Check if there is more than one city with the same name
      if [[ `cat /tmp/city.list.json | grep "\"name\":\"$name\"" | wc -l` -gt 1 ]]
      then
	  list=`cat /tmp/city.list.json | grep "\"name\":\"$name\"" | awk -F, '{print $2 $1 $3}'`
          read -p "$list 
More than one city with the same name, insert the id of the city you want: " id
          echo $id
      else
      	  id=`cat /tmp/city.list.json | grep "\"name\":\"$name\"" | awk -F, '{print $1}' | grep -o '[0-9]*'`
      	  echo $id
      fi
  elif [ $parameter == "coord" ]
  then
      new_lon=`echo $lon | sed 's/-/\\\-/g'`
      new_lat=`echo $lat | sed 's/-/\\\-/g'`
      
      id=`cat /tmp/city.list.json | grep "lat\":$new_lat" | grep "lon\":$new_lon" | awk -F, '{print $1}' | grep -o '[0-9]*'`
      echo $id
  else
      echo ""
  fi
}

# Shows the weather in readable mode
function show_data()
{
  var=$1
  json=`curl -s "$url?id=$var&appid=$appid_key"`

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
  echo "---- This is the weather in $city_name ($id) $country   ----"
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
      curl -s "$url?id=$var&appid=$appid_key"
  elif [ $format == "xml" ]
  then
      curl -s "$url?id=$var&mode=xml&appid=$appid_key"
  elif [ $format == "html" ]
  then
      curl -s "$url?id=$var&mode=html&appid=$appid_key"
  else
      echo "No format"
  fi
}

# Run the menu
while :
do
  clear

  # Menu
  echo "----- Welcome to the Shlomi's Tester (Best Practice) -----"
  echo ""
  echo "----- Choose one of this options to get current weather data by: "
  echo "----- 1. City name"
  echo "----- 2. City ID"
  echo "----- 3. Geographic Coordinates"
  echo "----- 4. Exit"
  
  # The choice
  read -p "Insert the number you choose: " choice
  
  # Checking all the cases
  case $choice in
      1)
        read -p "Insert the City Name: " cname

        # Checking if the input is correct
        # Getting the city ID
        find_id "$cname" "name" > /tmp/id
        id=`cat /tmp/id`
        rm -f /tmp/id > /dev/null

        result=`curl -s "$url?id=$id&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
        else

            # Show weather to the user
            show_data $id
            
            # Check if the user want the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format $id
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
            show_data $cID
            
	    # Check if the user wants the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format $id
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      3)
        read -p "Insert lat: " clat
        read -p "Insert lon: " clon

	# Checking if the input is correct
        # Getting the city ID
        
        find_id "null" "coord" $clon $clat > /tmp/id
        id=`cat /tmp/id`
        rm -f /tmp/id > /dev/null
	
        result=`curl -s "$url?id=$id&appid=$appid_key"`
        out=$(error_404 ${result})
        if [[ $out == "error" ]]
        then
            echo "Error - Input Incorrect"
            read -p "Press any key to continue... " key
        else

            # Show weather to the user
            show_data $id

            # Check if the user wants the output in other format
            read -p "Wanna see in JSON/XML/HTML format?[y/n] " answer
            if [ $answer == "y" ]
            then
                read -p "Select which format[json,xml,html]" format
                show_format $format $id
            fi

            echo ""
            read -p "Press any key to continue... " key
        fi
        ;;
      4)
        echo "Bye Bye"
        exit
        ;;
  esac
done
