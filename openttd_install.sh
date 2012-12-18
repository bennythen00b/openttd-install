#!/bin/bash
# written by Bennythen00b
# bennythen00b@gmail.com
# version 0.2.3

# flags
usage="$(basename $0) [-h] [-r] -- simple bash script for installing openttd

where:
    -h  show this help text
    -r  remove all openttd-related files"

while getopts 'hr' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    r)  echo "WARNING: This will remove ALL openttd-related files from your system.
		Are you sure you want to proceed? [y/N]"
		read prompt_delete
		if [ "$prompt_delete" == "y" ] || [ "$prompt_delete" == "Y" ]; then
			echo "Removing all openttd-related files from your system..."
			rm -rf /home/$USER/OpenTTD/
			rm -rf /home/$USER/.openttd/
			exit
		else
			echo "Exiting..."
			exit
		fi
       ;;
    ?) printf "illegal option: '%s'\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
  esac
done
shift $((OPTIND - 1))

# version checking
# todo: make it not suck
while [[ $VERSION != [0-9].[0-9].[0-9] ]] && [[ $VERSION != r* ]]; do
	echo "Enter OpenTTD version:"
	read VERSION
	if [[ $VERSION != [0-9].[0-9].[0-9] ]] && [[ $VERSION != r* ]]; then
		echo "Erronous version format"
	fi
	# different filename for nightly and stable builds
	if [[ $VERSION == [0-9].[0-9].[0-9] ]]; then
		BUILD=stable
		FILE=openttd-$VERSION-linux-generic-amd64.tar.gz
		FOLDER=openttd-$VERSION-linux-generic-amd64
		INSTALL_PATH=/home/$USER/OpenTTD/$VERSION
	elif [[ $VERSION == r* ]]; then
		BUILD=nightly
		FILE=openttd-trunk-$VERSION-linux-generic-amd64.tar.xz
		FOLDER=openttd-trunk-$VERSION-linux-generic-amd64
		INSTALL_PATH=/home/$USER/OpenTTD/$VERSION
	fi
done

# grf prompt
prompt_pack=
echo "Install openttdcoop NewGRF package?" [Y/n]
read prompt_pack

echo
echo "Installing to $INSTALL_PATH..."
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# download files
echo
echo "Downloading files..."

COUNTER=1
while [[ $COUNTER -lt 4 && ! -e $FILE ]]; do
	if [[ $BUILD == stable ]]; then
		wget -nv http://binaries.openttd.org/releases/$VERSION/openttd-$VERSION-linux-generic-amd64.tar.gz
	elif [[ $BUILD == nightly ]]; then
		wget -nv http://hu.binaries.openttd.org/binaries/nightlies/trunk/$VERSION/openttd-trunk-$VERSION-linux-generic-amd64.tar.xz
	fi
	if [[ ! -e $FILE ]]; then
		echo "Error: Download failed. Retrying in 2 seconds... (retry $COUNTER)"
		let COUNTER=COUNTER+1
		sleep 2
		if [[ $COUNTER == 4 ]]; then
			echo "Download failed three times, exiting..."
			exit
		fi
	fi
done

## grf download and install
if [ "$prompt_pack" == "" ] || [ "$prompt_pack" == "y" ] || [ "$prompt_pack" == "Y" ]; then
	mkdir -p /home/$USER/.openttd/newgrf/
	cd /home/$USER/.openttd/newgrf/
	wget -nv http://bundles.openttdcoop.org/grfpack/releases/LATEST/ottdc_grfpack_8.0.tar.gz
	tar -xzvf ottdc_grfpack_8.0.tar.gz
	rm ottdc_grfpack_8.0.tar.gz
fi
##

cd $INSTALL_PATH

wget -nv http://81.166.86.40/public/ttd-files.tgz

if [[ ! -e $INSTALL_PATH/ttd-files.tgz ]]; then
	echo "Original graphics download appears to have failed."
	echo "Exiting.."
	rm -rf $INSTALL_PATH
	exit
fi

# unzip and clean up
echo
echo "Extracting files..."
echo "Extracting $FILE:"
tar -xzvf $FILE

## todo
# error checking
mv $INSTALL_PATH/$FOLDER/* $INSTALL_PATH/
rm $INSTALL_PATH/$FILE
rm -r $INSTALL_PATH/$FOLDER

# does this version of openttd use the "data" folder or the "baseset" folder?
if [[ -a $INSTALL_PATH/baseset/ ]]; then
	DATA=baseset
	elif [[ -a $INSTALL_PATH/data/ ]]; then
		DATA=data
	else
		echo "Error: No data or baseset folder found. Deleting files and exiting."
		rm -rf $INSTALL_PATH
		exit
fi

# extract base files and clean up
echo "Extracting ttd-files.tgz"
tar -xzvf $INSTALL_PATH/ttd-files.tgz -C $INSTALL_PATH/$DATA/
rm $INSTALL_PATH/ttd-files.tgz

