# from https://github.com/containerd/containerd/releases
version=1.7.18

# download and extract
wget https://github.com/containerd/containerd/releases/download/v$version/containerd-$version-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-$version-linux-amd64.tar.gz

# enable with systemd
sudo mkdir -p /usr/local/lib/systemd/system
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /usr/local/lib/systemd/system/containerd.service
