# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

EGIT_REPO_URI="git://github.com/D-Programming-GDC/GDC.git"
EGIT_BRANCH="gdc-4.8"
EGIT_COMMIT="c568ff603fcdcc50f405a6ab2e0639350a8648f6"
EGIT_SOURCEDIR="${WORKDIR}/dev"
EGIT_NOUNPACK=1

inherit git-2

IUSE="d"

# Original GCC code starts here
PATCH_VER="1.1"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
PIE_VER="0.5.9"
SPECS_VER="0.2.0"
SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

inherit eutils toolchain

DESCRIPTION="The GNU Compiler Collection"

LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	>=${CATEGORY}/binutils-2.20"
PDEPEND="d? ( =dev-util/gdmd-${PV}* )"

GCC_FILESDIR=${PORTDIR}/sys-devel/gcc/files

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

src_prepare() {
	if has_version '<sys-libs/glibc-2.12' ; then
		ewarn "Your host glibc is too old; disabling automatic fortify."
		ewarn "Please rebuild gcc after upgrading to >=glibc-2.12 #362315"
		EPATCH_EXCLUDE+=" 10_all_default-fortify-source.patch"
	fi

	toolchain_src_prepare

	use vanilla && return 0
	#Use -r1 for newer piepatchet that use DRIVER_SELF_SPECS for the hardened specs.
	[[ ${CHOST} == ${CTARGET} ]] && epatch "${GCC_FILESDIR}"/gcc-spec-env-r1.patch

	if use d ; then
		# Get GDC sources into the tree.
		git-2_src_unpack
		cd ../dev || die "Changing into Git checkout directory failed."
		./setup-gcc.sh ../gcc-${GCC_PV} || die "Could not setup GDC."
	fi
}
