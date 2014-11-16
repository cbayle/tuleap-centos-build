#! /usr/bin/make -f
BUILDDIR=$(CURDIR)/../srpms-libs

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
ssh://gitolite@tuleap.net/tuleap/deps/tuleap/openfire-tuleap-plugins.git


DEPS=ssh://gitolite@tuleap.net/tuleap/deps/tuleap/documentation.git
EN=https://github.com/Enalean/tuleap-documentation-en.git
FR=https://github.com/Enalean/tuleap-documentation-fr.git


FRGUPG=git@github.com:cbayle/ForgeUpgrade.git


GITREPOS2=\
https://github.com/Enalean/docker-build-documentation.git \
https://github.com/Enalean/tuleap-admin-documentation.git \



default: build #builddoc copydoc
	echo 'Done'

build:
	make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=forgeupgrade
	make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=viewvc-tuleap
	make -f Makefile.pkgname RPM_TMP=$(BUILDDIR) PKG_NAME=jpgraph-tuleap
	#createrepo $(BUILDDIR)/RPMS


modules: forgeupgrade
	@for gitrepo in $(GITREPOS) $(GITREPOS2) ; \
	do \
		var=$$(basename "$$gitrepo" '.git'); \
		echo "=== $$var ===" ;\
		if [ ! -d "$$var" ] ; \
		then \
			git clone $$gitrepo ; \
		fi \
	done

forgeupgrade:
	git clone $(FRGUPG) forgeupgrade

VERSION=1.0

dockerbuild:
	cd docker-build-documentation ; docker build -t cbayle/docker-build-documentation .


builddoc:
	[ -d doc/deps ] || git clone $(DEPS) doc/deps
	[ -d doc/en ] || git clone $(EN) doc/en
	[ -d doc/fr ] || git clone $(FR) doc/fr
	docker run --rm -e VERSION=$(VERSION) \
		-e UID=$(shell id -u) \
		-e GID=$(shell id -g) \
		-v $(CURDIR)/doc:/sources \
		cbayle/docker-build-documentation

copydoc:
	[ -d ../rpms-libs/RPMS/noarch ] || mkdir -p ../rpms-libs/RPMS/noarch
	[ -d ../rpms-libs/SOURCES ] || mkdir -p ../rpms-libs/SOURCES
	[ -d ../rpms-libs/SPECS ] || mkdir -p ../rpms-libs/SPECS
	cp doc/rpm/RPMS/noarch/*.rpm ../rpms-libs/RPMS/noarch
	cp doc/rpm/SOURCES/*.tar.gz ../rpms-libs/SOURCES
	cp doc/rpm/SPECS/*.spec ../rpms-libs/SPECS

restlertgz:
	cd php53-restler ; git archive -o ../php-restler/php-restler-3.0.rc4.tgz --prefix=restler-3.0.rc4/ HEAD
