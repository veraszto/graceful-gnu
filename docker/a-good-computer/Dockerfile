FROM ubuntu:latest
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
vim tmux htop locales git gnupg tree wev x11-utils \
dconf-cli dbus-x11 uuid-runtime libglib2.0-bin dconf-gsettings-backend libcanberra-gtk3-module \
curl python3 python3-pyqt6 libsecp256k1-dev python3-cryptography

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
WORKDIR root/git
RUN git clone https://github.com/veraszto/bash.git
RUN git clone https://github.com/veraszto/danvim.git
RUN git clone https://github.com/veraszto/graceful-gnu.git
WORKDIR /root
RUN touch .bash_history
RUN ln -s git/bash/inputrc .inputrc
RUN echo "source ~/git/bash/my-custom-bashrc.sh" >> .bashrc
CMD ["tmux", "-f", "/root/git/graceful-gnu/tmux/default.conf"]
