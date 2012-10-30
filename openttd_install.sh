#!/bin/bash
# written by Bennythen00b
# bennythen00b@gmail.com
# version 0.2.2
#
# TODO:
#  - change $INSTALL_PATH to $INST or similar?
#  - finish grf pack

while [[ $VERSION != [0-9].[0-9].[0-9] ]] && [[ $VERSION != r* ]]; do
	echo "Enter OpenTTD version:"
	read VERSION
	if [[ $VERSION != [0-9].[0-9].[0-9] ]]; then
	echo "Erronous version format"
	fi
	# Different filename for nightly and stable builds
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

## NOT FINISHED
# Download and install grf pack?
#
#PACK=null
#echo "Install openttdcoop NewGRF package?" [Y/n]
#read PACK
#
#if [ $PACK == null ] || [ $PACK == Y ] || $PACK == y ]; then
#	PACKINSTALL=true
#fi
##

echo
echo "Installing to $INSTALL_PATH..."
mkdir -p $INSTALL_PATH
cd $INSTALL_PATH

# Download files
echo
echo "Downloading files..."

COUNTER=1
while [[ $COUNTER -lt 4 && ! -e $FILE ]]; do
	if [ $BUILD == stable ]; then
		wget -nv http://binaries.openttd.org/releases/$VERSION/openttd-$VERSION-linux-generic-amd64.tar.gz
	elif [ $BUILD == nightly ]; then
		wget -nv http://hu.binaries.openttd.org/binaries/nightlies/trunk/$VERSION/openttd-trunk-$VERSION-linux-generic-amd64.tar.xz
	fi
	if [ ! -e $FILE ]; then
		echo "Error: Download failed. Retrying in 2 seconds... (retry $COUNTER)"
		let COUNTER=COUNTER+1
		sleep 2
		if  [ $COUNTER == 4 ]; then
			echo "Download failed three times, exiting..."
			exit
		fi
	fi
done

#if $PACKINSTALL == true ];]; then
#	wget -nv http://bundles.openttdcoop.org/grfpack/releases/LATEST/ottdc_grfpack_8.0.tar.gz
#fi
wget -nv http://81.166.86.40/public/ttd-files.tgz

# Unzip OpenTTD and clean up
echo
echo "Extracting files..."
echo "Extracting $FILE:"
tar -xzvf $FILE
## TODO
# if exist etc?
# if not exist delete everything?
mv $INSTALL_PATH/$FOLDER/* $INSTALL_PATH/
rm $INSTALL_PATH/$FILE
rm -r $INSTALL_PATH/$FOLDER

# Does this version of OpenTTD use the "data" folder
# or the "baseset" folder?

if [ -a baseset ]; then
	DATA=baseset
elif [ -a data ]; then
	DATA=data
else	echo "Error: No data or baseset folder found. Deleting files and exiting."
	rm -r /home/$USER/OpenTTD/
	exit

fi

# Extract base files and clean up
echo "Extracting ttd-files.tgz"
tar -xzvf $INSTALL_PATH/ttd-files.tgz -C $INSTALL_PATH/$DATA/
rm $INSTALL_PATH/ttd-files.tgz
