#! /usr/bin/make -f
BUILDDIR=$(CURDIR)/../srpms-libs
RESULTDIR=$(CURDIR)/../rpms-libs
TLBUILDDIR=$(CURDIR)/../srpms
TLRESULTDIR=$(CURDIR)/../rpms

# Try to find Tuleap Version, if not set 1.0
VERSION=$(shell cat tuleap/stable/VERSION 2>/dev/null)
ifeq ($(strip $(VERSION)),)
        VERSION=1.0
endif

GITREPOS=\
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/cvs-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/mailman-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/php-mediawiki-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/viewvc-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/jpgraph-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-restler.git \
ssh://gitolite@tuleap.net/tuleap/deps/src/php53-restler.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/restler-api-explorer.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/htmlpurifier.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-zendframework.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/openfire-tuleap-plugins.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/forgeupgrade.git

TULEAP=ssh://gitolite@tuleap.net/tuleap/tuleap/stable.git

DEPS=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/documentation.git
EN=https://github.com/Enalean/tuleap-documentation-en.git
FR=https://github.com/Enalean/tuleap-documentation-fr.git


BUILD_DOC_CONTAINER=https://github.com/Enalean/docker-build-documentation.git
BUILD_ADMDOC_CONTAINER=https://github.com/Enalean/tuleap-admin-documentation.git


default: buildmodules buildtuleap copydoc
	@echo 'Done $@ $(VERSION)'

buildmodules: clonemodules extra buildsrpms buildrpms
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=forgeupgrade
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=viewvc-tuleap
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=jpgraph-tuleap
	@#createrepo $(RESULTDIR)/RPMS
	@echo 'Done $@'

buildtuleap: clonetuleap tlbuildsrpms tlbuildrpms
	@echo 'Done $@'

getmaster:
	cd tuleap/stable ; git checkout -f master ; 
	
getvers: getmaster
	@lastbranch=$(shell cd tuleap/stable ; basename $$(git branch -va | tail -1 | cut -d" " -f3)) ; \
	branch=$(shell cd tuleap/stable ; git branch | grep ^\* | cut -d" " -f2) ; \
	mv tools/rpm ../rpm.master ;\
	git branch -d $$lastbranch || true ; \
	git checkout -b $$lastbranch remotes/origin/$$lastbranch ; \
	mv tools/rpm tools/rpm.old ; mv ../rpm.master tools/rpm

tlbuildsrpms: cbayle/docker-tuleap-buildsrpms
	@echo "=== $@ ==="
	@[ -d $(TLBUILDDIR)/rhel6 ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/tuleap/stable:/tuleap \
		-v $(TLBUILDDIR):/srpms \
		cbayle/docker-tuleap-buildsrpms:1.0
	
tlbuildrpms: cbayle/docker-tuleap-buildrpms
	@echo "=== $@ ==="
	@[ -d $(TLRESULTDIR)/RPMS/noarch ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/tuleap/stable:/tuleap \
		-v $(TLBUILDDIR):/srpms \
		-v $(TLRESULTDIR):/tmp/build \
		cbayle/docker-tuleap-buildrpms /run.sh --folder=rhel6 --php=php

buildsrpms: cbayle/docker-tuleap-buildsrpms
	@echo "=== $@ ==="
	@[ -d $(BUILDDIR)/rhel6 ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
                -v $(CURDIR):/tuleap \
                -v $(BUILDDIR):/srpms \
                cbayle/docker-tuleap-buildsrpms:1.0

buildrpms: cbayle/docker-tuleap-buildrpms
	@echo "=== $@ ==="
	@[ -d $(RESULTDIR)/RPMS/noarch ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(BUILDDIR)/:/srpms/ \
		-v $(RESULTDIR)/:/tmp/build \
		cbayle/docker-tuleap-buildrpms /run.sh --folder=rhel6 --php=php
 
clonetuleap:
	@echo "=== $@ ==="
	@[ -d tuleap/stable ] || git clone $(TULEAP) tuleap/stable
	@echo "=== Current branch ==="
	@cd tuleap/stable ; git branch -v
	@echo "=== Last branch availeble ==="
	@cd tuleap/stable ; git branch -va | tail -1

clonemodules: 
	@echo "=== $@ ==="
	@cd modules ; for gitrepo in $(GITREPOS) ; \
	do \
		var=$$(basename "$$gitrepo" '.git'); \
		echo "=== $$var ===" ;\
		if [ ! -d "$$var" ] ; \
		then \
			git clone $$gitrepo ; \
		fi \
	done
	@echo 'Done $@'


# We need :
#  the docker-build-documentation container 
#  get documentation repository as deps
#  get english documentation 
#  get french documentation 
# we only build if doc/rpm/RPMS/noarch is not yet there
builddoc: cbayle/docker-build-documentation doc/deps doc/en doc/fr
	@if [ ! -d doc/rpm/RPMS/noarch ] ; \
	then \
		docker run --rm -e VERSION=$(VERSION) \
			-e UID=$(shell id -u) \
			-e GID=$(shell id -g) \
			-v $(CURDIR)/doc:/sources \
			cbayle/docker-build-documentation ; \
	else \
		echo "Doc already build, remove doc/rpm if you want to rebuild"; \
	fi

# We build the container if not found in locally available images
cbayle/docker-build-documentation:
	@if docker images $@ | grep -q $@ ; \
	then \
		docker images $@ ; \
	else \
		make docker-build-documentation-container ; \
	fi ;\

# Check container is there
cbayle/docker-tuleap-buildsrpms:
	@docker images $@ | grep -q $@

# Check container is there
cbayle/docker-tuleap-buildrpms:
	@docker images $@ | grep -q $@

docker-build-documentation-container: doc/docker-build-documentation
	cd doc/docker-build-documentation ; docker build -t cbayle/docker-build-documentation .

doc/docker-build-documentation:
	git clone $(BUILD_DOC_CONTAINER) $@

doc/deps: 
	git clone $(DEPS) doc/deps

doc/en: 
	git clone $(EN) doc/en

doc/fr: 
	git clone $(FR) doc/fr

copydoc: $(RESULTDIR)/RPMS/noarch $(RESULTDIR)/SOURCES $(RESULTDIR)/SPECS builddoc 
	@cp doc/rpm/RPMS/noarch/*.rpm $(RESULTDIR)/RPMS/noarch
	@cp doc/rpm/SOURCES/*.tar.gz $(RESULTDIR)/SOURCES
	@cp doc/rpm/SPECS/*.spec $(RESULTDIR)/SPECS

$(RESULTDIR)/%:
	[ -d $@ ] || mkdir -p $@

extra: restlertgz
	@echo 'Done $@'

restlertgz:
	@echo "=== $@ ==="
	@cd modules/php53-restler ; \
	[ -f ../php-restler/php-restler-3.0.rc4.tgz ] || \
		git archive -o ../php-restler/php-restler-3.0.rc4.tgz --prefix=restler-3.0.rc4/ HEAD




