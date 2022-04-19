#!bin/bash

export RELEASE_REGEX_ALPHA="^v([0-9]+).([0-9]+).([0-9]+)-alpha([0-9]+)$"
export RELEASE_REGEX="^v([0-9]+).([0-9]+).([0-9]+)$"

function get_new_tag() {
  latest_tag=$1
  if [[ ${latest_tag} =~ ${RELEASE_REGEX_ALPHA} ]]; then
    export NEW_TAG=$(echo "${latest_tag}" | sed -e "s/alpha${BASH_REMATCH[4]}/alpha$((${BASH_REMATCH[4]} + 1))/g")
  else
    if [[ ${latest_tag} =~ ${RELEASE_REGEX} ]]; then
      # export NEW_TAG=$(echo "${latest_tag}" | sed -e "s/.${BASH_REMATCH[3]}$/.$((${BASH_REMATCH[3]} + 1))/g")
      export NEW_TAG="${latest_tag}-alpha0"
    else
      return 1
    fi
  fi

  echo ${NEW_TAG}
  return 0
}

# echo $(get_new_tag "v1.0.32-alpha14")
# echo $(get_new_tag "v1.0.0-alpha17")
# echo $(get_new_tag "v1.0.1")
# echo $(get_new_tag $(get_new_tag "v1.0.1"))
#
#
