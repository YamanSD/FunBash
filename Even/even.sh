# Array of options for the user to choose from, based on problem description
options=("Create a file" "Create a directory" "Delete a file" "Delete a directory" "Count from/to n" "Search for a phrase in a given directory" "Current directory" "Exit")

# Stores the requested user action number
action=0

# Read the user's name; -r to read entire line
echo "Please enter your name:"
read -r name

# Read the user's ID
echo "Please enter your ID:"
read -r id

# Check if the user ID is a valid integer using regex;
# and check if user ID is even;
# if both checks do not pass, exit.
if ! { [[ "$id" =~ ^[0-9]+$ ]] && ((id % 2 == 0)); }; then
    echo -e "\nID not even, goodbye $name!"
    exit 0
fi

# Display greeting; -e to allow \n
echo -e "\nGood morning $name, the date and time is $(date +"%a %b %d %I:%M:%S %p%n%Z %Y"), how can I help you today?"


# Displays the given text as colored, then returns to white text.
# First parameter is the text to be displayed.
# Second parameter is the special color character.
display_colored() {
    # Data
    local txt=$1

    # Color
    local color=$2

    # Display info
    echo -en "$color$txt$(tput setaf 7)"
}

# Displays an error message (red).
# Takes text as input.
display_err() {
    # Display colored information
    local err=$1

    # Display colored information (red)
    display_colored "\n$err\n" "$(tput setaf 1)"
}

# Displays a success message, colored green.
# Takes text as input.
display_success() {
    # Input message
    local msg=$1

    # True removes new line characters
    local rmv_pad=${2:-false}

    if [ "$rmv_pad" != true ]; then
        msg="\n$msg\n"
    fi

    # Display colored information (green).
    display_colored "$msg" "$(tput setaf 2)"
}

# Displays an informational message, colored cyan.
# Takes text as input.
display_info() {
    # Input message
    local info=$1

    # Display colored information (cyan).
    display_colored "\n$info\n" "$(tput setaf 6)"
}

# Function to display the menu & set the chosen user action
display_menu() {
    # Empty new line
    echo ""

    # Iterate over the length of the options array
    for ((i = 0; i < "${#options[@]}"; i++)); do
        # Print the option
        echo "$((i + 1))- ${options[i]}"
    done

    # Empty new line
    echo ""

    # Read user choice from console
    read -r action

    # Check if the user input is a valid integer using regex;
    # if check does not pass, set the choice to -1.
    if ! { [[ "$action" =~ ^[0-9]+$ ]]; }; then
        action=-1
    fi
}

# Transforms the given path from relative to absolute.
# Takes path to be transformed as first input.
to_absolute() {
    # Prepend the home-dir path to the given path.
    echo "$HOME/$1"
}

# Performs the necessary I/O operations to create a new file.
# Treats the given path as absolute.
# Takes the file path as the first parameter.
# Takes an optional boolean as the second parameter,
# if true create a dir; otherwise a file.
create_file() {
    # Absolute path
    local path
    path=$(to_absolute "$1")

    # Is directory flag, default is false.
    local is_dir=${2:-false}

    # If directory
    if [ "$is_dir" == true ]; then
        # Check if directory does not exist, or is a file name
        if [[ ! -d "$path" ]] && [[ ! -f "$path" ]]; then
            # -p to create missing intermediate dirs
            mkdir -p "$path"
            display_success "Directory created successfully!"
        else # Does exist
            display_err "Directory already exists!"
        fi
    else # If file
        # Check if file does not exist, or is a directory name
        if [[ ! -f "$path" ]] && [[ ! -d "$path" ]]; then
            # First create intermediates if missing
            mkdir -p "${path%/*}" && touch "$path"
            display_success "File created successfully!"
        else # Does exist
            display_err "File already exists!"
        fi
    fi
}

# Performs the necessary I/O operations to delete a file.
# Treats the given path as absolute.
# Takes the file path as the first parameter.
# Takes an optional boolean as the second parameter,
# if true delete a dir; otherwise a file.
delete_file() {
    # Absolute path
    local path
    path=$(to_absolute "$1")

    # Is directory flag, default is false.
    local is_dir=${2:-false}

    # If directory
    if [ "$is_dir" == true ]; then
        # Check if directory does not exist
        if [ ! -d "$path" ]; then
            display_err "Directory does not exist!"
        else # Does exist
            rm -ir "$path" # Ask for confirmation; -i
            display_success "Directory deleted successfully!"
        fi
    else # If file
        # Check if file does not exist
        if [ ! -f "$path" ]; then
            display_err "File does not exist!"
        else # Does exist
            rm -i "$path" # Ask for confirmation; -i
            display_success "File deleted successfully!"
        fi
    fi
}

# Displays the numbers from lower to upper; [lower, upper].
# Takes lower bound as the first parameter.
# Takes upper bound as the second parameter.
# Note that both bounds are valid when given to the function.
count() {
    # Positive integer input
    local lower=$1

    # Positive integer input
    local upper=$2

    # Loop over the numbers in [lower, upper]
    for ((i = lower; i < upper; i++)); do
        display_success "$i, " true
    done

    display_success "$upper\n" true
}

# Searches for the given phrase in the given directory.
# Takes phrase as first parameter.
# Takes absolute path to directory as second parameter.
search() {
    # Phrase to look for in the directory files
    local phrase=$1

    # Absolute path to directory
    local path
    path=$(to_absolute "$2")

    # Check if directory does not exist
    if [ ! -d "$path" ]; then
        display_err "Directory does not exist!"
    else # Does exist
        # Display the search result
        # Search recursively (-r), add line number (-n), & match the entire phrase (-w).
        # -e for the search pattern (phrase).
        # Store result for display
        local result
        result=$(grep -rnw "$path" -e "$phrase")

        # Check if there are no results
        if [ -z "$result" ]; then
            display_info "Phrase not found!"
        else
            display_info "$result"
        fi

        display_success "Search complete!"
    fi
}

# Keep on taking user input till exiting
while true; do
    # Call the display menu, fill take action input
    display_menu

    # Switch user action
    case $action in
        1) # Create file
            # Take file path
            display_info "Enter the file’s absolute path: "
            read -r file_path

            create_file "$file_path"
            ;;
        2) # Create dir
            # Take dir path
            display_info "Enter the directory's absolute path: "
            read -r dir_path

            create_file "$dir_path" true
            ;;
        3) # Delete file
            # Take file path
            display_info "Enter the file’s absolute path: "
            read -r file_path

            delete_file "$file_path"
            ;;
        4) # Delete directory
            # Take dir path
            display_info "Enter the directory's absolute path: "
            read -r dir_path

            delete_file "$dir_path" true
            ;;
        5) # Count from 1 to n
            # Take lower bound
            display_info "Enter lower bound (positive integer): "
            read -r lower

            # Take upper bound
            display_info "Enter upper bound (positive integer): "
            read -r upper

            # Check if the user input is a valid integer using regex;
            # if check does not pass, warn user.
            if ! { [[ "$lower" =~ ^[-+]?[0-9]+$ ]]; }; then
                display_err "Invalid input, must be an integer!"
            else # valid lower bound
                # Check if the user input is a valid integer using regex;
                # and check if user lower bound is less than or equal to the upper;
                # if both checks do not pass, warn user.
                if ! { [[ "$upper" =~ ^[-+]?[0-9]+$ ]] && ((lower <= upper)); }; then
                    display_err "Invalid input, must be greater than lower bound!"
                else # valid integer
                    count "$lower" "$upper"
                fi
                    count "$lower"
            fi
            ;;
        6) # Search phrase
            # Take phrase to look for
            display_info "Enter the phrase to look for: "
            read -r search_phrase

            # Take directory to look in
            display_info "Enter the directory's absolute path: "
            read -r search_dir

            search "$search_phrase" "$search_dir"
            ;;
        7) # Display current dir
            display_info "Current directory is:"
            pwd | to_absolute
            ;;
        8) # Exit
            display_info "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            display_err "Invalid choice. Please enter a number between 1 and ${#options[@]}."
            ;;
    esac
done
