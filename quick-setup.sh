#!/bin/bash

# OEM IT Onboarding Quick Setup Script
# v1.1 - 09-12-2025
# 
# Authors:
# - Jack Greenberg - 09-24-2022
# - Henry Tejada Deras - 09-07-2025
# - Microsoft Copilot + GitHub Copilot
#
# Assumptions:
# - Ubuntu 24.04.3 LTS or later

# Declarations ##################################################
set -u

# Colors
red=$(printf '\033[0;31m')
green=$(printf '\033[0;32m')
blue=$(printf '\033[34m')
white=$(printf '\033[97m')
bold=$(printf '\033[1m')
cl=$(printf '\033[0m')

confirm_and_run() {
  cmd=$1
  read -p "${white}Run ${green}${cmd}${white}? [y/n] " -n 1 -r resp
  printf "\n"

  case $resp in
    [yY][eE][sS]|[yY])
      printf "\n${green}Running: ${blue}${bold}$1${cl}\n"
      eval $1
      ;;
    [nN][oO]|[nN])
      printf "${red}${bold}Skipping ${green}$1${cl}\n"
      ;;
    *)
      echo "Invalid input...\n"
      exit 1
      ;;
  esac
}

# Main Script ##################################################
main () {
  printf "\n${bold}Welcome to the OEM quick setup!${cl}"
  printf "\n${bold}v1.1 - 09-07-2025"
  # TODO: Bazel, Setup Virtual Environment, KiCad Defaults

  # Get Script File Directory
  SCRIPT_PATH=$(readlink -f "$0")
  printf "\nScript Location: ${blue}${bold}$SCRIPT_PATH${cl}\n"

  ##################
  # Initialization #
  ##################
  printf "\n"
  read -p "Are you sure you ready to proceed? (Y/n): " response
  if [[ "$response" == [yY] ]]; then
      echo "Proceeding..."
  else
      echo "Setup canceled."
      exit 0
  fi

  # Update Package List
  printf "\n"
  printf "${green}${bold}Updating Package List...${cl}\n"
  sudo apt-get update

  # Create Directory with Temp files: ~/Downloads/oem-quick-setup-temp
  printf "\n"
  printf "${green}${bold}Create Temporary Files Directory (if not present)...${cl}\n"
  TMP_DIR=~/Downloads/oem-quick-setup-temp
  mkdir -p $TMP_DIR
  cd $TMP_DIR
  printf "Temporary Files Directory: ${blue}${bold}$TMP_DIR${cl}\n"

  # Read Previous Script State (Handles Shell Restarts)
  printf "\n"
  printf "${green}${bold}Read Previous Script State...${cl}\n"
  # Save the state to a temporary file
  STATE_FILE="$TMP_DIR/script_state.txt"

  # Check if the state file exists
  if [[ -f "$STATE_FILE" ]]; then
      # Read the state
      STATE=$(cat "$STATE_FILE")
  else
      # Initialize the state
      STATE="Start"
  fi
  printf "Current State: ${blue}${bold}$STATE${cl}\n"
  
  # Determine action based on state
  case "$STATE" in
    "Start")
        # Install cURL if not already installed
        printf "\n${green}${bold}Checking for cURL...${cl}\n"
          if command -v curl &> /dev/null; then
              echo "cURL is installed. Skipping installation of cURL."
          else
              sudo apt install curl
          fi
        
        # Install Miniconda
        printf "\n${green}${bold}Installing Miniconda...${cl}\n"
        confirm_and_run "curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > $TMP_DIR/miniconda.sh && \
        chmod -v +x $TMP_DIR/miniconda.sh && \
        cd $TMP_DIR && \
        ./miniconda.sh"

        # printf "\n${green}${bold}Restarting Shell to Apply Changes...${cl}\n"
        echo "Step 2" > "$STATE_FILE"  # Save the next state
        printf "\n${green}${bold}Please restart your shell to apply changes and then re-run the script.${cl}\n"
        exit 0
        # exec $SHELL $SCRIPT_PATH # Restart the shell and restart script
        ;;
    "Step 2")
        # Accept Conda TOS
        printf "\n${green}${bold}Accepting Conda TOS...${cl}\n"
        printf "Anaconda Terms of Service: https://www.anaconda.com/legal/terms/terms-of-service\n"
        printf "Anaconda Privacy Policy: https://www.anaconda.com/legal/privacy-policy\n"
        printf "You must accept the Terms of Service to proceed. By inputting "y", you are accepting the terms of service.\n"
        printf "\n"
        read -p "Do you accept Anaconda's Terms of Service? (Y/n): " response
        if [[ "$response" == [yY] ]]; then
            echo "You accepted Anaconda's Terms of Service. Continuing setup."
            conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
            conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
        elif [[ "$response" == [nN] ]]; then
            echo "You did not accept the Terms of Service. Exiting setup."
            exit 0
        else
            echo "Invalid input. Exiting setup."
            exit 0
        fi

        # Create OEM Conda Environment
        printf "\n${green}${bold}Creating OEM Conda Environment...${cl}\n"
        confirm_and_run "conda create -n oem python=3.10 -y"

        # Setting OEM Conda Environment to Auto-Activate on Shell Start
        printf "\n${green}${bold}Setting OEM Conda Environment to Auto-Activate on Shell Start...${cl}\n"
        conda config --set auto_activate_base false
        echo "conda activate oem" >> ~/.bashrc
        source ~/.bashrc

        # printf "\n${green}${bold}Restarting Shell to Apply Changes...${cl}\n"
        echo "Restarts Done" > "$STATE_FILE"  # Save the next state
        printf "\n${green}${bold}Please restart your shell to apply changes and then re-run the script.${cl}\n"
        exit 0
        # exec $SHELL $SCRIPT_PATH # Restart the shell and restart script
        ;;
    "Restarts Done")
        # Install Python packages for OEM work
        printf "\n"
        printf "${green}${bold}TODO: Installing Python packages for OEM work...${cl}\n"
        # TODO: Create OEM conda environment with all necessary packages for OEM work
        # Change so packages are installed in OEM environment in conda

        # Install Non-Python packages for OEM work
        printf "\n${green}${bold}Installing Non-Python packages for OEM work...${cl}"
        confirm_and_run "pip3 install cantools && \
        sudo apt install can-utils"
        sudo apt-get update # Update Package List

        #######
        # GIT #
        #######
        # https://git-scm.com/book/en/v2/Getting-Started-Installing-Git
        printf "\n"
        printf "${green}${bold}Installing Git (latest stable version)...${cl}\n"
        confirm_and_run "sudo apt install git-all"
        eval "git --version"

        #########
        # Bazel #
        #########
        # https://bazel.build/install/ubuntu
        printf "\n"
        printf "${green}${bold}TODO: Installing Bazel (latest stable version)...${cl}\n"
        # TODO: IMPLEMENT THIS

        #########
        # KICAD #
        #########
        # https://www.kicad.org/download/linux/
        printf "\n"
        printf "${green}${bold}Installing KiCad (latest stable version)...${cl}\n"
        confirm_and_run "sudo add-apt-repository ppa:kicad/kicad-9.0-releases && \
        sudo apt update && \
        sudo apt install kicad"

        ###########
        # VS CODE #
        ###########
        # Installed using Ubuntu's snap package manager
        printf "\n"
        printf "${green}${bold}Installing VS Code (latest stable version)...${cl}\n"
        confirm_and_run "sudo snap install --classic code"

        ################################
        # TOOLCHAIN - ATmega 16M1/64M1 #
        ################################
        printf "\n"
        printf "\n${green}${bold}Installing buildchain (for ATmega 16M1/64M1)...${cl}\n"
        confirm_and_run "sudo apt-get install build-essential manpages-dev gcc avr-gcc avrdude"

        #########################################
        # TOOLCHAIN - STM32G441KBT6/STM32G474RE #
        #########################################
        printf "\n"
        printf "\n${green}${bold}TODO: Installing buildchain (for STM32G441KBT6/STM32G474RE)...${cl}\n"
        # TODO: IMPLEMENT THIS

        ########
        # ZOOM #
        ########
        # https://support.zoom.com/hc/en/article?id=zm_kb&sysparm_article=KB0063458
        printf "\n"
        printf "\n${green}${bold}Installing Zoom...${cl}\n"
        confirm_and_run "sudo apt-get install libglib2.0-0 libgstreamer-plugins-base0.10-0 libxcb-shape0 libxcb-shm0 libxcb-xfixes0 libxcb-randr0 \
        libxcb-image0 libfontconfig1 libgl1-mesa-glx libxi6 libsm6 libxrender1 libpulse0 libxcomposite1 libxslt1.1 libsqlite3-0 \
        libxcb-keysyms1 libxcb-xtest0 ibus"
        confirm_and_run "curl -L https://zoom.us/client/latest/zoom_amd64.deb > ~/Downloads/oem-quick-setup-temp/zoom_amd64.deb && \
        sudo dpkg -i ~/Downloads/oem-quick-setup-temp/zoom_amd64.deb"
        ;;
    
        ############
        # CLEAN UP #
        ############
        # Remove Temporary Files Directory
        printf "\n"
        printf "${green}${bold}Cleaning Up Temporary Files...${cl}\n"
        rm -rf $TMP_DIR
  esac

# FINAL MESSAGE
cat << EOF
Congratulations! Your environment should now be setup. Please verify that the following commands work:
  - [Add Bazel Commands Here]

EOF

}

main
