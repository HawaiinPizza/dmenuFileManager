#!/bin/sh

# Read Config (If Any)
Config_Dir="$(pwd)/config"
Official_Dir="$Config_Dir/officialdir"
Trash_Dir="$(pwd)/trash"

# Make sure Directories Exits
mkdir -p $Config_Dir
mkdir -p $Trash_Dir


# Obtain Actual Dir
if [ ! -f "$Official_Dir" ]; then
    printf "Please Enter Official Notes Directory: "
    read input

    # Create Directory
    mkdir -p $input

    # Save Official Dir
    echo "Saving Location..."
    mkdir $Config_Dir -p
    echo $input > $Official_Dir
fi

# Load Directory
echo "Loading Directory..."
Official_Dir=$(< $Official_Dir)
mkdir -p $Official_Dir
cd $Official_Dir

# Dmenu Color Scheme
alias mod-dmenu='rofi -dmenu -i \
                    -font "Monospace 10" \
                    -color-window "#0A2342, #0A2342, #0A2342" \
                    -color-normal "#9BC1BC, #B24C63, #9BC1BC, #1E91D6, #2C3E50" \
                    -color-active "#000000, #B1B4B3, #000000, #007763, #B1B4B3" \
                    -color-urgent "#222222, #B1B4B3, #222222, #77003D, #B1B4B3"'


# Open Dmenu
Choice="..."
Actions=("*New Dir*" "*New Note*" "*Remove*")
while [ "$Choice" != "" ]; do
    # Get Dirs and Files
    Dirs="$(find -L . -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^/[/;s/$/]/')"
    Files="$(find -L .   -mindepth 1 -maxdepth 1 -type f -not -path '*/\.*')"


    # Add Previous Directory in order to go back
    if [ "$(pwd)" != "$Official_Dir" ]; then
            Files="....\n"$Files
    fi

    # Seperate Directories & Files
    # Keep it clean with no Empty Selections
    if [ "$Dirs" != "" ]; then
        Dirs=$Dirs"\n"
    fi


    # Construct Choices to Display & Filter it
    # Only Sort Files and Directories, leaving Actions at Top
    Choice=$(printf "%s\n" "${Actions[@]}" "$(printf "$Dirs$Files" | sort)" | sed '/^$/d' | sed 's/\..//' | mod-dmenu -p 'Notes' -lines 10 -location 3 -width 25 -hide-scrollbar | sed 's/[][]//g')

    # Check if Action
    case $Choice in

        "*New Dir*")    # Create new Directory
            # Get new Directory Name
            newDir=`printf "$Dirs" | sed 's/\..//' | sort | mod-dmenu -p "New Directory" -width 20`
            
            # Create Directory
            if [ "$newDir" != "" ]; then
                mkdir -p "$newDir"
            fi
            ;;
        
        "*New Note*")   # Create new Note
            # Get new File Name
            newFile=`printf "$Files" | sed 's/\..//;/^$/d' | sort | mod-dmenu -p "New Note" -width 20`

            # Create File
            if [ "$newFile" != "" ]; then
                touch "$newFile"
            fi
            ;;

        "*Remove*")     # Remove Note/Directory
            # Get what to Remove    # TODO: Remove '..' and NO Empty Choices!
            deleteMe=`printf "$Dirs$Files" | sed 's/\..//' | sort | mod-dmenu -p "New Directory" -width 20 | sed 's/[][]//g'`

            # Delete Selection!
            if [ "$deleteMe" != "" ]; then
                mv "$deleteMe" $Trash_Dir # (Safely)
                # rm -rf "$deleteMe"        # (Danger)
            fi
            ;;


        *)
            # Get into Directory
            if [ -d "$Choice" ]; then
                cd "$Choice"

            # Edit File
            elif [ "$Choice" != "" ]; then
                vim "$Choice"
            fi
            ;;

    esac


done

echo "Exiting..."
exit 0