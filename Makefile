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

# Fix for jpgraph package
JPGRAPH=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/jpgraph-tuleap.git
JPGRAPH=https://github.com/cbayle/jpgraph-tuleap.git

GIT=ssh://gitolite@tuleap.net/tuleap/deps/src/git.git
GITOLITE3=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/gitolite3.git


GITREPOS=\
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/cvs-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/php-mediawiki-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/viewvc-tuleap.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/mailman-tuleap.git \
$(JPGRAPH) \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-restler.git \
ssh://gitolite@tuleap.net/tuleap/deps/src/php53-restler.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/restler-api-explorer.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/htmlpurifier.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-zendframework.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/openfire-tuleap-plugins.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/forgeupgrade.git \
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/openfire-tuleap-plugins.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-sabredav.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/geshi.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-pear-Mail-Mbox.git \
ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-guzzle.git \


TULEAP=ssh://gitolite@tuleap.net/tuleap/tuleap/stable.git

DEPS=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/documentation.git
EN=https://github.com/Enalean/tuleap-documentation-en.git
FR=https://github.com/Enalean/tuleap-documentation-fr.git


BUILD_DOC_CONTAINER=https://github.com/Enalean/docker-build-documentation.git
BUILD_RPM_CONTAINER=https://github.com/cbayle/docker-tuleap-buildrpms.git
BUILD_SRPM_CONTAINER=https://github.com/Enalean/docker-tuleap-buildsrpms.git
BUILD_ADMDOC_CONTAINER=https://github.com/Enalean/tuleap-admin-documentation.git


default: buildmodules buildtuleap copydoc buildrepo
	@echo '--> Done $@ $(VERSION)'

buildmodules: clonemodules extra buildsrpms buildrpms
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=forgeupgrade
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=viewvc-tuleap
	@#make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=jpgraph-tuleap
	@#createrepo $(RESULTDIR)/RPMS
	@echo '--> Done $@'

buildtuleap: clonetuleap tlbuildsrpms tlbuildrpms
	@echo '--> Done $@'

getmaster:
	@echo "=== $@ ==="
	cd tuleap/stable ; git checkout -f master ; 
	@echo '--> Done $@'
	
getvers: getmaster
	@echo "=== $@ ==="
	@lastbranch=$(shell cd tuleap/stable ; basename $$(git branch -va | tail -1 | cut -d" " -f3)) ; \
	branch=$(shell cd tuleap/stable ; git branch | grep ^\* | cut -d" " -f2) ; \
	mv tools/rpm ../rpm.master ;\
	git branch -d $$lastbranch || true ; \
	git checkout -b $$lastbranch remotes/origin/$$lastbranch ; \
	mv tools/rpm tools/rpm.old ; mv ../rpm.master tools/rpm
	@echo '--> Done $@'

tlbuildsrpms: $(TLBUILDDIR) cbayle/docker-tuleap-buildsrpms
	@echo "=== $@ ==="
	@[ -d $(TLBUILDDIR)/rhel6 ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/tuleap/stable:/tuleap \
		-v $(TLBUILDDIR):/srpms \
		cbayle/docker-tuleap-buildsrpms:1.0
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
                -v $(TLBUILDDIR):/srpms \
		ubuntu:14.04 /bin/chown -R $(shell id -u).$(shell id -g) /srpms
	@echo '  --> Already Done $@ : remove $(TLBUILDDIR)/rhel6 to rebuild'
	
$(TLBUILDDIR):
	mkdir $(TLBUILDDIR)

tlbuildrpms: $(TLRESULTDIR) cbayle/docker-tuleap-buildrpms
	@echo "=== $@ ==="
	@[ -d $(TLRESULTDIR)/RPMS/noarch ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/tuleap/stable:/tuleap \
		-v $(TLBUILDDIR):/srpms \
		-v $(TLRESULTDIR):/tmp/build \
		cbayle/docker-tuleap-buildrpms:1.0 /run.sh --folder=rhel6 --php=php
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
		-v $(TLRESULTDIR):/tmp/build \
		centos:centos6 /bin/chown -R $(shell id -u).$(shell id -g) /tmp/build
	@echo '  --> Already Done $@ : remove $(TLRESULTDIR)/RPMS/noarch to rebuild'

$(TLRESULTDIR):
	mkdir $(TLRESULTDIR)

buildsrpms: $(BUILDDIR) cbayle/docker-tuleap-buildsrpms
	@echo "=== $@ ==="
	@[ -d $(BUILDDIR)/rhel6 ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
                -v $(CURDIR):/tuleap \
                -v $(BUILDDIR):/srpms \
                cbayle/docker-tuleap-buildsrpms:1.0
	@echo '  --> Done $@'
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
                -v $(BUILDDIR):/srpms \
		ubuntu:14.04 /bin/chown -R $(shell id -u).$(shell id -g) /srpms
	@echo '  --> Done $@'

$(BUILDDIR):
	mkdir $(BUILDDIR)

buildrpms: $(RESULTDIR) cbayle/docker-tuleap-buildrpms
	@echo "=== $@ ==="
	@[ -d $(RESULTDIR)/RPMS/noarch ] || docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(BUILDDIR):/srpms/ \
		-v $(RESULTDIR):/tmp/build \
		cbayle/docker-tuleap-buildrpms:1.0 /run.sh --folder=rhel6 --php=php
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
		-v $(RESULTDIR):/tmp/build \
		centos:centos6 /bin/chown -R $(shell id -u).$(shell id -g) /tmp/build
	@echo '  --> Done $@'
 
$(RESULTDIR):
	mkdir $(RESULTDIR)

clonetuleap:
	@echo "=== $@ ==="
	@if [ ! -d tuleap/stable ] ; \
	then \
		git clone $(TULEAP) tuleap/stable ; \
	fi
	@echo "=== Current branch ==="
	@cd tuleap/stable ; git branch -v
	@echo "=== Last branch availeble ==="
	@cd tuleap/stable ; git branch -va | tail -1
	@echo '  --> Done $@'

updatetuleap:
	@echo "=== $@ ==="
	@if [ -d tuleap/stable ] ; \
	then \
		(cd tuleap/stable ; git pull) ; \
	fi
	@echo "  === Current branch ==="
	@cd tuleap/stable ; git branch -v
	@echo "  === Last branch availeble ==="
	@cd tuleap/stable ; git branch -va | tail -1
	@echo '  --> Done $@'

clonemodules: 
	@echo "=== $@ ==="
	@cd modules ; for gitrepo in $(GITREPOS) ; \
	do \
		var=$$(basename "$$gitrepo" '.git'); \
		echo "  +-> $$var" ;\
		if [ ! -d "$$var" ] ; \
		then \
			git clone $$gitrepo ; \
		fi \
	done
	@echo '  --> Done $@'

updatemodules:
	@echo "=== $@ ==="
	@cd modules ; for gitrepo in $(GITREPOS) ; \
	do \
		var=$$(basename "$$gitrepo" '.git'); \
		echo "  +-> $$var" ;\
		if [ -d "$$var" ] ; \
		then \
			(cd $$var ; git pull) ; \
		fi \
	done
	@echo '  --> Done $@'


# We need :
#  the docker-build-documentation container 
#  get documentation repository as deps
#  get english documentation 
#  get french documentation 
# we only build if doc/rpm/RPMS/noarch is not yet there
builddoc: cbayle/docker-build-documentation doc/deps doc/en doc/fr
	@echo "=== $@ ==="
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
	@echo '  --> Done $@'

# We build the container if not found in locally available images
cbayle/docker-build-documentation:
	@echo "=== $@ ==="
	@if docker images $@ | grep -q $@ ; \
	then \
		docker images $@ ; \
	else \
		make docker-build-documentation-container ; \
	fi
	@echo '  --> Done $@'

# Check container is there
cbayle/docker-tuleap-buildsrpms:
	@echo "=== $@ ==="
	@if docker images $@ | grep -q $@ ; \
	then \
		docker images $@ ; \
	else \
		make docker-build-srpms-container ; \
	fi
	@echo '  --> Done $@'

# Check container is there
cbayle/docker-tuleap-buildrpms:
	@echo "=== $@ ==="
	@if docker images $@ | grep -q $@ ; \
	then \
		docker images $@ ; \
	else \
		make docker-build-rpms-container ; \
	fi
	@echo '  --> Done $@'

docker-build-documentation-container: docker/docker-build-documentation
	@echo "=== $@ ==="
	cd docker/docker-build-documentation ; docker build -t cbayle/docker-build-documentation .
	@echo '  --> Done $@'

docker-build-rpms-container: docker/docker-tuleap-buildrpms
	@echo "=== $@ $< ==="
	cd $< ; docker build -t cbayle/docker-tuleap-buildrpms:1.0 .
	@echo '  --> Done $@'

docker-build-srpms-container: docker/docker-tuleap-buildsrpms
	@echo "=== $@ = $< ==="
	cd $< ; docker build -t cbayle/docker-tuleap-buildsrpms:1.0 .
	@echo '--> Done $@'

docker/docker-tuleap-buildrpms:
	@echo "=== $@ ==="
	git clone $(BUILD_RPM_CONTAINER) $@
	@echo '  --> Done $@'

docker/docker-tuleap-buildsrpms:
	@echo "=== $@ ==="
	git clone $(BUILD_SRPM_CONTAINER) $@
	@echo '  --> Done $@'

docker/docker-build-documentation:
	@echo "=== $@ ==="
	git clone $(BUILD_DOC_CONTAINER) $@
	@echo '  --> Done $@'

doc/deps: 
	@echo "=== $@ ==="
	git clone $(DEPS) doc/deps
	@echo '  --> Done $@'

doc/en: 
	@echo "=== $@ ==="
	git clone $(EN) doc/en
	@echo '  --> Done $@'

doc/fr: 
	@echo "=== $@ ==="
	git clone $(FR) doc/fr
	@echo '  --> Done $@'

copydoc: $(RESULTDIR)/RPMS/noarch $(RESULTDIR)/SOURCES $(RESULTDIR)/SPECS builddoc 
	@echo "=== $@ ==="
	@cp doc/rpm/RPMS/noarch/*.rpm $(RESULTDIR)/RPMS/noarch
	@cp doc/rpm/SOURCES/*.tar.gz $(RESULTDIR)/SOURCES
	@cp doc/rpm/SPECS/*.spec $(RESULTDIR)/SPECS
	@echo '  --> Done $@'

$(RESULTDIR)/%:
	@echo "=== $@ ==="
	[ -d $@ ] || mkdir -p $@
	@echo '  --> Done $@'

extra: restlertgz
	@echo '  --> Done $@'

restlertgz:
	@echo "=== $@ ==="
	@cd modules/php53-restler ; \
	[ -f ../php-restler/php-restler-3.0.rc4.tgz ] || \
		git archive -o ../php-restler/php-restler-3.0.rc4.tgz --prefix=restler-3.0.rc4/ HEAD
	@echo "  --> Done $@"

buildrepo: /usr/bin/createrepo
	@echo "=== $@ ==="
	@[ -d $(RESULTDIR)/RPMS/repodata ] || createrepo $(RESULTDIR)/RPMS
	@[ -d $(TLRESULTDIR)/RPMS/repodata ] || createrepo $(TLRESULTDIR)/RPMS
	@echo "  --> Done $@"

clean:
	@echo "=== $@ ==="
	rm -rf doc/rpm
	rm -rf $(TLBUILDDIR)
	rm -rf $(TLRESULTDIR)
	rm -rf $(BUILDDIR)
	rm -rf $(RESULTDIR)
	@echo "  --> Done $@"

/usr/bin/createrepo:
	sudo apt-get -y install createrepo

