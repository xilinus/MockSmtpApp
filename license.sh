#!/bin/sh

COMMAND=
PRODUCT="Xilinus/*"
TYPE="Trial"
DAYS=30
DATE=
USERNAME=
EMAIL=
ARCHIVE="NO"
OUTPUT_FILE=
KEY_FILE=

print_help()
{
    echo "Usage: license.sh gen|add|help [-z] [-p product] [-t license_type] [-d expiration_days] [-u username] [-e email] key_file path"
}

case $1 in
    "gen"   ) COMMAND="gen";;
    "add"   ) COMMAND="add";;
    "help"  ) print_help; exit 0;;
    *       ) echo "Unknown command: $1"; print_help; exit 65;;
esac

shift

while getopts ":p:t:d:u:e:z" Option
do
    case $Option in
        "p" ) PRODUCT=$OPTARG;;
        "t" ) TYPE=$OPTARG;;
        "d" ) DAYS=$OPTARG;;
        "u" ) USERNAME=$OPTARG;;
        "e" ) EMAIL=$OPTARG;;
        "z" ) ARCHIVE="YES";;
        *   ) echo "Unknown option."; print_help; exit 65;
    esac
done
shift $(($OPTIND - 1))

if [ $# -ne 2 ]
then
    print_help
    exit 65
fi

KEY_FILE=$1
OUTPUT_FILE=$2

PLIST_STRING="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Product</key> <string>${PRODUCT}</string>
    <key>LicenseType</key> <string>${TYPE}</string>
"

echo "Generating license file..."

if [ "$TYPE" = "Trial" ]
then
    DATE=`date -uv+${DAYS}d "+%Y-%m-%dT%H:%M:%SZ"`
    ERROR=$?
    if [ "$ERROR" -ne 0 ]
    then
        echo "Error while obtaining date. Exiting..."
        exit
    fi
    
    PLIST_STRING="${PLIST_STRING}    <key>ExpirationDate</key> <date>${DATE}</date>
"
fi

if [ "$USERNAME" ]
then
    PLIST_STRING="${PLIST_STRING}    <key>Username</key> <string>${USERNAME}</string>
"
fi

if [ "$EMAIL" ]
then
    PLIST_STRING="${PLIST_STRING}    <key>Email</key> <string>${EMAIL}</string>
"
fi

PLIST_STRING="${PLIST_STRING}</dict>
</plist>
"

TMP_DIR=`mktemp -d /tmp/mocksmtp.license.XXXXXX`
ERROR=$?
if [ "$ERROR" -ne 0 ]
then
    echo "Error while creating temp directory. Exiting..."
    exit
fi

PLIST_FILE="${TMP_DIR}/license.plist"
SIG_FILE="${PLIST_FILE}.sha1"

echo "$PLIST_STRING" > "$PLIST_FILE"

ERROR=$?
if [ "$ERROR" -ne 0 ]
then
    echo "Error while creating plist file. Exiting..."
    exit
fi

echo "Ok"

echo "Generating signaure..."

openssl dgst -sha1 -sign ${KEY_FILE} -out ${SIG_FILE} ${PLIST_FILE}
if [ ! -s "$SIG_FILE" ]
then
    echo "Error while creating signature. Exiting..."
    exit
fi

echo "Ok"

if [ "$COMMAND" = "gen" ]
then
    echo "Packing license file and signature into the key file..."
    tar -czf $OUTPUT_FILE -C $TMP_DIR license.plist license.plist.sha1
    
    ERROR=$?
    if [ "$ERROR" -ne 0 ]
    then
        echo "Error. Exiting..."
        exit
    fi
    
    echo "Ok"
    echo "Done"
fi

if [ "$COMMAND" = "add" ]
then
    if [ "$ARCHIVE" = "NO" ]
    then
        KEY_FILE="${OUTPUT_FILE}/Contents/Resources/default.key"
        
        echo "Addin license to the application folder..."
        tar -czf $KEY_FILE -C $TMP_DIR license.plist license.plist.sha1
        
        ERROR=$?
        if [ "$ERROR" -ne 0 ]
        then
            echo "Error. Exiting..."
            exit
        fi

        echo "Ok"
        echo "Done"
    fi
    
    if [ "$ARCHIVE" = "YES" ]
    then
        echo "Unpacking application archive..."
        unzip "$OUTPUT_FILE" -d "$TMP_DIR" > /dev/null
        
        ERROR=$?
        if [ "$ERROR" -ne 0 ]
        then
            echo "Error. Exiting..."
            exit
        fi
        
        echo "Ok"
        
        pushd $PWD > /dev/null
        cd $TMP_DIR
        
        KEY_FILE="MockSmtp.app/Contents/Resources/default.key"
        echo "Packing license file and signature into the key file..."
        tar -czf $KEY_FILE license.plist license.plist.sha1
        
        ERROR=$?
        if [ "$ERROR" -ne 0 ]
        then
            echo "Error. Exiting..."
            exit
        fi
        
        echo "Ok"
        
        rm license.plist license.plist.sha1
        
        echo "Recreating application archive..."
        zip -r MockSmtp.zip MockSmtp.app > /dev/null
        
        ERROR=$?
        if [ "$ERROR" -ne 0 ]
        then
            echo "Error while creating archive. Exiting..."
            exit
        fi
        
        popd > /dev/null
        mv "${TMP_DIR}/MockSmtp.zip" "$OUTPUT_FILE"
        
        ERROR=$?
        if [ "$ERROR" -ne 0 ]
        then
            echo "Error while moving archive file. Exiting..."
            exit
        fi
        
        echo "Ok"
        echo "Done"
    fi
fi

rm -rf "$TMP_DIR"

exit

