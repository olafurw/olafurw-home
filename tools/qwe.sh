#!/bin/bash
#
# Copyright 2021 Ólafur Waage, Michael Mikowski
#
# Name   : qwe.source
# Purpose: Command line bookmarks with autocomplete
# License: GPL v2
#
# Original concept and code
#   https://github.com/olafurw/olafurw-home/blob/master/tools/qwe.sh
# Inspiration: https://superuser.com/questions/416881
#
# Please add a line to .bashrc to provide this function:
#   source /path/to/qwe.sh
#

qwe () {
  ## BEGIN UTILITIES {
  _echoHeadFn () {
    declare _title _arg_str _count _under_str;
    _arg_str="$*";
    _title="${_baseName} Bookmarks";

    if [ -n "${_arg_str}" ]; then
      _title="${_title}: ${_arg_str}";
    fi

    _count=${#_title};
    _under_str=$(printf "%${_count}s" |tr ' ' '=');

    1>&2 cat <<_EOH01

  ${_title}
  ${_under_str}
_EOH01
  }

  _echoHelpFn () {
    1>&2 cat <<_EOH02
  ${_baseName}          : Interactive select directory
  ${_baseName}    <tag> : Change to directory identified by <tag>
  ${_baseName} -a <tag> : Add a <tag> pointing to current directory
  ${_baseName} -d <tag> : Delete <tag>
  ${_baseName} -h or -? : Show this help message
  ${_baseName} -l       : Show sorted list of tags
  ${_baseName} -p <tag> : Print the directory identified by <tag>
  ${_baseName} -r <tag> <new> : Rename <tag> with <new> name
  ${_baseName} -s       : Show tag of current directory

  Press <TAB> to auto-complete tag names.
_EOH02
  }

  _echoMsgFn () {
    declare _str;
    _str="$*";
    if [ -z "${_str}" ]; then
      1>&2 echo;
    else
      1>&2 echo -e "  ${_baseName}: ${_str}";
    fi
  }

  _chkTagNameFn () {
    declare _tag_name;
    [ $# -gt 0 ] && _tag_name="$1" || _tag_name='';

    if [ -z "${_tag_name}" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Argument required.\n";
      return 1;
    fi

    if ! echo "${_tag_name}" |grep -qE '^[0-9a-zA-Z_.-]+$'; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Special chars in tag name |${_tag_name}";
      _echoMsgFn "  Use only 0-9, A-z, period, -, or _.\n";
      return 1;
    fi
    return 0;
  }

  _getTagDirFn () {
    declare _tag_name _line_str _dir_str;
    [ $# -gt 0 ] && _tag_name="$1" || _tag_name='';
    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    _line_str=$(grep -E "^${_tag_name}"$'\t' "${_dataFile}");
    if [ -z "${_line_str}" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Tag ${_tag_name} not found.";
      _echoMsgFn "Use -l to list; -h or -? for help\n";
      return 1;
    fi

    # shellcheck disable=SC2001
    _dir_str=$(echo -e "${_line_str}" |sed -e "s/^${_tag_name}\\t//");
    echo "${_dir_str}";
    return 0;
  }

  _echoPwdTagFn () {
    declare _pwd_str _found_line _tag_str;

    [ "$#" -gt 0 ] && _pwd_str="$1" || _pwd_str="$(pwd)";
    _tag_str='';
    _found_line="$(grep -E $'^[^\t]+\t'"${_pwd_str}$" "${_dataFile}")";

    if [ -n "${_found_line}" ]; then
      _tag_str="$(echo "${_found_line}" |awk '{print $1}')";
    fi

    echo "${_tag_str}";
  }
  ## . END UTILITIES }

  ## BEGIN OPTION HANDLERS {
  _addTagFn () {
    declare _tag_name _pwd_str _pwd_tag_str;
    [ $# -gt 0 ] && _tag_name="$1" || _tag_name='';
    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    _pwd_str="$(pwd)";
    if grep -qE "^${_tag_name}"$'\t' "${_dataFile}"; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Tag |${_tag_name}| already exists.";
      _echoMsgFn "  Please provide a new, unique tag name.\n";
      return 1;
    fi

    _pwd_tag_str="$(_echoPwdTagFn "${_pwd_str}")";
    if [ -n "${_pwd_tag_str}" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "This directory already has the tag |${_pwd_tag_str}|.";
      _echoMsgFn "  Use -r to rename the tag or -d to delete it.\n";
      return 1;
    fi

    echo -e "${_tag_name}\t${_pwd_str}" >> "${_dataFile}";
    return 0;
  }

  _deleteTagFn () {
    declare _found_line _tag_name;
    [ $# -gt 0 ] && _tag_name="$1" || _tag_name='';

    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi

    _found_line=$(grep -E "^${_tag_name}"$'\t'  "${_dataFile}");
    if [ -z "$_found_line" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Tag |${_tag_name}| does not exist.";
      _echoMsgFn "  Use -l to list tags or -h for help.\n";
      return 1;
    fi

    sed -i -e "/^${_tag_name}\\t/d" "${_dataFile}";
    return 0;
  }

  _echoTagLinesFn () {
    declare _pwd_tag_str _sort_str;
    _pwd_tag_str="$(_echoPwdTagFn)";

    _sort_str="$(sort "${_dataFile}" |sed -E 's/^/  /g')";
    echo -e "  TAG\tDIRECTORY
  ~\tHome: ${HOME:?Not Available}
  -\tLast: ${__QweLastDirname:-No Last directory}
${_sort_str}
";
    if [ -n "${_pwd_tag_str}" ]; then
      echo -e "  ${_pwd_tag_str}\t<= CURRENT DIRECTORY TAG\n";
    fi
    return 0;
  }

  _cdTagDirFn () {
    declare _tag_name _dir_str _pwd_str;
    [ $# -gt 0 ] && _tag_name="$1" || _tag_name='';

    case "${_tag_name}" in
      '~' )
        if [ -n "${HOME}" ]; then
          _dir_str="${HOME}";
        else
          _echoHeadFn 'ERROR';
          _echoMsgFn 'HOME directory is not set.';
          return 1;
        fi
        ;;
      '-' )
        if [ -n "${__QweLastDirname}" ]; then
          _dir_str="${__QweLastDirname}";
        else
          _echoHeadFn 'ERROR';
          _echoMsgFn 'No previous qwe directory. Please try again';
          return 1;
        fi
        ;;
      * )
        if ! _dir_str=$(_getTagDirFn "${_tag_name}"); then
          return $?;
        fi
        ;;
    esac

    _pwd_str="$(pwd)";
    cd "${_dir_str}" || return 1;

    if [ "${_pwd_str}" != "${__QweLastDirname}" ]; then
      __QweLastDirname="${_pwd_str}";
    fi

    return 0;
  }

  _echoTagDirFn () {
    declare _tag_name _dir_str;
    [ "$#" -gt 0 ] && _tag_name="$1" || _tag_name='';

    if ! _dir_str="$(_getTagDirFn "${_tag_name}")"; then return $?; fi
    echo "${_dir_str}";
    return 0;
  }

  _interactFn () {
    declare _reply;

    _echoTagLinesFn;
    read -rp '  Enter a tag, ? for help, or  <Enter> to exit: ' _reply;
    if [ "${_reply}" = '?' ]; then
      _echoHeadFn 'HELP'; _echoHelpFn;
      return 0;
    fi

    if [ -n "${_reply}" ]; then
      _cdTagDirFn "${_reply}";
      return $?;
    else
      _echoMsgFn;
      _echoMsgFn 'Exit';
      _echoMsgFn;
      return 0;
    fi
  }

  _renameTagFn () {
    declare _tag_name _new_name _found_line;
    [ "$#" -gt 0 ] && _tag_name="$1" || _tag_name='';
    [ "$#" -gt 1 ] && _new_name="$2" || _new_name='';

    if ! _chkTagNameFn "${_tag_name}"; then return $?; fi
    if ! _chkTagNameFn "${_new_name}"; then return $?; fi

    _found_line="$(grep -E "^${_tag_name}"$'\t'  "${_dataFile}")";
    if [ -z "${_found_line}" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "Old Tag |${_tag_name}| not found.";
      _echoMsgFn "  Use -l to list tags or -h for help.\n";
      return 1;
    fi

    _found_line="$(grep -E "^${_new_name}"$'\t'  "${_dataFile}")";
    if [ -n "${_found_line}" ]; then
      _echoHeadFn 'ERROR';
      _echoMsgFn "New Tag |${_new_name}| already exists.";
      _echoMsgFn "  Use -l to list tags or -h for help.\n";
      return 1;
    fi

    if sed -i "s/^${_tag_name}"$'\t'"/${_new_name}"$'\t'"/g" \
      "${_dataFile}"; then
      _echoMsgFn "Tag |${_tag_name}| renamed to |${_new_name}|\n";
      return 0;
    fi

    _echoHeadFn 'ERROR';
    _echoMsgFn "Could not rename |${_tag_name}|\n"
    return 1;
  }
  ## . END OPTION HANDLERS }

  ## Begin Process option {
  #  Any option consumes arguments and returns
  #
  declare _arg1_str _arg2_str _arg3_str;
  [ "$#" -gt 0 ] && _arg1_str="$1" || _arg1_str='';
  [ "$#" -gt 1 ] && _arg2_str="$2" || _arg2_str='';
  [ "$#" -gt 2 ] && _arg3_str="$3" || _arg3_str='';

  case "${_arg1_str}" in
    -  ) ;;
    -a ) _addTagFn "${_arg2_str}"; return $?;;
    -d ) _deleteTagFn "${_arg2_str}"; return $?;;
    -h|-\? ) _echoHeadFn 'HELP'; _echoHelpFn; return 0;;
    -l ) _echoHeadFn 'LIST'; _echoTagLinesFn; return $?;;
    -p ) _echoTagDirFn "${_arg2_str}"; return $?;;
    -r ) _renameTagFn "${_arg2_str}" "${_arg3_str}"; return $?;;
    -s ) _echoPwdTagFn; return $?;;
    -* )
      _echoHeadFn 'ERROR';
      _echoMsgFn "Invalid option: ${_arg1_str} \n";
      _echoHeadFn 'HELP'; _echoHelpFn; return 1;;
  esac;
  ## End Process option }

  ## Begin Process tag {
  if [ "${_arg1_str}" = "${HOME}" ]; then
    _arg1_str='~';
  fi

  if [ -n "${_arg1_str}" ]; then
    _cdTagDirFn "${_arg1_str}";
    return $?;
  else
    _echoHeadFn 'LIST';
    _interactFn;
    return $?;
  fi
  ## End Process tag }
}

## BEGIN Tab completion support {
_qweAliasFn () {
  declare _pwd_str;
  [ "$#" -gt 1 ] && _pwd_str="$2" || _pwd_str='';

  __QweLastDirname='';
  IFS=$'\n' read -r -d '' -a COMPREPLY < <(
    grep "^${_pwd_str}" "${_dataFile}" | cut -f1
  );
  return 0;
}
## . END Tab completion support }

## BEGIN MAIN {
_dataFile="${HOME}/.qwe.data";
_baseName='qwe';
touch "${_dataFile}";

complete -F _qweAliasFn qwe
## END MAIN }
