# ARG bash_version
# FROM bash:${bash_version}
FROM ubuntu

ARG BATS_VERSION=1.4.1
ARG USER=ops

# RUN apk add --no-cache git curl \
# 	&& git config --global user.email "user@example.com" \
# 	&& git config --global user.name "User Name" \
# 	&& adduser -D ${USER}
RUN apt-get update \
	&& apt-get install -y git curl \
	&& git config --global user.email "user@example.com" \
	&& git config --global user.name "User Name" \
	&& adduser ${USER}

RUN rm -f /basalt.lock

USER ops
WORKDIR /home/${USER}

# Install Basalt
RUN curl -LsSo- https://raw.githubusercontent.com/hyperupcall/basalt/main/scripts/install.sh | sh

# Install bats-core
RUN \
	curl -LsSo './bats-core.tar.gz' --create-dirs "https://github.com/bats-core/bats-core/archive/v${BATS_VERSION}.tar.gz" \
	&& tar xf './bats-core.tar.gz' \
	&& mv ./bats-core-*/ ./bats-core \
	&& rm -f './bats-core.tar.gz'

COPY --chown=$USER:$USER . ./bash-object

WORKDIR /home/$USER/bash-object

ENV PATH="/home/ops/.local/share/basalt/source/pkg/bin:$PATH"
ENTRYPOINT ["bash", "-c", "eval \"$(basalt global init bash)\" && basalt install && /home/ops/bats-core/bin/bats ./tests"]
