# Makefile for gccg-mythos packages
#
#

# core/ files included in mythos client package
#  NOTE this is also built in core/xml/packages.xml
CLIENT_NAME:=gccg-mythos
CLIENT_VERSION:=0.3.2
CLIENT_XML:=<module name=\"mythos\" version=\"${CLIENT_VERSION}\"></module>
CLIENT_PACKAGE:=${CLIENT_NAME}-${CLIENT_VERSION}.tgz
CLIENT_FILES=Mythos Mythos.bat decks/Mythos graphics/Mythos scripts/Mythos* xml/mythos.xml xml/Mythos

SERVER_FILES=games.dat

# mythos/ files included in mythos-data package
DATA_NAME:=gccg-mythos-data
DATA_VERSION:=11072901
DATA_XML:=<module name=\"mythos-data\" version=\"${DATA_VERSION}\"></module>
DATA_PACKAGE:=${DATA_NAME}-${DATA_VERSION}.tgz
DATA_FILES=xml/Mythos

# mythos/ files included in mythos-graphics package
GRAPHICS_NAME:=gccg-mythos-graphics
GRAPHICS_VERSION:=${DATA_VERSION}
GRAPHICS_XML:=<module name=\"mythos-graphics\" version=\"${GRAPHICS_VERSION}\"></module>
GRAPHICS_PACKAGE:=${GRAPHICS_NAME}-${GRAPHICS_VERSION}.tgz
GRAPHICS_FILES=graphics/Mythos graphics/fonts/Mythos

PKG_PATH:=packages
SITE_PATH:=site/markferry.net/gccg
SITE_XML:=${SITE_PATH}/available.xml

AVAILABLE_XML="<modules>\n\t<source url=\"http://gccg.sourceforge.net/modules/\"/>\n\t${CLIENT_XML}\n\t${DATA_XML}\n\t${GRAPHICS_XML}\n</modules>"

SSH_PATH=yuggoth-git:~/public_html/
########################
all: dist

build-dirs:
	mkdir -p ${PKG_PATH}

client: build-dirs
	cd core && tar -cv ${CLIENT_FILES} ${SERVER_FILES} \
	           | gzip -f -c --rsyncable > ../${PKG_PATH}/${CLIENT_PACKAGE}

data: build-dirs
	cd mythos && tar -cv ${DATA_FILES} \
	           | gzip -f -c --rsyncable > ../${PKG_PATH}/${DATA_PACKAGE}

graphics: build-dirs
	cd mythos && tar -cv ${GRAPHICS_FILES} \
	           | gzip -f -c --rsyncable > ../${PKG_PATH}/${GRAPHICS_PACKAGE}

dist-dirs:
	mkdir -p ${SITE_PATH}

available: dist-dirs
	echo ${AVAILABLE_XML} > ${SITE_XML}

client-dist: client dist-dirs available
	cp ${PKG_PATH}/${CLIENT_PACKAGE} ${SITE_PATH}/

data-dist: data dist-dirs available
	cp ${PKG_PATH}/${DATA_PACKAGE} ${SITE_PATH}/

graphics-dist: graphics dist-dirs available
	cp ${PKG_PATH}/${GRAPHICS_PACKAGE} ${SITE_PATH}/

dist: client-dist data-dist graphics-dist dist-dirs available

clean:
	rm -f ${PKG_PATH}/${CLIENT_NAME}-*.tgz
	rm -f ${PKG_PATH}/${DATA_NAME}-*.tgz
	rm -f ${PKG_PATH}/${GRAPHICS_NAME}-*.tgz

web-clean:
	rm -rf ${SITE_PATH}

web: dist
	rsync -av ${SITE_PATH} ${SSH_PATH}

