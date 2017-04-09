#! /bin/sh

ulimit -c 100000000

. ../../config

PHYSKDIR=../../../physkeyb/src
PKGNAME="${HACKNAME}"
PKGVER="${VERSION}"

#cp -f $PHYSKDIR/physkeyb.jar $PHYSKDIR/*.kbd ./

KINDLE_MODELS="k3g k3w k3gb"
for model in ${KINDLE_MODELS} ; do
	# Prepare our files for this specific kindle model...
	ARCH=${PKGNAME}_${PKGVER}_${model}

	# Build install update
	./kindletool create ota -d ${model} install.sh bcel-5.2.jar K3Translator.jar loc-bind loc-init msp_prefs translation.jar ui_loc.tar.gz physkeyb.jar kindle.kbd bulgarian.kbd update_${ARCH}_install.bin

	# Build uninstall update
	./kindletool create ota -d ${model} uninstall.sh update_${ARCH}_uninstall.bin
done

