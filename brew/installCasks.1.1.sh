#!/usr/bin/env bash

# i is interactive mode
# this will loop through all of the apps and ask for confirmation - only confirmated ones will be installed

# FIXME figure out what cores I installed and what was installed as a dependancy
# TIP brew leaves | xargs brew deps --installed --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"
# TIP https://stackoverflow.com/questions/41029842/easy-way-to-have-homebrew-list-all-package-dependencies/41029864

#################
# VARIABLES
#################

# check command line modifier to guide what actions to take (current modifiers: casks, cores)
case $1 in
  casks) BREWCOMMANDINSTALL='brew install --cask';BREWCOMMANDLIST="brew list --$1";;
  cores) BREWCOMMANDINSTALL='brew install';BREWCOMMANDLIST='brew list --formulae';;
  *) printf "This command needs either 'casks' or 'cores' as a modifier\n"; exit;;
esac
# TIP "https://www.linuxshelltips.com/bash-case-statement-examples/

# get items to load
applications=$(less ./$1)

# get items already installed
declare -a applicationsInstalled=($($BREWCOMMANDLIST))
# printf '%s\n' "${applicationsInstalled[@]}"
# exit

# compare items to load against items already loaded - spit out those not loaded
# TIP https://newbedev.com/intersection-of-two-arrays-in-bash
applicationsNotInstalled=($(comm -13 <(printf '%s\n' "${applications[@]}" | LC_ALL=C sort) <(printf '%s\n' "${applicationsInstalled[@]}" | LC_ALL=C sort)))
# FIXME this seems to be printing out things that are installed, but not in the docs - makes me doubt the logic of the command above - the -13 might not be right - review article
printf "apps not installed\n"
printf '%s\n' "${applicationsNotInstalled[@]}"
exit

#################
# FUNCTIONS
#################

# select applications to install
selectionPrompt () {
  printf "\nInstall: $1\n"
  select yn in 'Yes' 'No'; do
    case $yn in
      Yes ) applicationsYes+=($1); break;;
      No ) applicationsNo+=($1); break;;
    esac
  done
}

# install applications 
installApplications () {
  # printf "\nInstalling these applications\n"
  for file in "${applicationsYes[@]}"; do 
    printf "\nInstalling: $file\n"
    $BREWCOMMANDINSTALL $file
  done
  exit
 }

# loop through applications not installed
selectApplications () {
  for file in "${applicationsNotInstalled[@]}"; do 
    selectionPrompt $file
  done
 }

# show output from selection
showSelections () {
  printf "\n## Applications to install:\n"
  for file in "${applicationsYes[@]}"; do 
    printf "$file\n"
  done

  printf "\n## Applications to skip:\n"
  for file in "${applicationsNo[@]}"; do 
    printf "$file\n"
  done
}

# prompt for continue
installCheck () {
  printf "\nContinue with installation or start over?\n"
  select yn in 'Continue' 'Restart'; do
    case $yn in
      Continue ) installApplications;; 
      Restart ) applicationsYes=();applicationsNo=();selectionLoop;;  # reset variables and start over
    esac
  done
}

selectionLoop () {
  selectApplications
  showSelections
  installCheck
}

#################
# Main
#################

selectionLoop

printf "you hit the end"
