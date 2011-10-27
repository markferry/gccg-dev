# Makefile for gccg-mythos packages
#
#
CLIENT_NAME:=gccg-mythos
CLIENT_VERSION:=0.2.4
CLIENT_XML:=<module name=\"mythos\" version=\"${CLIENT_VERSION}\"></module>
CLIENT_PACKAGE:=${CLIENT_NAME}-${CLIENT_VERSION}.tar

DATA_NAME:=gccg-mythos-data
DATA_VERSION:=11072900
DATA_XML:=<module name=\"mythos-data\" version=\"${DATA_VERSION}\"></module>
DATA_PACKAGE:=${DATA_NAME}-${DATA_VERSION}.tar

GRAPHICS_NAME:=gccg-mythos-graphics
GRAPHICS_VERSION:=${DATA_VERSION}
GRAPHICS_XML:=<module name=\"mythos-graphics\" version=\"${GRAPHICS_VERSION}\"></module>
GRAPHICS_PACKAGE:=${GRAPHICS_NAME}-${GRAPHICS_VERSION}.tar

PKG_PATH:=packages
SITE_PATH:=site/markferry.net/gccg
SITE_XML:=${SITE_PATH}/available.xml

AVAILABLE_XML="<modules>\n\t<source url=\"http://gccg.sourceforge.net/modules/\"/>\n\t${CLIENT_XML}\n\t${DATA_XML}\n\t${GRAPHICS_XML}\n</modules>"

# core/ files included in mythos-client package
CLIENT_FILES=decks/Mythos graphics/Mythos scripts/Mythos* xml/mythos.xml xml/Mythos
SERVER_FILES=games.dat
# mythos/ files included in mythos-data package
DATA_FILES=xml/Mythos
# mythos/ files included in mythos-graphics package
GRAPHICS_FILES=graphics/Mythos

SSH_PATH=yuggoth-git:~/public_html/
########################
all: dist

build-dirs:
	mkdir -p ${PKG_PATH}

client: build-dirs
	cd core && tar -cvf ../${PKG_PATH}/${CLIENT_PACKAGE} ${CLIENT_FILES} ${SERVER_FILES} \
	&& gzip -f --rsyncable ../${PKG_PATH}/${CLIENT_PACKAGE}

data: build-dirs
	cd mythos && tar -cvf ../${PKG_PATH}/${DATA_PACKAGE} ${DATA_FILES} \
	&& gzip -f --rsyncable ../${PKG_PATH}/${DATA_PACKAGE}

graphics: build-dirs
	cd mythos && tar -cvf ../${PKG_PATH}/${GRAPHICS_PACKAGE} ${GRAPHICS_FILES} \
	&& gzip -f --rsyncable ../${PKG_PATH}/${GRAPHICS_PACKAGE}

dist-dirs:
	rm -rf ${SITE_PATH}
	mkdir -p ${SITE_PATH}

available:
	echo ${AVAILABLE_XML} > ${SITE_XML}

dist: client data graphics dist-dirs available
	cp ${PKG_PATH}/${CLIENT_PACKAGE}.gz ${SITE_PATH}/
	cp ${PKG_PATH}/${DATA_PACKAGE}.gz ${SITE_PATH}/
	cp ${PKG_PATH}/${GRAPHICS_PACKAGE}.gz ${SITE_PATH}/

clean:
	rm -rf ${SITE_PATH}
	rm -f ${PKG_PATH}/${CLIENT_NAME}-*.tar.gz
	rm -f ${PKG_PATH}/${DATA_NAME}-*.tar.gz
	rm -f ${PKG_PATH}/${GRAPHICS_NAME}-*.tar.gz

web: dist
	rsync -av ${SITE_PATH} ${SSH_PATH}

