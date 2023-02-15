#!/bin/bash
wget https://t.me/s/shadowsocksm -O index.html
cat index.html | grep -v "vmess://" > index1.html
cat index1.html | grep "ss://" > index2.html
cat index2.html | grep "@" > index.html
s=$(cat index.html)
echo "" > res
echo "" > result
for line in $s
do
st=$(echo $line  | grep -b -o "ss://" | cut -d':' -f1)
l=${#line}
let e=$l-$st-1
a=${line:$st:$e}
echo $a >> index.txt
done
cat index.txt | grep "ss://Y" > links.txt
python3 proc.py
echo "Shadowsocks URLs:"
cat links.txt
rm index*
rm res*
linkmas=$(cat links.txt)
i=1
for line in $linkmas
do
jn=$i.json
let i=$i+1
# Shadowsocks URL
url=$(echo $line)
add_char="#"

# Check if the add char is not found in the input string
if ! echo "${url}" | grep -q "${add_char}"; then
  # Add the add char to the end of the input string
  url="${url}${add_char}"
fi

start_sample="//"
end_sample="@"

# Get the start index of the start sample
start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)

start_index=$((${start_index} + 3 ))
# Get the end index of the end sample
end_index=$(( $(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1) + ${#end_sample} - 1 ))

# Calculate the length of the desired substring
length=$(( ${end_index} - ${start_index} + 1 ))

# Extract the desired substring
encoded=$(echo "${url}" | cut -c ${start_index}-${end_index})


chiperinfo=$(echo $encoded | base64 --decode)

# Start and end samples
start_sample="@"
if ! echo "${url}" | grep -q "?"; then
  # Add the add char to the end of the input string
  end_sample="#"
else
  end_sample="?"
fi

# Get the start index of the start sample
start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)
start_index=$((${start_index} + 2 ))
# Get the end index of the end sample
end_index=$(( $(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1) + ${#end_sample} - 1 ))

# Calculate the length of the desired substring
length=$(( ${end_index} - ${start_index} + 1 ))

# Extract the desired substring
ipport=$(echo "${url}" | cut -c ${start_index}-${end_index})

# Character before which the string should be extracted
char=":"

# Get the index of the before char
char_index=$(echo "${ipport}" | grep -b -o "${char}" | cut -d':' -f1 | head -n 1)

# Extract the desired substring
ip=$(echo "${ipport}" | cut -c -${char_index})
char_index=$((${char_index} +2 ))
port=$(echo "${ipport}" | cut -c ${char_index}-)

char_index=$(echo "${chiperinfo}" | grep -b -o "${char}" | cut -d':' -f1 | head -n 1)

# Extract the desired substring
chiper=$(echo "${chiperinfo}" | cut -c -${char_index})
char_index=$((${char_index} +2 ))
password=$(echo "${chiperinfo}" | cut -c ${char_index}-)

echo "{" > $jn
echo '"server":"'$ip'",' >> $jn
echo '"server_port:"'$port',' >> $jn
echo '"local_port":'1050',' >>$jn


echo '"password":"'$password'",' >> $jn

if [ $(echo $end_sample) = '?' ]; then
        echo '"method":"'$chiper'",'  >> $jn
        echo '"plugin":"obfs-local",' >> $jn
	start_sample="obfs-host%3D"
        end_sample="#"
        if  echo "${url}" | grep -q "http"; then
        obfsopt="http"
        fi
        if  echo "${url}" | grep -q "tls"; then
        obfsopt="tls"
        fi
        
        # Get the start index of the start sample
        start_index=$(echo "${url}" | grep -b -o "${start_sample}" | cut -d':' -f1)
        start_index=$((${start_index} + 13 ))
        #echo $start_index
        # Get the end index of the end sample
        end_index=$(echo "${url}" | grep -b -o "${end_sample}" | cut -d':' -f1)

        # Extract the desired substring
        substring=$(echo "${url}" | cut -c ${start_index}-${end_index})

        echo '"plugin_opts":"obfs='$obfsopt';failover='"${substring}"'"' >> $2
else
echo '"method":"'$chiper'"' >> $jn
fi
echo "}" >> $jn
done

echo "Configuration files .json you can find in this folder:"
ls *.json
