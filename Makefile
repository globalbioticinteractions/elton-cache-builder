SHELL=/bin/bash
BUILD_DIR=$(PWD)/target
STAMP=$(BUILD_DIR)/.stamp

README:=static/README

ELTON_VERSION:=0.12.2
ELTON_URL:=https://github.com/globalbioticinteractions/elton/releases/download/$(ELTON_VERSION)/elton.jar
ELTON_JAR:=$(BUILD_DIR)/elton.jar
ELTON:=java -jar $(ELTON_JAR)

ELTON_DATA_DIR:=/var/cache/elton/datasets

ZENODO_UPLOAD_URL:=https://raw.githubusercontent.com/jhpoelen/zenodo-upload/master/zenodo_upload.sh
ZENODO_UPLOAD:=$(BUILD_DIR)/zenodo_upload.sh
ZENODO_DEPOSIT:=5639794

DIST_DIR:=$(PWD)/dist

CURL:=curl --silent -L

.PHONY: all clean update upload clone

all: upload

clean:
	rm -rf $(BUILD_DIR)/* $(DIST_DIR)/*

$(STAMP):
	mkdir -p $(BUILD_DIR) && touch $@

clone:
	tar cv $(ELTON_DATA_DIR)/$(ELTON_PACKAGE) | gzip > $(DIST_DIR)/elton-datasets.tar.gz
	cat $(DIST_DIR)/elton-datasets.tar.gz | sha256sum | tr -d ' ' | tr -d '-' > $(DIST_DIR)/elton-datasets.tar.gz.sha256

update: clone $(ELTON_JAR)
	mkdir -p $(DIST_DIR)
	$(ELTON) datasets --cache-dir=$(ELTON_DATA_DIR) $(ELTON_PACKAGE) > $(DIST_DIR)/elton-datasets.tsv
	cp $(ELTON_JAR) $(DIST_DIR)
	cp $(README) $(DIST_DIR)
	echo -e "\nIncluded datasets:\n" >> $(DIST_DIR)/README
	cat $(DIST_DIR)/elton-datasets.tsv | tail -n+2 >> $(DIST_DIR)/README

$(ELTON_JAR): $(STAMP)
	$(CURL) $(ELTON_URL) > $(ELTON_JAR)

$(ZENODO_UPLOAD): $(STAMP)
	$(CURL) $(ZENODO_UPLOAD_URL) >  $(ZENODO_UPLOAD)

upload: update $(ZENODO_UPLOAD)
	cd $(DIST_DIR) && ls -1 | xargs -L1 bash $(ZENODO_UPLOAD) $(ZENODO_DEPOSIT)
