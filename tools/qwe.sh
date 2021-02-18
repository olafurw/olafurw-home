#!/bin/bash
#
# qwe.source 
#
# Copyright 2021 MindShareManagement Inc.
# Written for the Kubuntu Focus by
#
# - Michael Mikowski
#
# Inspiration: https://superuser.com/questions/416881
# Original source: https://github.com/olafurw/olafurw-home/blob/master/tools/qwe.sh
# 
# This is a complete rewrite and passes shellcheck.
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
    _pwd_str=$(pwd);

    if ! _chkTagNameFn "${_tag_name}"; then
      return $?;
    fi

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

    if ! _chkTagNameFn "${_tag_name}"; then
      return $?;
    fi

    sed -i -e "/^${_tag_name}\\t/d" "${_dataFile}";
    return 0;
  }

  _printHelpFn () {
    1>&2 cat <<_EOH

  Usage:
    ${_cName}    <tag> : Traverse to folder identified by <tag>
    ${_cName} -a <tag> : Add a <tag> pointing to current folder
    ${_cName} -d <tag> : Remove <tag> record
    ${_cName} -h       : Show this help message
    ${_cName} -l       : List all known tags
    ${_cName} -p <tag> : Print the folder identified by <tag>

_EOH
    return 0;
  }

  _listTagLinesFn () {
    1>&2 cat "${_dataFile}";
    return 0;
  }

  _getTagStrFn () {
    declare _tag_name _line_str _dir_str;
    _tag_name="${*}";

    if ! _chkTagNameFn "${_tag_name}"; then
      return $?;
    fi

    _line_str=$(grep -E "^${_tag_name}"$'\t' "${_dataFile}");
    if [ -z "${_line_str}" ]; then
      1>&2 echo -e "\n${_cName} ERROR: tag ${_tag_name} not found\n";
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
    if ! _dir_str=$(_getTagStrFn "${_tag_name}"); then
      return $?;
    fi
    echo "${_dir_str}";
    return 0;
  }

  _cdTagPathFn () {
    declare _tag_name _dir_str;
    _tag_name="${*}";
    if ! _dir_str=$(_getTagStrFn "${_tag_name}"); then
      return $?;
    fi
    cd "${_dir_str}" || return 1;
    return 0;
  }

  # Begin Process Options {
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

complete -F _qweAliasFn qwe
# END MAIN }
