# file including a list of holidays
file="holidays.txt"

# assume no holiday first
holiday=0

# date only accepts english date specifications! save LANG in order to set it back in the end
locale=$(locale | grep -oP "(?<=^LANG=).*$")
LANG="C.UTF-8"

# is it weekend?
daynumber=$(date +%u)
if test $daynumber -ge 6
then
  if [ "$daynumber" == 6 ]
  then
    message="It is weekend (Saturday)."
    holiday=1
  fi
  if [ "$daynumber" == 7 ]
  then
    message="It is weekend (Sunday)."
    holiday=1
  fi
fi

# fixed holiday?
today=$(date +%m-%d)
regex="(?!^#)(?<=^$today\s//\s).*$"
if test $(grep "^$(date +%m-%d)" $file -ic) -ne 0
then
  holidayname=$(grep -oP $regex $file)
  message="Today is a holiday ($holidayname)."
  holiday=1
fi

# dynamic holiday (regarding Easter)?
var=$(ncal -e $(date +%Y))
today=$(date +%F)
regex="(?!^#)(?<=^EASTER\s).[0-9]*"
targets=$(grep -oP $regex $file)
for item in ${targets[*]}
do
  holyday=$(date -d "$(echo $var) $(echo $item days)" +%Y-%m-%d)
  if [ "$today" == "$holyday" ]
  then
    regex="(?!^#)(?<=^EASTER\s$item\s//\s).*$"
    holidayname=$(grep -oP $regex $file)
    message="Today is a holiday ($holidayname)."
    holiday=1
  fi
done

# set back locale
LANG="$locale"

if [ $holiday == 0 ] 
then
  message="No weekend nor holiday. Script will be executed."
fi

#echo $message
export message
export holiday
