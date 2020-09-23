
Building snap on command line

  cd snap

  snapcraft


  cleaning the latest build :

	snapcraft clean



Install on dev stage

  sudo snap install iotmonitor_0.2+git_amd64.snap --devmode --dangerous

Upload the edge :

  snapcraft upload --release=edge iotmonitor*.snap

promote the snap to beta or candidate
  snapcraft release iotmonitor 5 beta
