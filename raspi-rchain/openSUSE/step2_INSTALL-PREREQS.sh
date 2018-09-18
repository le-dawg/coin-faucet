



# Create a new swap file if we have less than 2GB allocated
currentSWAP=$(swapon --show=SIZE --noheadings --bytes)

if [ ! -f /swapfile ]; then
	if [ "$currentSWAP" -gt "2048000000" ]; then
		echo "SWAP is larger than 2GB. No need for additional room"
	else
		echo "SWAP is smaller than 2GB. Creating a new SWAP file"

		sudo touch /swapfile
		dd if=/dev/zero of=/swapfile bs=1024 count=2048000
		mkswap /swapfile
		swapon /swapfile
	fi
fi

# Install dependencies
zypper install -y automake cmake
zypper install -y libapr1 libapr-util1 libapr-util1-devel
zypper install -y ninja
zypper install -y gcc gcc-c++
zypper install -y lmdb-devel
zypper install -y openssl libopenssl1_0_0 libopenssl-devel
zypper install -y libtool
zypper install -y gnutls libgnutls-devel libgnutls-openssl-devel
zypper install -y go1.9
zypper install -y java-1_8_0-openjdk-devel

# Get libsodium
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue https://download.libsodium.org/libsodium/releases/libsodium-1.0.16.tar.gz
tar xf libsodium-1.0.16.tar.gz

# Build and install libsodium
cd libsodium-1.0.16
./configure
make && make check
sudo make install
cd ..

# Get LibreSSL
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://openbsd.cs.toronto.edu/pub/OpenBSD/LibreSSL/libressl-2.8.0.tar.gz
tar xf libressl-2.8.0.tar.gz

# Build and install LibreSSL
cd libressl-2.8.0
./configure
make
sudo make install
cd ..

# Get netty-tcnative (Tomcat Native)
git clone https://github.com/netty/netty-tcnative.git

# Build and install netty-tcnative (Tomcat Native)
export MAVEN_OPTS="-Xmx768m"
cd netty-tcnative
./mvnw compile
sudo ./mvnw install
cd ..

# Download and Install Java CUP 11b
mkdir -p ~/.local/share/java/
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://central.maven.org/maven2/com/github/vbmacher/java-cup/11b/java-cup-11b.jar
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://central.maven.org/maven2/nz/ac/waikato/cms/weka/thirdparty/java-cup-11b-runtime/2015.03.26/java-cup-11b-runtime-2015.03.26.jar
cp java-cup-11b.jar ~/.local/share/java/
cp java-cup-11b-runtime-2015.03.26.jar ~/.local/share/java/java-cup-11b-runtime.jar

# Setup all environment variables
export M2_HOME=$HOME/.m2
export JAVA_OPTS="-Xms256m -Xmx512m"
export SBT_OPTS="-Xms256m -Xmx512m"
export CLASSPATH=$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
export CLASSPATH=$CLASSPATH:$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT.jar
export CLASSPATH=$CLASSPATH:$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
export CLASSPATH=$CLASSPATH:$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT.jar
export CLASSPATH="$CLASSPATH:$HOME/.local/share/java/java-cup-11b.jar"
export CLASSPATH="$CLASSPATH:$HOME/.local/share/java/java-cup-11b-runtime.jar"

