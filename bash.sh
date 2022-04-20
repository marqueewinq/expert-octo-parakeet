#!bin/bash
set -euxo

export RELEASE_REGEX_ALPHA="^v([0-9]+).([0-9]+).([0-9]+)-alpha([0-9]+)$"
export RELEASE_REGEX="^v([0-9]+).([0-9]+).([0-9]+)$"
export RELEASE_REGEX_CANDIDATE="^v([0-9]+).([0-9]+).([0-9]+)-rc([0-9]+)$"
export RELEASE_REGEX_BRANCH_NAME="^release-v([0-9]+).([0-9]+).([0-9]+)$"

function release_internal() {
  latest_tag=$1
  if [[ ${latest_tag} =~ ${RELEASE_REGEX_ALPHA} ]]; then
    export NEW_TAG=$(echo "${latest_tag}" | sed -e "s/alpha${BASH_REMATCH[4]}/alpha$((${BASH_REMATCH[4]} + 1))/g")
  else
    if [[ ${latest_tag} =~ ${RELEASE_REGEX} ]]; then
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
  if [[ ${latest_tag} =~ ${RELEASE_REGEX_ALPHA} ]]; then
    # remove -rcxx suffix
    export latest_tag=$(echo ${latest_tag} | sed -e "s/-rc[0-9]*//g")
  fi

  if [[ ${latest_tag} =~ ${RELEASE_REGEX} ]]; then
    export NEW_TAG=$(echo "${latest_tag}" | \
      sed -e "s/v${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}/v${BASH_REMATCH[1]}.$((${BASH_REMATCH[2]} + 1)).${BASH_REMATCH[3]}/g")
  else
    return 1
  fi

  echo ${NEW_TAG}
  return 0
}

function release_candidate() {
  latest_tag=$1
  branch_name=$2

  if [[ ${latest_tag} =~ ${RELEASE_REGEX_ALPHA} ]]; then
    # remove -alphaxx suffix
    export latest_tag=$(echo ${latest_tag} | sed -e "s/-alpha[0-9]*//g")
  fi

  if [[ ${branch_name} =~ ${RELEASE_REGEX_BRANCH_NAME} ]]; then
    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    patch=${BASH_REMATCH[3]}
    if [[ ${latest_tag} =~ ^v${major}.${minor}.${patch}-rc[0-9]+$ ]]; then
      if [[ ${latest_tag} =~ ${RELEASE_REGEX_CANDIDATE} ]]; then
        export NEW_TAG="v${major}.${minor}.${patch}-rc$((${BASH_REMATCH[4]} + 1))"
      else
        export NEW_TAG="v${major}.${minor}.${patch}-rc0"
      fi
    else
      export NEW_TAG="v${major}.${minor}.${patch}-rc0"
    fi
  else
    return 1
  fi

  echo ${NEW_TAG}
  return 0
}

# unit tests

source assert.sh

assert_eq "v1.0.32-alpha15" $(release_internal "v1.0.32-alpha14")
assert_eq "v17.16.15-alpha17" $(release_internal "v17.16.15-alpha16")
assert_eq "v1.0.1-alpha0" $(release_internal "v1.0.1")

assert_eq "v1.0.1-alpha1" $(release_internal $(release_internal "v1.0.1"))
assert_eq "v1.14.1" $(release_external $(release_external "v1.12.1"))
assert_eq "v1.4.3" $(release_external $(release_internal "v1.3.3"))

assert_eq "v1.4.3-rc0" $(release_candidate "" "release-v1.4.3")
assert_eq "v2.4.3-rc0" $(release_candidate "v2.3.3" "release-v2.4.3")
assert_eq "v3.4.3-rc0" $(release_candidate "v3.4.3" "release-v3.4.3")
assert_eq "v4.4.3-rc1" $(release_candidate "v4.4.3-rc0" "release-v4.4.3")
assert_eq "v5.4.3-rc1" $(release_candidate $(release_candidate "v5.4.3" "release-v5.4.3") "release-v5.4.3")
