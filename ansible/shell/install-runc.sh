# from https://github.com/opencontainers/runc/releases
version=1.1.12

# download and install
wget https://github.com/opencontainers/runc/releases/download/v$version/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
