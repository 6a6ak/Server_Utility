#!/bin/bash

# Define the main menu function
function main_menu() {
    clear
    echo "----------------------------------"
    echo " MAIN MENU"
    echo "----------------------------------"
    echo "1. SSH Key4Git"
    echo "2. cat Key"
    echo "3. User Manager"
    echo "4. Git Loader"
    echo "5. Installer"
    echo "0. Exit"
    echo
    echo "Please enter your choice: "
    read selection
    echo
}

# Define the actions for each menu option
function menu_options() {
    case $selection in
        1) 
            echo "SSH Key 4 Git"
            echo "_________________________________"

            echo "instruction : The SSH Key should be named id_ed25519 which is defult Github key name "
            cd ~/.ssh
            ls

            # Ask for the user's email address
            echo "Enter your email address:"
            read email

            # Retrieve the private and public key names
            echo "Enter the name of your private key file (e.g., id_ed25519):"
            read private_key
            public_key="${private_key}.pub"
            ssh-keygen -t ed25519 -b 4096 -C "$email" -f ~/.ssh/${private_key}

            # Print the path and names of the private and public keys
            echo "Private key: ~/.ssh/${private_key}"
            echo "Public key: ~/.ssh/${public_key}"

            #copy this for authorize
            cat ~/.ssh/${public_key}

            # add to ssh  agent
            eval "$(ssh-agent -s)"
            #it can be id_ed_25519 or id_ed25519
            ssh-add ~/.ssh/id_ed_25519

            #copy this for authorize
            cat ~/.ssh/${public_key}




            ;;
        2) 
            echo "Public Key"
            echo "_________________________________"
            cd $HOME/.ssh
            ls -1 *.pub

            echo "_________________________________"

            echo "Please enter the name of the key file etc id_ed25519.pub):"
            read key_file

            if [ -f ~/.ssh/$key_file ]; then
                cat ~/.ssh/$key_file
            else
                echo "File ~/.ssh/$key_file does not exist."
            fi

            sleep 1000

            ;;
        3)
            echo "User Manager"
              echo "_________________________________"
    
                clear
                text="\e[1m                   User Manager                   \e[0m"
                color="\e[44m"
                width=$(tput cols)
                padding=$(( ($width - ${#text})))
                #tput cup 2 $padding
                echo -ne "${color}${text}\033[0m\n"

                while true; do
                # Display menu and prompt user for selection
                echo "User Manager Menu!"
                echo "1. Change root password"
                echo "2. Switch to root"
                echo "3. Add new user"
                echo "4. Delete user"
                echo "5. Edit SSH config"
                echo "6. Restart SSH service"
                echo "7. Delete this script"
                echo "0. Exit"

                read -p "Select an option: " option
                case $option in
                    1)
                    # Prompt user for new root password
                    read -sp "Enter new root password: " root_password
                    echo

                    # Change root password
                    echo -e "$root_password\n$root_password" | sudo passwd root
                    ;;
                    2)
                    # Prompt user for root password and switch to root if correct
                    read -sp "Enter root password: " root_password
                    echo

                    # Switch to root if password is correct
                    if sudo -kS whoami <<< "$root_password" && sudo -n true; then
                        sudo su -
                    else
                        echo "Incorrect password"
                    fi
                    ;;
                    3)
                    # Prompt user for new username and password
                    read -p "Enter username: " username
                    read -sp "Enter password: " password
                    echo

                    # Add new user
                    sudo useradd -m -s /bin/bash $username
                    echo "$username:$password" | sudo chpasswd
                    ;;
                4)
                    # Prompt user for username to delete
                    read -p "Enter username to delete: " username

                    # Delete user
                    sudo userdel -r $username
                    ;;
                    5)
                    # Check if SSH config has been edited already
                    if sudo grep -Eq "^#?PasswordAuthentication\s+(no|yes)$" /etc/ssh/sshd_config; then
                        # SSH config has been edited, replace with "PasswordAuthentication yes"
                        sudo sed -i -E 's/^#?PasswordAuthentication\s+(no|yes)$/PasswordAuthentication yes/' /etc/ssh/sshd_config
                        sudo sed -i '/^PubkeyAuthentication /c\PubkeyAuthentication yes' /etc/ssh/sshd_config
                    else
                        # SSH config has not been edited, add a comment
                        sudo sed -i '1i# Password authentication has been disabled' /etc/ssh/sshd_config
                    fi
                    echo "SSH config updated."
                    ;;
                    6)
                    # Restart SSH service
                    sudo service ssh restart
                    echo "SSH service restarted."
                    ;;
                7)
                    # Delete this script
                    rm $0
                    echo "Script deleted."
                    ;;
                    0)
                    # Exit script
                    exit;;
                    *)
                    echo "Invalid option";;
                esac
                done

            ;;
        4)
            echo "Git Loader"
             echo "_________________________________"
            

            # Ask user for the directory to clone the repository to
            read -p "Enter the directory to clone the repository to: (Example:/home/user_name/directory_01)" CLONE_DIR

            # Set the SSH address of the repository
            REPO_SSH="git@github.com:0x134134k/Slider.git"

            # Create the directory if it doesn't exist
            mkdir -p "$CLONE_DIR"

            # Change to the clone directory
            cd "$CLONE_DIR"

            # Set the SSH key file location
            SSH_KEY_FILE=~/.ssh/id_ed_25519.pub

            # Extract the repository name from the SSH address
            REPO_NAME=$(echo "$REPO_SSH" | awk -F/ '{print $NF}' | sed 's/.git$//')

            # Create a directory with the same name as the repository
            mkdir -p "$REPO_NAME"

            # Change to the directory
            cd "$REPO_NAME"

            # Clone the repository with SSH
            if GIT_SSH_COMMAND="ssh -i $SSH_KEY_FILE" git clone "$REPO_SSH" .
            then
                echo "Repository cloned successfully to $CLONE_DIR/$REPO_NAME"
            else
                echo "Failed to clone the repository"
            fi
            
            sleep 1000
            ;;
            5)
            echo "All in one Installer"
              echo "_________________________________"
              


                # Get input for the target directory
                read -p "Please enter the directory path(example: /home/user_name/directory_01) " target_directory

                # Change directory to the provided path
                cd "$target_directory"

                # Check if the directory change was successful
                if [ $? -ne 0 ]; then
                    echo "Failed to change directory to $target_directory"
                    exit 1
                fi

                # List the files in the current directory
                ls -l

                # Get input for the script name
                read -p "Please enter the script name: " script_name

                # Check if the script exists and is executable
                if [ ! -x "$script_name" ]; then
                    echo "Script $script_name does not exist or is not executable"
                    exit 1
                fi

                # Run the provided script
                ./$script_name

                # Check if the script execution was successful
                if [ $? -ne 0 ]; then
                    echo "Failed to execute the script: ./$script_name"
                    exit 1
                fi

                exit 0

            ;;
        0) 
            echo "Exiting the program"
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
}

# Continuously display the main menu until the user chooses to exit
while true; do
    main_menu
    menu_options
done
#end
