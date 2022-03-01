##
# (c) 2021 - CloudopsWorks OÜ - https://docs.cloudops.works/
#
OS := $(shell uname)
PWD := $(shell pwd)
CURR := $(shell basename $(PWD))
VERFOUND := $(shell [ -f VERSION ] && echo 1 || echo 0)
RELEASE_VERSION :=
TARGET :=
CHART :=
PLATFORM :=

.PHONY: VERSION
.PHONY: version
.PHONY: module.tf

module.tf:
	@if [ ! -f $(TARGET)-module-version.tf ] ; then \
		echo "Module $(TARGET)-module-version.tf not found... copying from templates" ; \
		cp template-module-version.tf_template $(TARGET)-module-version.tf ; \
		cp template-module-blue.tf_template $(TARGET)-module-blue.tf ; \
		cp template-module-green.tf_template $(TARGET)-module-green.tf ; \
		cp template-deploy-blue.tf_template $(TARGET)-deploy-blue.tf ; \
		mkdir -p values/${TARGET}/ ; \
		touch values/$(TARGET)/.placeholder ; \
	else echo "Module $(TARGET)-module-version.tf found... all OK" ; \
	fi

version: VERSION module.tf
ifeq ($(OS),Darwin)
	sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-version.tf
	sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-blue.tf
	sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-green.tf
	sed -i "" -e "s/source_name[ \t]*=.*/source_name = \"$(CHART)\"/" $(TARGET)-module-version.tf
	sed -i "" -e "s/source_version[ \t]*=.*/source_version = \"$(RELEASE_VERSION)\"/" $(TARGET)-module-version.tf
	sed -i "" -e "s/release_name[ \t]*=.*/release_name = \"$(TARGET)\"/" $(TARGET)-module-version.tf
	sed -i "" -e "s/load_balancer_log_prefix[ \t]*=.*/load_balancer_log_prefix = \"$(TARGET)\"/" $(TARGET)-module-version.tf
	sed -i "" -e "s/load_balancer_alias[ \t]*=.*/load_balancer_alias = \"$(TARGET)\-ingress\"/" $(TARGET)-module-version.tf
	@if [ "$(PLATFORM)" != "" ] ; then \
		sed -i "" -e "s/SOLUTION_STACK/$(PLATFORM)/g" $(TARGET)-module-version.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-blue.tf ] ; then \
		sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-green.tf ] ; then \
		sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-both.tf ] ; then \
		sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
else ifeq ($(OS),Linux)
	sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-version.tf
	sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-blue.tf
	sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module-green.tf
	sed -i -e "s/source_name[ \t]*=.*/source_name = \"$(CHART)\"/" $(TARGET)-module-version.tf
	sed -i -e "s/source_version[ \t]*=.*/source_version = \"$(RELEASE_VERSION)\"/" $(TARGET)-module-version.tf
	sed -i -e "s/release_name[ \t]*=.*/release_name = \"$(TARGET)\"/" $(TARGET)-module-version.tf
	sed -i -e "s/load_balancer_log_prefix[ \t]*=.*/load_balancer_log_prefix = \"$(TARGET)\"/" $(TARGET)-module-version.tf
	sed -i -e "s/load_balancer_alias[ \t]*=.*/load_balancer_alias = \"$(TARGET)\-ingress\"/" $(TARGET)-module-version.tf
	@if [ "$(PLATFORM)" != "" ] ; then \
		sed -i -e "s/SOLUTION_STACK/$(PLATFORM)/g" $(TARGET)-module-version.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-blue.tf ] ; then \
		sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-green.tf ] ; then \
		sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
	@if [ -f $(TARGET)-deploy-both.tf ] ; then \
		sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-deploy-blue.tf ; \
	fi
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif

VERSION:
ifeq ($(VERFOUND),1)
	$(info Version File OK)
override RELEASE_VERSION := $(shell cat VERSION | grep VERSION | cut -f 2 -d "=")
override TARGET := $(shell cat VERSION | grep TARGET | cut -f 2 -d "=")
override CHART := $(shell cat VERSION | grep CHART | cut -f 2 -d "=")
override PLATFORM := $(shell cat VERSION | grep PLATFORM | cut -f 2 -d "=")
else
	$(error Hey $@ File not found)
endif

clean:
	rm -f VERSION

init-template:
	@if [ ! -f terraform.tfvars ] ; then \
		echo "Initial Variables terraform.tfvars not found... copying from template" ; \
		cp terraform.tfvars_template terraform.tfvars ; \
	else echo "Initial Variables terraform.tfvars found... all OK" ; \
	fi

init: init-template
ifeq ($(OS),Darwin)
	sed -i "" -e "s/default_bucket_prefix[ \t]*=.*/default_bucket_prefix = \"$(CURR)\"/" terraform.tfvars
else ifeq ($(OS),Linux)
	sed -i -e "s/default_bucket_prefix[ \t]*=.*/default_bucket_prefix = \"$(CURR)\"/" terraform.tfvars
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif
