# from https://github.com/containernetworking/plugins/releases
version=1.4.0

# download and install
wget https://github.com/containernetworking/plugins/releases/download/v$version/cni-plugins-linux-amd64-v$version.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v$version.tgz
