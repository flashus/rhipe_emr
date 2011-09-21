#! /bin/bash
set -e

export HADOOP=/home/hadoop

SOURCESLIST=sources.list
APTDIR=/etc/apt
CP=/bin/cp
SUDO=/usr/bin/sudo
APT=/usr/bin/apt-get
WGET=/usr/bin/wget
TAR=/bin/tar
MAKE=/usr/bin/make
R=/usr/bin/R
LDCONFIG=/sbin/ldconfig
CAT=/bin/cat
CHOWN=/bin/chown
LIBR=/usr/local/lib/R
LIBDIR=/usr/lib
GFORTRAN=/usr/lib/gcc/x86_64-linux-gnu/4.3/libgfortran*

PROTOBUF_PATH=http://protobuf.googlecode.com/files/
PROTOBUF=protobuf-2.4.1
PROTOBUF_SRC=$PROTOBUF.tar.gz

RHIPE_PATH=http://ml.stat.purdue.edu/rhipe/download/
RHIPE_SRC=Rhipe_0.66.tar.gz

$CAT << EOF > $SOURCESLIST
deb http://http.us.debian.org/debian   stable         main contrib non-free
deb http://security.debian.org         lenny/updates  main contrib non-free
deb http://security.debian.org         stable/updates main contrib non-free
EOF

$SUDO $CP $SOURCESLIST $APTDIR/$SOURCESLIST
$SUDO $APT update
$SUDO $APT -y install r-base-dev
$SUDO $APT -y install pkg-config
$SUDO $APT -y install emacs ess

$SUDO $CP $GFORTRAN $LIBDIR

$WGET $PROTOBUF_PATH$PROTOBUF_SRC
$TAR xvfz $PROTOBUF_SRC
cd $PROTOBUF && ./configure && $MAKE && $SUDO $MAKE install && $SUDO $LDCONFIG
$WGET $RHIPE_PATH$RHIPE_SRC
$SUDO $CHOWN -R hadoop:hadoop $LIBR
$R CMD INSTALL $RHIPE_SRC

cd $HADOOP && $CAT << EOF >> .bashrc
export HADOOP=/home/hadoop
export HADOOP_BIN=/home/hadoop/bin
EOF


cd $HADOOP && $CAT << EOF >> install.R
install.packages("biglm", repos="http://cran.r-project.org/")
install.packages("multicore", repos="http://cran.r-project.org/")
EOF
$R CMD BATCH install.R
