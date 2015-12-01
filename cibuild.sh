#!/bin/sh

set -e

usage()
{
    echo "Options"
    echo "  --os <os>                      OS to run (Linux / Darwin)"
    echo "  --scope <scope>                Scope of the build (Compile / Test)"
}

build()
{
	echo Build Command: "xbuild $XBUILD_ARGS"

	xbuild $XBUILD_ARGS

	echo Build completed. Exit code: $?
	egrep "Warning\(s\)|Error\(s\)|Time Elapsed" "$LOG_PATH_ARG"
	echo "Log: $LOG_PATH_ARG"
}

SCRIPT_PATH="`dirname \"$0\"`"

#Default build arguments
OS_ARG="OSX"
TARGET_ARG="Build"
LOG_PATH_ARG="$SCRIPT_PATH"/"msbuild.log"
PROJECT_FILE_ARG="$SCRIPT_PATH"/"build.proj"

while [[ $# > 0 ]]
do
    opt="$1"
    case $opt in
        -h|--help)
        usage
        exit 1
        ;;
        --os)
        OS_NAME=$2
        shift 2
        ;;
        --scope)
        SCOPE=$2
        shift 2
        ;;
        *)
        usage 
        exit 1
        ;;
    esac
done

if [[ "$OS_NAME" = "Linux" ]]; then
	OS_ARG="Unix"
elif [[ "$OS_NAME" = "Darwin" ]]; then
	OS_ARG="OSX"
fi

if [[ "$SCOPE" = "Compile" ]]; then
	TARGET_ARG="Build"
elif [[ "$SCOPE" = "Test" ]]; then
	TARGET_ARG="BuildAndTest"
fi

MSBUILD_ARGS="$PROJECT_FILE_ARG /t:$TARGET_ARG /p:OS=$OS_ARG /p:Configuration=Debug-Netcore /verbosity:minimal /fileloggerparameters:Verbosity=diag;LogFile=$LOG_PATH_ARG"

XBUILD_ARGS="$MSBUILD_ARGS"

build