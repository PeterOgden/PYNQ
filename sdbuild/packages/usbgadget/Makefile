USB_SOURCEDIR := $(dir $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))
USB_WORKDIR := ${WORKDIR}/usbgadget

${USB_WORKDIR}: | ${WORKDIR}
	mkdir ${USB_WORKDIR}

${USB_WORKDIR}/staging: | ${USB_WORKDIR}
	mkdir ${USB_WORKDIR}/staging

${USB_WORKDIR}/fatfs: | ${USB_WORKDIR}/staging
	-rm -f ${USB_WORKDIR}/fatfs
	truncate --size 50M ${USB_WORKDIR}/fatfs
	mkfs -t fat -n "Ultra96" ${USB_WORKDIR}/fatfs
	sudo mount ${USB_WORKDIR}/fatfs ${USB_WORKDIR}/staging
	sudo cp -r ${USB_SOURCEDIR}/fatfs/* ${USB_WORKDIR}/staging
	sudo umount ${USB_WORKDIR}/staging

${STAGE}PACKAGE_BUILD += ${USB_WORKDIR}/fatfs

