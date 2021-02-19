#!/bin/bash
#
# qwe.source
#
# Original concept and code:
#   https://github.com/olafurw/olafurw-home/blob/master/tools/qwe.sh
# Inspiration: https://superuser.com/questions/416881
#
# Copyright 2021 MindShareManagement Inc.
# Adapted for the Kubuntu Focus by
#   - Michael Mikowski
#
# This is designed to be source during shell startup by .bashrc or similar.
#

qwe () {
  _chkTagNameFn () {
    declare _tag_name;
    _tag_name="${*}";

    if [ -z "${_tag_name}" ]; then
      1>&2 echo -e "\n${_cName} ERROR: Argument required.\n";
      return 1;
    fi

    if ! echo "${_tag_name}" |grep -qE '^[0-9a-zA-Z_.-]+$'; then
      1>&2 echo -e "\n${_cName} ERROR: Special chars in tag name";
      1>&2 echo -e "  Use only 0-9, A-z, period, -, or _.\n";
      return 1;
    fi
    return 0;
  }

  _addTagFn () {
    declare _tag_name _pwd_str;
    _tag_name="${*}";
    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    _pwd_str=$(pwd);
    if grep -qE "^${_tag_name}"$'\t' "${_dataFile}"; then
      1>&2 echo -e "\n${_cName} ERROR: tag already exists";
      1>&2 echo -e "  Delete it first to replace it.\n";
      return 1;
    fi

    echo -e "${_tag_name}\t${_pwd_str}" >> "${_dataFile}";
    return 0;
  }

  _delTagFn () {
    declare _tag_name;
    _tag_name="${*}";
    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    sed -i -e "/^${_tag_name}\\t/d" "${_dataFile}";
    return 0;
  }

  _printHelpFn () {
    1>&2 cat <<_EOH

  ${_cName} Folder Bookmark Utility
  ===========================
  Usage:
    ${_cName}    <tag> : Traverse to folder identified by <tag>
    ${_cName} -a <tag> : Add a <tag> pointing to current folder
    ${_cName} -d <tag> : Remove <tag> record
    ${_cName} -h       : Show this help message
    ${_cName} -l       : List all known tags (sorted)
    ${_cName} -p <tag> : Print the folder identified by <tag>

_EOH
    return 0;
  }

  _listTagLinesFn () {
    1>&2 echo -e "\nTag\tFolder";
    1>&2 echo -e   "===\t========";
    1>&2 sort "${_dataFile}";
    1>&2 echo;
    return 0;
  }

  _getTagDirFn () {
    declare _tag_name _line_str _dir_str;
    _tag_name="${*}";
    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    _line_str=$(grep -E "^${_tag_name}"$'\t' "${_dataFile}");
    if [ -z "${_line_str}" ]; then
      1>&2 echo -e "\n${_cName} ERROR: tag ${_tag_name} not found.";
      _listTagLinesFn;
      return 1;
    fi

    # shellcheck disable=SC2001
    _dir_str=$(echo -e "${_line_str}" |sed -e "s/^${_tag_name}\\t//");
    echo "${_dir_str}";
    return 0;
  }

  _printTagDirFn () {
    declare _tag_name _dir_str;
    _tag_name="${*}";
    if ! _dir_str=$(_getTagDirFn "${_tag_name}"); then return $?; fi

    echo "${_dir_str}";
    return 0;
  }

  _cdTagPathFn () {
    declare _tag_name _dir_str;
    _tag_name="${*}";
    if ! _dir_str=$(_getTagDirFn "${_tag_name}"); then return $?; fi
    cd "${_dir_str}" || return 1;
    return 0;
  }

  # Begin Process Options {
  # TODO: Add rename taq capability
  # TODO: Add default bookmarks
  _opt_str="${1}";
  case "${_opt_str}" in
    -a ) _addTagFn "${2}"; return $?;;
    -d ) _delTagFn "${2}"; return $?;;
    -h ) _printHelpFn;     return $?;;
    -l ) _listTagLinesFn;  return $?;;
    -p ) _printTagDirFn "${2}"; return $?;;
    -* ) 1>&2 echo -e "\n${_cName} Invalid option: -${OPTARG} \n"
      _printHelpFn; return $?;;
  esac

  if [ "$#" = '1' ]; then
    if ! _cdTagPathFn "${1}"; then
      1>&2 echo -e "\n${_cName} No such tag";
      1>&2 echo -e "  Valid tags are listed below\n";
      _listTagLinesFn;
      return 1;
    fi
  else
    _printHelpFn; return $?;
  fi
  # End Process Options }
}

# tab completion
_qweAliasFn () {
  declare _pwd_str;
  _pwd_str="${2}";

  # shellcheck disable=SC2207
  COMPREPLY=( $( grep "^${_pwd_str}" "$HOME/.qwe.data" | cut -f1 ) )
  return 0;
}

# BEGIN MAIN {
_dataFile="${HOME}/.qwe.data";
_cName='qwe';
touch "${_dataFile}";

complete -F _qweAliasFn qwe
# END MAIN }
