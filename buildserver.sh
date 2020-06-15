#!/bin/bash 

build_reporting(){	
if [[ $1 = 1 ]];then
        echo "BUILD FOR $PLATFORM FAILED at $2!"
	STATUS="FAILED"
	exit 0
elif [[ $1 = 0 ]];then
        echo "BUILD FOR $PLATFORM COMPLETED SUCCESSFULLY!"
	echo "OUTPUT IMAGES ARE STORED AT $IMAGE_DIR "
	ls $IMAGE_DIR
	STATUS="PASSED"
fi	

SERVER_EMAIL_ID=""
SERVER_EMAIL_PSWD=""
USER_EMAIL_ID=$USER_EMAIL
LOG_FILE="${LOGS_DIR}/build_log.txt"
EMAIL_BODY="image build for $PLATFORM has ${STATUS} .
Build log is attached in email . 
Build images can be found at $IMAGE_DIR,
logs can be found at ${LOGS_DIR}/build_log.txt
at machine 192.168.3.217"
EMAIL_SUBJECT="BOARDFARM|${PLATFORM}|BUILD STATUS - ${STATUS}"

#python3 $SOURCE_DIR/../../send_email.py ${SERVER_EMAIL_ID} ${SERVER_EMAIL_PSWD} ${USER_EMAIL_ID} ${LOG_FILE} "${EMAIL_BODY}" "${EMAIL_SUBJECT}"

exit 1 
}

build_lx2160acex7(){
	SOC_TYPE=$1
	BOOT_MODE=$2
	RCW_REPO=$3
	ATF_REPO=$4
	EDK2_REPO=$5
	EDK2PLAT_REPO=$6
	BUILD_TYPE=$7
	RCW_BRANCH=$8
	ATF_BRANCH=$9
	EDK2_BRANCH=${10}
	EDK2PLAT_BRANCH=${11}
	RCW_TAG=${12}
	ATF_TAG=${13}
	EDK2_TAG=${14}
	EDK2PLAT_TAG=${15}
	DDRSPEED=${16}
	SERDES_CONFIG=${17}
		
	echo "                                        "
	echo "**********FIRMWARE BUILD CONFIG*********"
	echo "NOTE: 'x' denotes default tags taken from default git respository submodules .	"
	echo "https://github.com/SolidRun/lx2160a_build/tree/LSDK-19.09-sr-uefi "
	echo "                                        "
	echo "SOC              : ${SOC_TYPE}"	
	echo "PLATFORM         : ${PLATFORM}"	
	echo "BOOT MODE        : ${BOOT_MODE}"	
	echo "UEFI BUILD MODE  : ${BUILD_TYPE}"	
	echo "RCW REPO         : ${RCW_REPO}"	
	echo "RCW BRANCH       : ${RCW_BRANCH}"	
	echo "RCW TAG          : ${RCW_TAG}"	
	echo "ATF REPO         : ${ATF_REPO}"	
	echo "ATF BRANCH       : ${ATF_BRANCH}"	
	echo "ATF TAG          : ${ATF_TAG}"	
	echo "EDK2 REPO        : ${EDK2_REPO}"	
	echo "EDK2 BRANCH      : ${EDK2_BRANCH}"	
	echo "EDK2 TAG         : ${EDK2_TAG}"	
	echo "EDK2-PLAT REPO   : ${EDK2PLAT_REPO}"	
	echo "EDK2-PLAT BRANCH : ${EDK2PLAT_BRANCH}"	
	echo "EDK2-PLAT TAG    : ${EDK2PLAT_TAG}"	
	echo "SERDES           : ${SERDES_CONFIG}"	
	echo "DDR SPEED        : ${DDRSPEED}"	
	echo "****************************************"	


	if [ ! -d "$SOURCE_DIR/lx2160a_build" ];then git clone https://github.com/SolidRun/lx2160a_build.git $SOURCE_DIR/lx2160a_build --branch LSDK-19.09-sr-uefi ;fi
	cd $SOURCE_DIR/lx2160a_build
	git submodule init
	#git -c submodule."build/arm-trusted-firmware".update=none submodule update --init --recursive

	if [ "$ATF_REPO" != "x" ];then git clone $ATF_REPO $SOURCE_DIR/lx2160a_build/arm-trusted-firmware;else git submodule update --remote build/arm-trusted-firmware --progress; fi
	if [ "$EDK2_REPO" != "x" ];then git clone $EDK2_REPO $SOURCE_DIR/lx2160a_build/tianocore/edk2;else git submodule update --remote build/tianocore/edk2 --progress; fi
	if [ "$EDK2PLAT_REPO" != "x" ];then git clone $EDK2PLAT_REPO $SOURCE_DIR/lx2160a_build/tianocore/edk2-platforms;else git submodule update --remote build/tianocore/edk2-platforms --progress; fi
	
	git submodule update --remote build/mc-utils --progress
	git submodule update --remote build/qoriq-mc-binary --progress
	git submodule update --remote build/tianocore/edk2-non-osi --progress
	if [ "$RCW_REPO" != "x" ];then 
		git clone $RCW_REPO $SOURCE_DIR/lx2160a_build/rcw
	else 
		git submodule update --remote build/rcw --progress
		#sed -i '/SDHC2_DIR_PMUX/d' $SOURCE_DIR/lx2160a_build/build/rcw/lx2160acex7/configs/lx2160a_defaults.rcwi
	fi
	sudo BOOT=$BOOT_MODE BOOT_LOADER=uefi BOOTLOADER_ONLY=y DDR_SPEED=$RAMSPEED SERDES=$SERDES_CONFIG $SOURCE_DIR/lx2160a_build/runme.sh
	
	cp $SOURCE_DIR/lx2160a_build/build/arm-trusted-firmware/build/lx2160acex7/release/*.bin $SOURCE_DIR/lx2160a_build/build/arm-trusted-firmware/build/lx2160acex7/release/*.pbl $IMAGE_DIR/	

	
}

build_rdb_board(){
	SOC_TYPE=$1
	BOOT_MODE=$2
	RCW_REPO=$3
	ATF_REPO=$4
	EDK2_REPO=$5
	EDK2PLAT_REPO=$6
	BUILD_TYPE=$7
	RCW_BRANCH=$8
	ATF_BRANCH=$9
	EDK2_BRANCH=${10}
	EDK2PLAT_BRANCH=${11}
	RCW_TAG=${12}
	ATF_TAG=${13}
	EDK2_TAG=${14}
	EDK2PLAT_TAG=${15}
	RAM_SPEED=${16}
	SERDESCONFIG=${17}
	MTDEN=${18}
	REV=${19}
		
	echo "                                        "
	echo "**********FIRMWARE BUILD CONFIG*********"	
	echo "SOC              : ${SOC_TYPE}"	
	echo "PLATFORM         : ${PLATFORM}"	
	echo "BOOT MODE        : ${BOOT_MODE}"	
	if [[ "$PLATFORM" == "lx2160acex7" ]];then 
	echo "DDR SPEED        : ${RAM_SPEED}"	
	echo "SERDES CONFIG    : ${SERDESCONFIG}"	
	fi
	if [[ "$SOC_TYPE" == "LX2160" ]];then 
	echo "Silicon Revision : v${REV}"	
	fi	
	echo "UEFI BUILD MODE  : ${BUILD_TYPE}"	
	echo "MTD enabled Linux  : ${MTDEN}"	
        echo "RCW REPO         : ${RCW_REPO}"	
	if [[ -z $RCW_TAG ]];then
	echo "RCW BRANCH       : ${RCW_BRANCH}"	
        else
	echo "RCW TAG          : ${RCW_TAG}"
        fi	
	echo "ATF REPO         : ${ATF_REPO}"	
	if [[ -z $ATF_TAG ]];then
	echo "ATF BRANCH       : ${ATF_BRANCH}"	
        else
	echo "ATF TAG          : ${ATF_TAG}"	
        fi	
	echo "EDK2 REPO        : ${EDK2_REPO}"	
	if [[ -z $EDK2_TAG ]];then
	echo "EDK2 BRANCH      : ${EDK2_BRANCH}"	
        else
	echo "EDK2 TAG         : ${EDK2_TAG}"	
        fi	
	echo "EDK2-PLAT REPO   : ${EDK2PLAT_REPO}"	
	if [[ -z $EDK2PLAT_TAG ]];then
	echo "EDK2-PLAT BRANCH : ${EDK2PLAT_BRANCH}"	
        else
	echo "EDK2-PLAT TAG    : ${EDK2PLAT_TAG}"	
        fi	
	echo "****************************************"	
	echo "                                        "
	if [ ! -d "$SOURCE_DIR/edk2" ];then fetch_resource "edk2" "$EDK2_REPO" "$EDK2_BRANCH" "$EDK2_TAG"; fi
	if [ ! -d "$SOURCE_DIR/edk2/edk2-platforms" ];then fetch_resource "edk2-platforms" "$EDK2PLAT_REPO" "$EDK2PLAT_BRANCH" "$EDK2PLAT_TAG"; fi
	mv $SOURCE_DIR/edk2-platforms $SOURCE_DIR/edk2/edk2-platforms
	if [ ! -d "$SOURCE_DIR/atf" ];then fetch_resource "atf" "$ATF_REPO" "$ATF_BRANCH" "$ATF_TAG"; fi
        if [ ! -d "$SOURCE_DIR/rcw" ];then fetch_resource "rcw" "$RCW_REPO" "$RCW_BRANCH" "$RCW_TAG"; fi

        echo "cloning of repositories done!"
        echo " "
        echo "setting up toolchain.."
        if [ ! -d "$SOURCE_DIR/$TOOLCHAIN" ];then fetch_resource "toolchain"; fi
	
	cd $SOURCE_DIR
        export ARCH=arm64
        export CROSS_COMPILE="$SOURCE_DIR/$TOOLCHAIN/bin/aarch64-linux-gnu-"

        echo "###########BUILDING RCW IMAGE #####################"
        cd $SOURCE_DIR/rcw
        if [[ "${SOC_TYPE}" == "LX2160" && "${PLATFORM}" == "lx2160ardb" && "$REV" == 2  ]];then
		cd lx2160ardb_rev2
	else
		cd $PLATFORM
	fi
	make clean 
	make 
        if [ $? -ne 0 ];then build_reporting 1 "RCW compilation"; fi
	echo "###################################################"
	
	source $SOURCE_DIR/edk2/edksetup.sh
	cd $SOURCE_DIR/edk2/
	git submodule update --init --progress
	cd $SOURCE_DIR/edk2/Conf
	rm $SOURCE_DIR/edk2/BuildEnv.sh $SOURCE_DIR/edk2/build_rule.txt $SOURCE_DIR/edk2/tools_def.txt $SOURCE_DIR/edk2/target.txt
		
	echo "###########BUILDING BASE TOOLS#####################"
	cd ..
	make -C BaseTools clean 
	make -C BaseTools 
	if [ $? -ne 0 ];then build_reporting 1 "building basetools"; fi		
	echo "###################################################"
		
	echo "###########BUILDING .FD IMAGE #####################"
	cd  $SOURCE_DIR/edk2/edk2-platforms/Platform/NXP
	source $SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/Env.cshrc
	if [ "$PLATFORM" == "ls1046ardb" ] || [ "$PLATFORM" == "lx2160ardb" ] ;then
		if [ "$PLATFORM" == "ls1046ardb" ];then 
			if grep -q "#define QSPI_STATUS" "$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LS1046aRdbPkg/AcpiTables/Platform.h"; then
				sed -i 's/#define QSPI_STATUS.*/#define QSPI_STATUS 0x03/' $SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LS1046aRdbPkg/AcpiTables/Platform.h 
			else
				echo "WARNING: QSPI DRIVER DISABLE SUPPORT NOT AVAILABLE"
				sleep 5
			fi
		else 
			if grep -q "#define FSPI_STATUS" "$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LX2160aRdbPkg/AcpiTables/Platform.h"; then
				sed -i 's/#define FSPI_STATUS.*/#define FSPI_STATUS 0x03/' $SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LX2160aRdbPkg/AcpiTables/Platform.h 
			else
				echo "WARNING: FSPI DRIVER DISABLE SUPPORT NOT AVAILABLE"
				sleep 5
			fi
		fi

		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE RDB $BUILD_TYPE clean 
		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE RDB $BUILD_TYPE 
	elif [ "$PLATFORM" == "ls1046afrwy" ];then 
		if [[ "$MTDEN" == "yes" ]] ;then
			if grep -q "#define QSPI_STATUS" "$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LS1046aFrwyPkg/AcpiTables/Platform.h"; then
				sed -i 's/#define QSPI_STATUS.*/#define QSPI_STATUS 0x03/' $SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/LS1046aFrwyPkg/AcpiTables/Platform.h
			else
				echo "WARNING: QSPI DRIVER DISABLE SUPPORT NOT AVAILABLE"
				sleep 5
			fi
		fi
		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE FRWY $BUILD_TYPE clean 
		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE FRWY $BUILD_TYPE 
	elif [ "$PLATFORM" == "lx2160acex7" ];then 
		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE CEX7 $BUILD_TYPE clean 
		$SOURCE_DIR/edk2/edk2-platforms/Platform/NXP/build.sh $SOC_TYPE CEX7 $BUILD_TYPE 
	fi
	if [ $? -ne 0 ];then build_reporting 1 "building .FD (uefi) image"; fi		
	echo "###################################################"
	
	echo "###################################################"
	echo "##################COMPILING ATF, PBL and FIP ########################"
	
	
	cd $SOURCE_DIR/atf/
	if [[ "$PLATFORM" == "ls1046ardb" ]];then
		cp $SOURCE_DIR/rcw/$PLATFORM/RR_FFSSPPPN_1133_5506/rcw_1600_qspiboot.bin $SOURCE_DIR/atf	 #copy rcw to ATF dir
		cp $SOURCE_DIR/rcw/$PLATFORM/RR_FFSSPPPN_1133_5506/rcw_1600_qspiboot.bin $IMAGE_DIR/             		#copy rcw to $IMAGE_DIR
		make PLAT=$PLATFORM clean
		make PLAT=$PLATFORM bl2 pbl BOOT_MODE=$BOOT_MODE RCW=rcw_1600_qspiboot.bin
		if [ $? -ne 0 ];then build_reporting 1 " .pbl compilation"; fi	
		make PLAT=$PLATFORM fip BL33=$SOURCE_DIR/edk2/Build/LS1046aRdbPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LS1046ARDB_EFI.fd
		if [ $? -ne 0 ];then build_reporting 1 " .fip compilation"; fi	

		cp $SOURCE_DIR/edk2/Build/LS1046aRdbPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LS1046ARDB_EFI.fd $IMAGE_DIR/ #copy .fd iamge

	elif [[ "$PLATFORM" == "lx2160ardb" ]];then 
		if [[ "$REV" == 2  ]];then
			cp $SOURCE_DIR/rcw/lx2160ardb_rev2/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin $SOURCE_DIR/atf            #copy rcw to ATF dir
			cp $SOURCE_DIR/rcw/lx2160ardb_rev2/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin $IMAGE_DIR/             #copy rcw imagedd
		else
			cp $SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin $SOURCE_DIR/atf            #copy rcw to ATF dir
			cp $SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin $IMAGE_DIR/             #copy rcw imagedd
		fi
        make PLAT=$PLATFORM clean
		if [[ "$REV" == 2  ]];then
			make PLAT=$PLATFORM bl2 pbl BOOT_MODE=$BOOT_MODE RCW=$SOURCE_DIR/rcw/lx2160ardb_rev2/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin
		else
			make PLAT=$PLATFORM bl2 pbl BOOT_MODE=$BOOT_MODE RCW=$SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_2900_19_5_2.bin
		fi
		if [ $? -ne 0 ];then build_reporting 1 " .pbl compilation"; fi	
            make PLAT=$PLATFORM fip BL33=$SOURCE_DIR/edk2/Build/LX2160aRdbPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LX2160ARDB_EFI.fd
		if [ $? -ne 0 ];then build_reporting 1 " .fip compilation"; fi	
			
		cp $SOURCE_DIR/edk2/Build/LX2160aRdbPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LX2160ARDB_EFI.fd $IMAGE_DIR/ 		#copy .fd iamge
		
	elif [[ "$PLATFORM" == "ls1046afrwy" ]];then
		cp $SOURCE_DIR/rcw/$PLATFORM/NN_NNQNNPNP_3040_0506/rcw_1600_${BOOT_MODE}boot.bin $SOURCE_DIR/atf            #copy rcw to ATF dir
  		cp $SOURCE_DIR/rcw/$PLATFORM/NN_NNQNNPNP_3040_0506/rcw_1600_${BOOT_MODE}boot.bin $IMAGE_DIR/             #copy rcw imagedd
        make PLAT=$PLATFORM clean
        make PLAT=$PLATFORM bl2 pbl BOOT_MODE=$BOOT_MODE RCW=$SOURCE_DIR/rcw/$PLATFORM/NN_NNQNNPNP_3040_0506/rcw_1600_${BOOT_MODE}boot.bin
		if [ $? -ne 0 ];then build_reporting 1 " .pbl compilation"; fi	
            make PLAT=$PLATFORM fip BL33=$SOURCE_DIR/edk2/Build/LS1046aFrwyPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LS1046AFRWY_EFI.fd
		if [ $? -ne 0 ];then build_reporting 1 " .fip compilation"; fi

		cp $SOURCE_DIR/edk2/Build/LS1046aFrwyPkg/${BUILD_TYPE}_${GCC_STRING}/FV/LS1046AFRWY_EFI.fd $IMAGE_DIR/ 		#copy .fd iamge	

	elif [[ "$PLATFORM" == "lx2160acex7" ]];then
		cp $SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_${RAM_SPEED}_${SERDESCONFIG}_${BOOT_MODE}.bin $SOURCE_DIR/atf            #copy rcw to ATF dir
  		cp $SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_${RAM_SPEED}_${SERDESCONFIG}_${BOOT_MODE}.bin $IMAGE_DIR/             #copy rcw imagedd
        make PLAT=$PLATFORM clean
        make PLAT=$PLATFORM bl2 pbl BOOT_MODE=$BOOT_MODE RCW=$SOURCE_DIR/rcw/$PLATFORM/XGGFF_PP_HHHH_RR_19_5_2/rcw_2000_700_${RAM_SPEED}_${SERDESCONFIG}_${BOOT_MODE}.bin
		if [ $? -ne 0 ];then build_reporting 1 " .pbl compilation"; fi	
            make PLAT=$PLATFORM fip BL33=$SOURCE_DIR/edk2/Build/LX2160aCex7Pkg/${BUILD_TYPE}_${GCC_STRING}/FV/LX2160ACEX7_EFI.fd
		if [ $? -ne 0 ];then build_reporting 1 " .fip compilation"; fi

		cp $SOURCE_DIR/edk2/Build/LX2160aCex7Pkg/${BUILD_TYPE}_${GCC_STRING}/FV/LX2160ACEX7_EFI.fd $IMAGE_DIR/ 		#copy .fd iamge	

	fi
		rm -rf $RESOURCE_DIR		
		cp $SOURCE_DIR/atf/build/$PLATFORM/release/*.bin $SOURCE_DIR/atf/build/$PLATFORM/release/*.pbl $IMAGE_DIR/
}

flex_builder(){
	if [ ! -f "$BUILDSERVER_DIR/${FLEXBUILD_VER}.tgz" ];then echo "FLEXBUILDER not found. Exiting..";build_reporting 1 " linux build" ; fi
	if [ ! -d "$FLEXBUILD_DIR" ];then tar -xf "$BUILDSERVER_DIR/${FLEXBUILD_VER}.tgz" -C $SOURCE_DIR; fi
	cd $FLEXBUILD_DIR
	sed -i "1972s+.*+#+" $FLEXBUILD_DIR/tools/flex-builder
	sed -i "1973s+.*+#+" $FLEXBUILD_DIR/tools/flex-builder
	sed -i "1974s+.*+#+" $FLEXBUILD_DIR/tools/flex-builder
	sed -i "1975s+.*+#+" $FLEXBUILD_DIR/tools/flex-builder
	sed -i "1977s+.*+#+" $FLEXBUILD_DIR/tools/flex-builder
	sed -i "194s+.*+linux_repo_url=${LINUX_REPO}+" $FLEXBUILD_DIR/configs/build_lsdk.cfg
	sed -i "195s+.*+linux_repo_tag=${LINUX_TAG}+" $FLEXBUILD_DIR/configs/build_lsdk.cfg
	
	source setup.env 
	
	if [ $1 == "linux" ];then
		echo "***********BUILDING LINUX********"
		echo "     				"
		if [[ -z "$LINUX_REPO" ]];then LINUX_REPO="https://github.com/ossdev07/linux.git" ; fi
		if [[ -z "$LINUX_BRANCH" ]];then LINUX_BRANCH="PS_Linux_Stable_v5.6-Release"; fi
		if [[ -z "$LINUX_TAG" ]];then LINUX_TAG="LS1046a_v1.0"; fi

		echo "LINUX REPO     : ${LINUX_REPO}"	
		echo "LINUX BRANCH   : ${LINUX_BRANCH}"	
		echo "LINUX TAG      : ${LINUX_TAG}"	
	
        	fetch_resource "linux" "$LINUX_REPO" "$LINUX_BRANCH" "$LINUX_TAG"
		mv $SOURCE_DIR/linux  $FLEXBUILD_DIR/packages/linux/.
		
		if [[ ! -z "$LINUX_TAG" ]];then
			cd $FLEXBUILD_DIR/packages/linux/linux
			git checkout -b "$LINUX_TAG"
		fi
		cd $FLEXBUILD_DIR	
		flex-builder -c linux -a arm64 -m ls1046ardb -f build_lsdk.cfg $LINUX_OPTIONS
		cp $FLEXBUILD_DIR/build/linux/kernel/arm64/LS/Image $IMAGE_DIR
	elif [ $1 == "boot-partition" ];then
		flex-builder -i mkboot -a arm64 $BOOT_PARTITION_OPTIONS
	elif [ $1 == "rfs" ];then
		flex-builder -i mkrfs $RFS_OPTIONS
	fi
}

fetch_resource(){
	if [ $1 != "toolchain" ];then
		RESOURCE_TYPE=$1
		RESOURCE_REPO=$2
		RESOURCE_BRANCH=$3
		RESOURCE_TAG=$4
	
		if [ ! -d "$RESOURCE_DIR/$RESOURCE_TYPE" ];then
			git clone $RESOURCE_REPO --branch $RESOURCE_BRANCH $RESOURCE_DIR/$RESOURCE_TYPE;
			if [[ ! -z "$RESOURCE_TAG" ]];then cd $RESOURCE_DIR/$RESOURCE_TYPE;git fetch --all --tags;git checkout $RESOURCE_TAG; fi
		elif [ -d "$RESOURCE_DIR/$RESOURCE_TYPE" ];then #check correct directory
			cd $RESOURCE_DIR/$RESOURCE_TYPE
			if [ "$(git config --get remote.origin.url)" == "$RESOURCE_REPO" ];then #check correct repo
				git stash
				git fetch --all --tags
				git reset --hard origin/$RESOURCE_BRANCH
				git checkout $RESOURCE_BRANCH
				if [[ ! -z "$RESOURCE_TAG" ]];then git checkout $RESOURCE_TAG; fi
			else #if repo dosent match user's repo
				git clone $RESOURCE_REPO --branch $RESOURCE_BRANCH $RESOURCE_DIR/$RESOURCE_TYPE;
				if [[ ! -z "$RESOURCE_TAG" ]];then cd $RESOURCE_DIR/$RESOURCE_TYPE;git fetch --all --tags;git checkout $RESOURCE_TAG; fi
			fi	
		fi
		if [ $? -ne 0 ];then build_reporting 1 "fetching source code from git"; fi	
		echo "copying $RESOURCE_TYPE source to $SOURCE_DIR ...."
		cp -rf $RESOURCE_DIR/$RESOURCE_TYPE $SOURCE_DIR/.
	elif [ $1 == "toolchain" ];then
        	if [ ! -f "$RESOURCE_DIR/${TOOLCHAIN}.tar.xz" ];then wget $TOOLCHAIN_URL -P $RESOURCE_DIR; fi
        	tar -xf "$RESOURCE_DIR/${TOOLCHAIN}.tar.xz" -C $SOURCE_DIR/.
	else
		 build_reporting 1 "invalid resource param"
	fi		
}

check_update(){

echo "CHECKING IF UPDATE FOR BUILDSERVER AVAILABLE..."
    if [[ -n $(git diff origin/master) ]];then
        echo "Found a new version,updating..."
        echo "IMPORTANT: RE-RUN THE SCRIPT WITH ARGUMENTS AFTER UPDATE IS COMLETE"
        git pull --force
        git checkout master
        git pull --force
        echo "Updated succesfully, please re-run the script"
        exit 1
    else
    	echo "Already the latest version."
    fi

}

if [[ -z "$BUILD_MODE" ]];then BUILD_MODE="RELEASE";echo "BUILD MODE not spcefied, taking default: $BUILD_MODE"; fi

if [[ -z "$BUILD_NAME" ]];then
	BUILD_NAME="$1_$(date +"%Y_%m_%d_%h_%s")"
	BUILD_NAME="${BUILD_MODE}_${BUILD_NAME}"
fi	

PLATFORM=$1
SKIP_FIRMWARE=$2
BUILDSERVER_DIR=$PWD
SOURCE_DIR=$BUILDSERVER_DIR/$BUILD_NAME/source_code
FLEXBUILD_VER=flexbuild_lsdk2004
FLEXBUILD_DIR=$SOURCE_DIR/$FLEXBUILD_VER
IMAGE_DIR=$BUILDSERVER_DIR/$BUILD_NAME/build_images
LOGS_DIR=$BUILDSERVER_DIR/$BUILD_NAME/logs
RESOURCE_DIR=$BUILDSERVER_DIR/common_source


#if [[ -z "$USER_EMAIL" ]];then echo "PLEASE ENTER USER EMAIL ID. exiting...";exit 1; fi

check_update
if [[ ! -d $BUILDSERVER_DIR/$BUILD_NAME ]];then mkdir $BUILD_NAME $SOURCE_DIR $IMAGE_DIR $LOGS_DIR; fi
if [[ ! -d $RESOURCE_DIR ]];then mkdir $RESOURCE_DIR; fi

if [[ -z "$GCCVER" ]];then 
	echo "GCCVER not specified, taking default, GCC5";
	GCC_STRING="GCC5"
	TOOLCHAIN=gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu
	TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/${TOOLCHAIN}.tar.xz"
elif [[ "$GCCVER" == "4" ]];then
	echo "GCCVER 4 specified, taking GCC4.9";
	GCC_STRING="GCC49"
        TOOLCHAIN=gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu
	TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/aarch64-linux-gnu/${TOOLCHAIN}.tar.xz"
else
	echo "GCC version other than 4 and 5 not supported. exiting..";
	build_reporting 1 "unsupported GCCVER"
fi

if [[ "$PLATFORM" == "lx2160acex7" ]];then
    echo "Building Images for cex7 board"
    if [[ -z "$BUILD_MODE" ]];then BUILD_MODE="RELEASE"; fi
    if [[ -z "$BOOT_MODE" ]];then BOOT_MODE="sd"; fi                             #deafult BOOT MODE
    if [[ -z "$RCW_REPO" ]];then RCW_REPO="https://github.com/ossdev07/rcw.git"; fi #default RCW repo
    if [[ -z "$RCW_BRANCH" ]];then RCW_BRANCH="UEFI_ACPI_SYSTEM_TESTING-CEX7_Porting"; fi #default RCW branch
    if [[ -z "$ATF_REPO" ]];then ATF_REPO="https://github.com/ossdev07/atf.git"; fi #default ATF repo
    if [[ -z "$ATF_BRANCH" ]];then ATF_BRANCH="UEFI_ACPI_SYSTEM_TESTING-CEX7_Porting"; fi #default ATF branch
    if [[ -z "$EDK2_REPO" ]];then EDK2_REPO="https://github.com/ossdev07/edk2.git"; fi #faultEDK2repo
    if [[ -z "$EDK2_BRANCH" ]];then EDK2_BRANCH="UEFI_ACPI_SYSTEM_TESTING-CEX7_Porting"; fi #faultEDK2BRANCH
    if [[ -z "$EDK2PLAT_REPO" ]];then EDK2PLAT_REPO="https://github.com/ossdev07/edk2-platforms.git"; fi
    if [[ -z "$EDK2PLAT_BRANCH" ]];then EDK2PLAT_BRANCH="UEFI_ACPI_SYSTEM_TESTING-CEX7_Porting"; fi
    if [[ -z "$RAMSPEED" ]];then RAMSPEED="3200"; fi	                #default RAM SPEED
    if [[ -z "$SERDES_CONFIG" ]];then SERDES_CONFIG="8_5_2"; fi		#default SERDES CONFIG
    if [[ -z "$MTDDRIVER_LINUX_ENABLE" ]];then MTDDRIVER_LINUX_ENABLE="NO"; fi
    if [[ -z "$SILICON_REV" ]];then SILICON_REV=1; fi
    build_rdb_board LX2160 $BOOT_MODE "$RCW_REPO" "$ATF_REPO" "$EDK2_REPO" "$EDK2PLAT_REPO" $BUILD_MODE "$RCW_BRANCH" "$ATF_BRANCH" "$EDK2_BRANCH" "$EDK2PLAT_BRANCH" "$RCW_TAG" "$ATF_TAG" "$EDK2_TAG" "$EDK2PLAT_TAG" "$RAMSPEED" "$SERDES_CONFIG" "$MTDDRIVER_LINUX_ENABLE" "$SILICON_REV"| tee -a "$LOGS_DIR/build_log.txt"

elif [[ "$PLATFORM" == "lx2160ardb" ]];then
    echo "Building Images for LX2160ARDB board"
    if [[ -z "$BUILD_MODE" ]];then BUILD_MODE="RELEASE"; fi
    if [[ -z "$BOOT_MODE" ]];then BOOT_MODE="flexspi_nor"; fi                             #deafult BOOT MODE
    if [[ -z "$RCW_REPO" ]];then RCW_REPO="https://github.com/ossdev07/rcw.git"; fi #default RCW repo
    if [[ -z "$RCW_BRANCH" ]];then RCW_BRANCH="master"; fi #default RCW branch
    if [[ -z "$ATF_REPO" ]];then ATF_REPO="https://github.com/ossdev07/atf.git"; fi #default ATF repo
    if [[ -z "$ATF_BRANCH" ]];then ATF_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #default ATF branch
    if [[ -z "$EDK2_REPO" ]];then EDK2_REPO="https://github.com/ossdev07/edk2.git"; fi #faultEDK2repo
    if [[ -z "$EDK2_BRANCH" ]];then EDK2_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #faultEDK2BRANCH
    if [[ -z "$EDK2PLAT_REPO" ]];then EDK2PLAT_REPO="https://github.com/ossdev07/edk2-platforms.git"; fi
    if [[ -z "$EDK2PLAT_BRANCH" ]];then EDK2PLAT_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi
    if [[ -z "$MTDDRIVER_LINUX_ENABLE" ]];then MTDDRIVER_LINUX_ENABLE="NO"; fi
    if [[ -z "$SILICON_REV" ]];then SILICON_REV=1; fi
    build_rdb_board LX2160 $BOOT_MODE "$RCW_REPO" "$ATF_REPO" "$EDK2_REPO" "$EDK2PLAT_REPO" $BUILD_MODE "$RCW_BRANCH" "$ATF_BRANCH" "$EDK2_BRANCH" "$EDK2PLAT_BRANCH" "$RCW_TAG" "$ATF_TAG" "$EDK2_TAG" "$EDK2PLAT_TAG" "" "" "$MTDDRIVER_LINUX_ENABLE" "$SILICON_REV"| tee -a "$LOGS_DIR/build_log.txt"

elif [[ "$PLATFORM" == "ls1046ardb" ]];then
    echo "Building Images for LS1046ARDB board"
    if [[ -z "$BUILD_MODE" ]];then BUILD_MODE="RELEASE"; fi
    if [[ -z "$BOOT_MODE" ]];then BOOT_MODE="qspi"; fi                             #deafult BOOT MODE
    if [[ -z "$RCW_REPO" ]];then RCW_REPO="https://github.com/ossdev07/rcw.git"; fi #default RCW repo
    if [[ -z "$RCW_BRANCH" ]];then RCW_BRANCH="master"; fi #default RCW branch
    if [[ -z "$ATF_REPO" ]];then ATF_REPO="https://github.com/ossdev07/atf.git"; fi #default ATF repo
    if [[ -z "$ATF_BRANCH" ]];then ATF_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #default ATF branch
    if [[ -z "$EDK2_REPO" ]];then EDK2_REPO="https://github.com/ossdev07/edk2.git"; fi #faultEDK2repo
    if [[ -z "$EDK2_BRANCH" ]];then EDK2_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #faultEDK2BRANCH
    if [[ -z "$EDK2PLAT_REPO" ]];then EDK2PLAT_REPO="https://github.com/ossdev07/edk2-platforms.git"; fi
    if [[ -z "$EDK2PLAT_BRANCH" ]];then EDK2PLAT_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi
    if [[ -z "$MTDDRIVER_LINUX_ENABLE" ]];then MTDDRIVER_LINUX_ENABLE="NO"; fi
    build_rdb_board LS1046 $BOOT_MODE "$RCW_REPO" "$ATF_REPO" "$EDK2_REPO" "$EDK2PLAT_REPO" $BUILD_MODE "$RCW_BRANCH" "$ATF_BRANCH" "$EDK2_BRANCH" "$EDK2PLAT_BRANCH" "$RCW_TAG" "$ATF_TAG" "$EDK2_TAG" "$EDK2PLAT_TAG" "" "" "$MTDDRIVER_LINUX_ENABLE"| tee -a "$LOGS_DIR/build_log.txt"

elif [[ "$PLATFORM" == "ls1046afrwy" ]];then
    echo "Building Images for LS1046ARFWY board"
    if [[ -z "$BUILD_MODE" ]];then BUILD_MODE="RELEASE"; fi
    if [[ -z "$BOOT_MODE" ]];then BOOT_MODE="qspi"; fi                             #deafult BOOT MODE
    if [[ -z "$RCW_REPO" ]];then RCW_REPO="https://github.com/ossdev07/rcw.git"; fi #default RCW repo
    if [[ -z "$RCW_BRANCH" ]];then RCW_BRANCH="master";echo "RCW branch not spcefied, taking default: $RCW_BRANCH"; fi #default RCW branch
    if [[ -z "$ATF_REPO" ]];then ATF_REPO="https://github.com/ossdev07/atf.git"; fi #default ATF repo
    if [[ -z "$ATF_BRANCH" ]];then ATF_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #default ATF branch
    if [[ -z "$EDK2_REPO" ]];then EDK2_REPO="https://github.com/ossdev07/edk2.git"; fi #faultEDK2repo
    if [[ -z "$EDK2_BRANCH" ]];then EDK2_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi #faultEDK2BRANCH
    if [[ -z "$EDK2PLAT_REPO" ]];then EDK2PLAT_REPO="https://github.com/ossdev07/edk2-platforms.git"; fi
    if [[ -z "$EDK2PLAT_BRANCH" ]];then EDK2PLAT_BRANCH="UEFI_ACPI_EAR1-PS-Devel"; fi
    if [[ -z "$MTDDRIVER_LINUX_ENABLE" ]];then MTDDRIVER_LINUX_ENABLE="NO"; fi
    build_rdb_board LS1046 $BOOT_MODE "$RCW_REPO" "$ATF_REPO" "$EDK2_REPO" "$EDK2PLAT_REPO" $BUILD_MODE "$RCW_BRANCH" "$ATF_BRANCH" "$EDK2_BRANCH" "$EDK2PLAT_BRANCH" "$RCW_TAG" "$ATF_TAG" "$EDK2_TAG" "$EDK2PLAT_TAG" "" "" "$MTDDRIVER_LINUX_ENABLE"| tee -a "$LOGS_DIR/build_log.txt"
fi


if [[ ! -z "$LINUX" ]];then 
	flex_builder "linux"
	if [ $? -ne 0 ];then build_reporting 1 " linux compilation";else cp $FLEXBUILD_DIR/build/linux/linux/arm64/LS $IMAGE_DIR/ ;fi	
fi	

if [[ ! -z "$RFS" ]];then
	flex_builder "rfs"
	if [ $? -ne 0 ];then build_reporting 1 " RFS compilation";else cp -rf $FLEXBUILD_DIR/build/rfs/* $IMAGE_DIR/ ;fi	
fi

build_reporting 0
