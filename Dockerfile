FROM ubuntu

ENV RUNNING_IN_DOCKER=true
RUN <<EOR
apt update -yq
apt install software-properties-common -yq
add-apt-repository ppa:longsleep/golang-backports
add-apt-repository ppa:apt-fast/stable
apt update
apt install -yq apt-fast
EOR

RUN apt-fast update -yq && apt-fast upgrade -yq && apt-fast install -yq \
      bash \
      curl \
      golang-go \
      delta \
      git \
      jq \
      libssl-dev \
      neovim \
      ncurses-term \
      protobuf-compiler \
      ripgrep \
      rustup \
      software-properties-common \
      sudo \
      tmux \
      tree \
      unzip \
      yq

RUN apt remove -yq xclip xsel
COPY ./files/xsel /usr/bin/xsel
RUN chmod +x /usr/bin/xsel
COPY ./files/xclip /usr/bin/xclip
RUN chmod +x /usr/bin/xclip

ARG USER_ID
ARG GROUP_ID
RUN sed -i 's/^UID_MIN.*/UID_MIN '"${USER_ID}"'/' /etc/login.defs
RUN sed -i 's/^GID_MIN.*/GID_MIN '"${GROUP_ID}"'/' /etc/login.defs
RUN useradd -u "${USER_ID}" -g "${GROUP_ID}" -G tty,sudo -m -s /usr/bin/bash user

USER user
WORKDIR /home/user
RUN mkdir -p /home/user/.local
RUN mkdir -p /home/user/.cache
RUN mkdir -p /home/user/.config

RUN rustup default stable
RUN cargo install --locked --bin jj jj-cli
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/user/.local/bin:/home/user/.cargo/bin:$PATH"
ENV EDITOR=nvim
ENV CLIPBOARD_BRIDGE=http://host.docker.internal:9999
ENTRYPOINT ["/home/user/.local/bin/claude"]
