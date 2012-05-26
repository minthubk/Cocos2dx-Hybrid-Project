# set params
NDK_ROOT=/Volumes/Data/Programs/Tools/android-ndk-r7b

RUN_PATH=${PWD}
SCRIPT_PATH=`dirname ${0}`

if [[ ${SCRIPT_PATH:0:1} == "/" ]]
then 
	PROJECT_ROOT=${SCRIPT_PATH}/..
else
	PROJECT_ROOT=${RUN_PATH}/${SCRIPT_PATH}/..
fi

LIB_ROOT=$PROJECT_ROOT/libs
COCOS2DX_ROOT=$LIB_ROOT/cocos2d
GAME_ROOT=$PROJECT_ROOT
GAME_ANDROID_ROOT=$PROJECT_ROOT/android
RESOURCE_ROOT=$PROJECT_ROOT/Resources

echo "Run path: "${RUN_PATH}
echo "Script path "${SCRIPT_PATH}
echo "Project root: "${PROJECT_ROOT}
echo "Android root: "${GAME_ANDROID_ROOT}

buildexternalsfromsource=

usage(){
cat << EOF
usage: $0 [options]

Build C/C++ native code using Android NDK

OPTIONS:
   -s	Build externals from source
   -m 	Recreate Android.mk 
   -c 	Clean project to rebuild (remove obj and libs/armeabi folders)
   -h	This help
EOF
}

clean(){
	echo "Cleaning ..."
	rm -rf ${GAME_ANDROID_ROOT}/obj
	rm -rf ${GAME_ANDROID_ROOT}/libs/armeabi
	echo "Done"
}

ANDROID_MK=$GAME_ANDROID_ROOT/jni/Android.mk
# mkMaker would fail if you execute it outside its parent directory
mkMaker(){
	echo "Creating Android.mk ..."
	echo -e "# Auto generated\n" > $ANDROID_MK
	
	#LOCAL_PATH := $(call my-dir)
	#include $(CLEAR_VARS)
	#LOCAL_MODULE := game_shared
	#LOCAL_MODULE_FILENAME := libgame
	
	echo "LOCAL_PATH := \$(call my-dir)" >> $ANDROID_MK
	echo "include \$(CLEAR_VARS)" >> $ANDROID_MK
	echo "LOCAL_MODULE := game_shared" >> $ANDROID_MK
	echo "LOCAL_MODULE_FILENAME := libgame" >> $ANDROID_MK
	
	echo "" >> $ANDROID_MK
	echo "LOCAL_SRC_FILES := helloworld/main.cpp \\" >> $ANDROID_MK
	
	# List files
	#files=`(cd $GAME_ANDROID_ROOT/jni;  "./list.sh" ../../Classes )`
	#echo $files >> $MK_TMP
	(cd $GAME_ANDROID_ROOT/jni;  "./list.sh" ../../Classes >> $ANDROID_MK)
	
	#LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes                   
	#LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocosdenshion_static box2d_static        
	#include $(BUILD_SHARED_LIBRARY)
	#$(call import-module,CocosDenshion/android) $(call import-module,cocos2dx) $(call import-module,Box2D)

	echo "" >> $ANDROID_MK
	echo "LOCAL_C_INCLUDES := \$(LOCAL_PATH)/../../Classes" >> $ANDROID_MK
	echo "LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static cocosdenshion_static box2d_static" >> $ANDROID_MK
	echo "include \$(BUILD_SHARED_LIBRARY)" >> $ANDROID_MK
	echo "\$(call import-module,CocosDenshion/android) \$(call import-module,cocos2dx) \$(call import-module,Box2D)" >> $ANDROID_MK
	
	echo "Done"
}

ANDROID_MK_TMPL=$GAME_ANDROID_ROOT/Android.mk.tmpl
mkMaker1(){
	echo "Creating Android.mk ..."
	echo "# Auto generated" > $ANDROID_MK
	
	
	# List files
	#files=`(cd $GAME_ANDROID_ROOT/jni;  "./list.sh" ../../Classes )`
	#echo $files >> $MK_TMP
	files=`(cd $GAME_ANDROID_ROOT/jni;  "./list.sh" ../../Classes)`
	#echo $files
	#echo $files | sed -e "s/\\\/\\\\\\\/g" | sed -e "s/\./\\\./g" | sed -e "s/\//\\\\\//g" >> $ANDROID_MK
	echo $files | sed -e "s/\\\/\\\\\\\/g" | sed -e "s/\./\\\./g" | sed -e "s/\//\\\\\//g" 
	
	#cat $ANDROID_MK_TMPL | while read LINE
	#do
       #echo $LINE | sed -e "s/__LOCAL_SRC_FILES__/${files}/g"
	#done
		
	echo "Done"
}

while getopts shcm OPTION; do
	case "$OPTION" in
		s)
			echo "Build External From Source"
			buildexternalsfromsource=1
			;;
		h)
			usage
			exit 0
			;;
		c)	
			clean
			;;
			
		m)	
			mkMaker
			;;	
		
	esac
done

# make sure assets is exist
if [ -d $GAME_ANDROID_ROOT/assets ]; then
    rm -rf $GAME_ANDROID_ROOT/assets
fi

mkdir $GAME_ANDROID_ROOT/assets

# copy resources
for file in $RESOURCE_ROOT/*
do
    if [ -d $file ]; then
        cp -rf $file $GAME_ANDROID_ROOT/assets
    fi

    if [ -f $file ]; then
        cp $file $GAME_ANDROID_ROOT/assets
    fi
done

if [[ $buildexternalsfromsource ]]; then
    echo "Building external dependencies from source"
    $NDK_ROOT/ndk-build -C $GAME_ANDROID_ROOT \
        NDK_MODULE_PATH=${LIB_ROOT}:${LIB_ROOT}/cocos2dx/platform/third_party/android/source
else
    echo "Using prebuilt externals"
    $NDK_ROOT/ndk-build -C $GAME_ANDROID_ROOT \
        NDK_MODULE_PATH=${LIB_ROOT}:${LIB_ROOT}/cocos2dx/platform/third_party/android/prebuilt
fi



