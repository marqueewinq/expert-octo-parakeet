#!bin/bash
# set -euxo

export RELEASE_REGEX_ALPHA="^v([0-9]+).([0-9]+).([0-9]+)-alpha([0-9]+)$"
export RELEASE_REGEX="^v([0-9]+).([0-9]+).([0-9]+)$"

function release_internal() {
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

function release_external() {
  latest_tag=$1
  if [[ ${latest_tag} =~ ${RELEASE_REGEX_ALPHA} ]]; then
    # remove -alphaxx suffix
    export latest_tag=$(echo ${latest_tag} | sed -e "s/-alpha[0-9]*//g")
  fi

  if [[ ${latest_tag} =~ ${RELEASE_REGEX} ]]; then
    export NEW_TAG=$(echo "${latest_tag}" | sed -e "s/.${BASH_REMATCH[3]}$/.$((${BASH_REMATCH[3]} + 1))/g")
  else
    return 1
  fi

  echo ${NEW_TAG}
  return 0
}

# echo $(release_internal "v1.0.32-alpha14")
# echo $(release_internal "v1.0.0-alpha17")
# echo $(release_internal "v1.0.1")
# echo $(release_internal $(release_internal "v1.0.1"))

# echo $(release_internal $(release_internal "v1.0.1"))
# echo $(release_external $(release_external "v1.0.1"))
# echo $(release_external $(release_internal "v1.0.1"))
