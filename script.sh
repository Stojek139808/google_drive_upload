#!/bin/bash

upload(){

    token=(`(cat credentials.txt | grep -oE "token.+" | grep -oE "[^=]+")`)
    metadata="{\"name\": \"$1\", \"parents\": [\"url_end_here\"]}"

    echo $metadata

    curl -X POST "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true" \
    -H "Authorization: Bearer ${token[1]}" \
    -F "metadata=$metadata;type=application/json;charset=UTF-8" \
    -F "file=@$1"
}

authorize(){

    client_id=(`(cat credentials.txt | grep -oE "client_id.+" | grep -oE "[^=]+")`)
    secret=(`(cat credentials.txt | grep -oE "secret.+" | grep -oE "[^=]+")`)

    device_json=`curl -d "client_id=${client_id[1]}&scope=https://www.googleapis.com/auth/drive.file" https://oauth2.googleapis.com/device/code`
    device_code=`echo $device_json | grep -oE "\"device_code\": [^,]+," | grep -oE ":\ +\"[^:\"]+\"" | grep -oE "[^\"\ :]+"`
    user_code=`echo $device_json | grep -oE "\"user_code\": [^,]+," | grep -oE ":\ +\"[^:\"]+\"" | grep -oE "[^\"\ :]+"`

    echo "Go to https://www.google.com/device and authorize your device with the code below:"
    echo
    echo     $user_code
    echo
    echo "When done, press anything to proceed."
    read -n 1

    token_json=`curl -d client_id=${client_id[1]} -d client_secret=${secret[1]} -d \
    device_code=$device_code -d \
    grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code \
    https://accounts.google.com/o/oauth2/token`

    token=`echo $token_json | grep -oE "\"access_token\": [^,]+," | grep -oE ":\ +\"[^:\"]+\"" | grep -oE "[^\"\ :]+"`

    echo "client_id=${client_id[1]}" > credentials.txt
    echo "secret=${secret[1]}" >> credentials.txt
    echo "token=$token" >> credentials.txt

}

help(){
    echo "  help             display this help"
    echo "  upload [FILE]    upload a file, according to the specified metadata"
    echo "  authorize        authorize yoursef on the google cloud"
}

case $1 in
    authorize)
        authorize
    ;;
    upload)
        upload $2
    ;;
    *)
        help
    ;;
esac
