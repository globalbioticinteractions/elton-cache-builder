SHELL=/bin/bash
BUILD_DIR=$(PWD)/target
STAMP=$(BUILD_DIR)/.stamp

README:=static/README

ELTON_VERSION:=0.12.2
ELTON_URL:=https://github.com/globalbioticinteractions/elton/releases/download/$(ELTON_VERSION)/elton.jar
ELTON_JAR:=$(BUILD_DIR)/elton.jar
ELTON:=java -jar $(ELTON_JAR)

ELTON_DATA_DIR:=/var/cache/elton/datasets

ELTON_PACKAGE:=globalbioticinteractions/template-dataset

PACKAGE_DIRS:=$(shell echo $(ELTON_PACKAGE) | sed 's+[ ]+ datasets/+g' | sed 's+^+datasets/+g')


ZENODO_UPLOAD_URL:=https://raw.githubusercontent.com/jhpoelen/zenodo-upload/master/zenodo_upload.sh
ZENODO_UPLOAD:=$(BUILD_DIR)/zenodo_upload.sh
ZENODO_DEPOSIT:=5711304

DIST_DIR:=$(PWD)/dist

CURL:=curl --silent -L

.PHONY: all clean update upload clone

all: upload

clean:
	rm -rf $(BUILD_DIR)/* $(DIST_DIR)/*

$(STAMP):
	mkdir -p $(BUILD_DIR) && touch $@

clone:
	mkdir -p $(DIST_DIR)
	echo $(PACKAGE_DIRS)
	cd $(ELTON_DATA_DIR) && cd .. && tar c $(PACKAGE_DIRS) | gzip > $(DIST_DIR)/elton-datasets.tar.gz
	cat $(DIST_DIR)/elton-datasets.tar.gz | sha256sum | tr -d ' ' | tr -d '-' > $(DIST_DIR)/elton-datasets.tar.gz.sha256

update: clone $(ELTON_JAR)
	mkdir -p $(DIST_DIR)
	$(ELTON) datasets --cache-dir=$(ELTON_DATA_DIR) $(ELTON_PACKAGE) > $(DIST_DIR)/elton-datasets.tsv
	cp $(ELTON_JAR) $(DIST_DIR)
	cp $(README) $(DIST_DIR)
	echo -e "\nIncluded datasets:\n" >> $(DIST_DIR)/README
	cat $(DIST_DIR)/elton-datasets.tsv | tail -n+2 >> $(DIST_DIR)/README
	echo -e "\nAssociated content ids:\n" >> $(DIST_DIR)/README
	cat $(DIST_DIR)/elton-datasets.tar.gz | gunzip | tar --list | grep -o -P "[a-f0-9]{64}" | sed 's+^+hash://sha256/+g' >> $(DIST_DIR)/README

$(ELTON_JAR): $(STAMP)
	$(CURL) $(ELTON_URL) > $(ELTON_JAR)

$(ZENODO_UPLOAD): $(STAMP)
	$(CURL) $(ZENODO_UPLOAD_URL) >  $(ZENODO_UPLOAD)

upload: update $(ZENODO_UPLOAD)
	cd $(DIST_DIR) && ls -1 | xargs -L1 bash $(ZENODO_UPLOAD) $(ZENODO_DEPOSIT)
