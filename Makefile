#! /usr/bin/make -f
BUILDDIR=$(CURDIR)/../srpms
RESULTDIR=$(CURDIR)/../rpms

RPMCMD=/run.sh --folder=rhel6 --php=php
SRPMCMD=/run.sh

# Try to find Tuleap Version, if not set 1.0
VERSION=$(shell cat tuleap/stable/VERSION 2>/dev/null)
ifeq ($(strip $(VERSION)),)
        VERSION=1.0
endif

# CVS-TULEAP
CVS_TULEAP=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/cvs-tuleap.git
# PHP-MEDIAWIKI-TULEAP
MEDIAWIKI=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/php-mediawiki-tuleap.git
# JPGRAPh
JPGRAPHUPS=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/jpgraph-tuleap.git
JPGRAPH=https://github.com/cbayle/jpgraph-tuleap.git
# VIEWVC
VIEWVC=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/viewvc-tuleap.git
# MAILMAn
MAILMAN=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/rhel/6/mailman-tuleap.git
# RESTLER
PHP_RESTLER=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-restler.git
PHP53_RESTLER=ssh://gitolite@tuleap.net/tuleap/deps/src/php53-restler.git
RESTLER_API=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/restler-api-explorer.git
# HTMLPURIFIER
HTMLPURIFIER=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/htmlpurifier.git
# ZENDFRAMEWORK
ZENDFRAMEWORK=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-zendframework.git
# OPENFIRE
OPENFIRE=https://github.com/igniterealtime/Openfire
OPENFIRE_TULEAP=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/openfire-tuleap-plugins.git
# FORGEUPGRADE
FORGEUPGRADE=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/forgeupgrade.git
# SABREDAV
SABREDAV=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-sabredav.git
# GESHI
GESHI=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/geshi.git
# MAIL_MBOX
MAIL_MBOX=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-pear-Mail-Mbox.git
# GUZZLE
GUZZLE=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/php-guzzle.git
# GIT
GIT=ssh://gitolite@tuleap.net/tuleap/deps/src/git.git
GITOLITE3=ssh://gitolite@tuleap.net/tuleap/deps/3rdparty/gitolite3.git

# TULEAP
TULEAP=ssh://gitolite@tuleap.net/tuleap/tuleap/stable.git

GITREPOS=$(CVS) $(MEDIAWIKI) $(VIEWVC) $(MAILMAN) $(JPGRAPH) $(PHP_RESTLER) $(PHP53_RESTLER) $(RESTLER_API) $(HTMLPURIFIER) $(ZENDFRAMEWORK) $(OPENFIRE-TULEAP) $(FORGEUPGRADE) $(SABREDAV) $(GESHI) $(MAIL_MBOX) $(GUZZLE) $(GIT)

DEPS=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/documentation.git
EN=https://github.com/Enalean/tuleap-documentation-en.git
FR=https://github.com/Enalean/tuleap-documentation-fr.git


BUILD_DOC_CONTAINER=https://github.com/Enalean/docker-build-documentation.git
BUILD_RPM_CONTAINER=https://github.com/cbayle/docker-tuleap-buildrpms.git
BUILD_SRPM_CONTAINER=https://github.com/Enalean/docker-tuleap-buildsrpms.git
BUILD_ADMDOC_CONTAINER=https://github.com/Enalean/tuleap-admin-documentation.git


default: clonecode buildcode buildrepo
	@echo '--> Done $@'
	@echo ''

clonecode: clonemodules clonetuleap cloneopenfire
	@echo '--> Done $@'
	@echo ''

buildcode: buildsrpms buildrpms copydoc buildrepo
	@echo '--> Done $@'
	@echo ''

getmaster:
	@echo "=== $@ ==="
	cd tuleap/stable ; git checkout -f master ; 
	@echo '--> Done $@'
	@echo ''
	
getvers: getmaster
	@echo "=== $@ ==="
	@lastbranch=$(shell cd tuleap/stable ; basename $$(git branch -va | tail -1 | cut -d" " -f3)) ; \
	branch=$(shell cd tuleap/stable ; git branch | grep ^\* | cut -d" " -f2) ; \
	mv tools/rpm ../rpm.master ;\
	git branch -d $$lastbranch || true ; \
	git checkout -b $$lastbranch remotes/origin/$$lastbranch ; \
	mv tools/rpm tools/rpm.old ; mv ../rpm.master tools/rpm
	@echo '--> Done $@'
	@echo ''

buildsrpms: $(BUILDDIR) cbayle/docker-tuleap-buildsrpms
	@echo "=== $@ ==="
	@docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
                -v $(CURDIR):/tuleap \
                -v $(BUILDDIR):/srpms \
                cbayle/docker-tuleap-buildsrpms:1.0 $(SRPMCMD)
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
                -v $(BUILDDIR):/srpms \
		ubuntu:14.04 /bin/chown -R $(shell id -u).$(shell id -g) /srpms
	@echo '  --> Done $@'
	@echo ''

buildrpms: $(RESULTDIR) cbayle/docker-tuleap-buildrpms extra
	@echo "=== $@ ==="
	@docker run --rm=true -t -i \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/tools/rpm:/tuleap \
		-v $(BUILDDIR):/srpms/ \
		-v $(RESULTDIR):/tmp/build \
		cbayle/docker-tuleap-buildrpms:1.0 $(RPMCMD)
	# A bit ugly, should be done by docker-tuleap-buildrpms container
	@docker run --rm=true -t -i \
		-v $(RESULTDIR):/tmp/build \
		centos:centos6 /bin/chown -R $(shell id -u).$(shell id -g) /tmp/build
	@echo '  --> Done $@'
	@echo ''
 
$(BUILDDIR):
	mkdir $(BUILDDIR)

$(RESULTDIR):
	mkdir $(RESULTDIR)

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
	@echo ''

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
	@echo '--> Done $@'
	@echo ''

clonetuleap:
	@echo "=== $@ ==="
	@cd modules ; \
	if [ ! -d tuleap ] ; \
	then \
		git clone $(TULEAP) tuleap ; \
	fi ; \
	echo "  +-> Current branch" ; \
	git branch -v ; \
	echo "  +-> Last branch availeble" ; \
	git branch -va | tail -1
	@echo '--> Done $@'
	@echo ''

cloneopenfire:
	@echo "=== $@ ==="
	@cd modules ; \
	if [ ! -d tuleap ] ; \
	then \
		git clone $(OPENFIRE) openfire ; \
	fi ;
	@echo '--> Done $@'
	@echo ''

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
	@echo ''


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
	@echo ''

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
	@echo ''

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
	@echo ''

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
	@echo ''

docker-build-documentation-container: docker/docker-build-documentation
	@echo "=== $@ ==="
	cd docker/docker-build-documentation ; docker build -t cbayle/docker-build-documentation .
	@echo '  --> Done $@'
	@echo ''

docker-build-rpms-container: docker/docker-tuleap-buildrpms
	@echo "=== $@ $< ==="
	cd $< ; docker build -t cbayle/docker-tuleap-buildrpms:1.0 .
	@echo '  --> Done $@'
	@echo ''

docker-build-srpms-container: docker/docker-tuleap-buildsrpms
	@echo "=== $@ = $< ==="
	cd $< ; docker build -t cbayle/docker-tuleap-buildsrpms:1.0 .
	@echo '--> Done $@'
	@echo ''

docker/docker-tuleap-buildrpms:
	@echo "=== $@ ==="
	git clone $(BUILD_RPM_CONTAINER) $@
	@echo '  --> Done $@'
	@echo ''

docker/docker-tuleap-buildsrpms:
	@echo "=== $@ ==="
	git clone $(BUILD_SRPM_CONTAINER) $@
	@echo '  --> Done $@'
	@echo ''

docker/docker-build-documentation:
	@echo "=== $@ ==="
	git clone $(BUILD_DOC_CONTAINER) $@
	@echo '  --> Done $@'
	@echo ''

doc/deps: 
	@echo "=== $@ ==="
	git clone $(DEPS) doc/deps
	@echo '  --> Done $@'
	@echo ''

doc/en: 
	@echo "=== $@ ==="
	git clone $(EN) doc/en
	@echo '  --> Done $@'
	@echo ''

doc/fr: 
	@echo "=== $@ ==="
	git clone $(FR) doc/fr
	@echo '  --> Done $@'
	@echo ''

copydoc: $(RESULTDIR)/RPMS/noarch $(RESULTDIR)/SOURCES $(RESULTDIR)/SPECS builddoc 
	@echo "=== $@ ==="
	@cp doc/rpm/RPMS/noarch/*.rpm $(RESULTDIR)/RPMS/noarch
	@cp doc/rpm/SOURCES/*.tar.gz $(RESULTDIR)/SOURCES
	@cp doc/rpm/SPECS/*.spec $(RESULTDIR)/SPECS
	@echo '  --> Done $@'
	@echo ''

$(RESULTDIR)/%:
	@echo "=== $@ ==="
	[ -d $@ ] || mkdir -p $@
	@echo '  --> Done $@'
	@echo ''

extra: restlertgz renameopenfire #getopenfire
	@echo '  --> Done $@'
	@echo ''

restlertgz:
	@echo "=== $@ ==="
	@cd modules/php53-restler ; \
	[ -f ../php-restler/php-restler-3.0.rc4.tgz ] || \
		git archive -o ../php-restler/php-restler-3.0.rc4.tgz --prefix=restler-3.0.rc4/ HEAD
	@echo "  --> Done $@"

renameopenfire:
	@echo "=== $@ ==="
	@perl -pi -e 's/codendi/tuleap/g' modules/openfire-tuleap-plugins/openfire-tuleap-plugins.spec
	@echo "  --> Done $@"

getopenfire:
	[ -f $(RESULTDIR)/RPMS/noarch/openfire-3.9.3-1.i386.rpm ] || \
	wget -o $(RESULTDIR)/RPMS/noarch/openfire-3.9.3-1.i386.rpm \
	http://download.igniterealtime.org/openfire/openfire-3.9.3-1.i386.rpm
	
buildrepo: /usr/bin/createrepo
	@echo "=== $@ ==="
	@[ -d $(RESULTDIR)/RPMS/repodata ] || createrepo $(RESULTDIR)/RPMS
	@echo "  --> Done $@"
	@echo ''

clean:
	@echo "=== $@ ==="
	rm -rf doc/rpm
	rm -rf $(BUILDDIR)
	rm -rf $(RESULTDIR)
	@echo "  --> Done $@"
	@echo ''

/usr/bin/createrepo:
	sudo apt-get -y install createrepo

