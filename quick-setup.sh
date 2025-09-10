#!/bin/bash

# OEM IT Onboarding Quick Setup Script
# v1.1 - 09-07-2025
# 
# Authors:
# - Jack Greenberg - 09-24-2022
# - Henry Tejada Deras - 09-07-2025

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

main () {
  printf "\n${bold}Welcome to the OEM quick setup!${cl}"
  printf "\n${bold}v1.1 - 09-07-2025"
  # TODO: Bazel, Setup Virtual Environment, KiCad Defaults

  ##################
  # Initialization #
  ##################
  printf "\n"
  printf "${green}${bold}Various Background Tasks...${cl}\n"
  sudo apt-get update # Update Package List


  # Install curl if not already installed
  if command -v curl &> /dev/null; then
      echo "cURL is installed. Skipping installation of cURL."
  else
      sudo apt install curl
  fi
  
  # Directory with Temp files: ~/Downloads/oem-quick-setup-temp
  mkdir -p ~/Downloads/oem-quick-setup-temp
  cd ~/Downloads/oem-quick-setup-temp

  # Install Python and pip, miniconda and other python libraries
  # confirm_and_run "sudo apt install python3 python3-pip python3-distutils"
  confirm_and_run "curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > ~/Downloads/oem-quick-setup-temp/miniconda.sh && \
  chmod -v +x ~/Downloads/oem-quick-setup-temp/miniconda.sh && \
  cd ~/Downloads/oem-quick-setup-temp && \
  ./miniconda.sh"
  cd ~/Downloads/oem-quick-setup-temp
  conda create -n oem python=3.10 -y
  # eval "$(/home/$USER/miniconda3/bin/conda shell.bash hook)"
  confirm_and_run "conda activate oem"

  # TODO: Create OEM conda environment with all necessary packages for OEM work
  printf "\n${green}${bold}Installing Python packages for OEM work...${cl}"
  # Change so packages are installed in OEM environment in conda

  # Install non-python packages for OEM work
  printf "\n${green}${bold}Installing non-Python packages for OEM work...${cl}"
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
  # https://code.visualstudio.com/docs/setup/linux; https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64
  printf "\n"
  printf "${green}${bold}Installing VS Code (latest stable version)...${cl}\n"
  confirm_and_run "curl -L https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 > ~/Downloads/oem-quick-setup-temp/vscode.deb && \
  sudo apt install ~/Downloads/oem-quick-setup-temp/vscode.deb"

  #############
  # TOOLCHAIN #
  #############
  printf "\n"
  printf "\n${green}${bold}Installing buildchain...${cl}\n"
  confirm_and_run "sudo apt-get install build-essential manpages-dev gcc avr-gcc avrdude"

  ########
  # ZOOM #
  ########
  printf "\n"
  printf "\n${green}${bold}Installing Zoom...${cl}\n"
  confirm_and_run "curl -L https://zoom.us/client/latest/zoom_amd64.deb > ~/Downloads/oem-quick-setup-temp/zoom_amd64.deb && \
  sudo dpkg -i ~/Downloads/oem-quick-setup-temp/zoom_amd64.deb"

# FINAL MESSAGE
cat << EOF
Your environment should now be setup. Here are a few things you may want to do now:

  ******************************************************************
  *** https://github.com/OlinElectricMotorSports/AdvancedResearch ***
  ******************************************************************

* ${bold}Fork the Advanced Research GitHub repository ^^^${cl} (create your own copy of it on GitHub)
* ${bold}Clone your forked repository: ${cl}${green}git clone https://github.com/<YOUR_GITHUB_USERNAME>/AdvancedElectrical.git${cl}
    * This copies the repository (all the code and files) to your computer

EOF

}

main
