ARG ELIXIR_VERSION="1.14.3"
ARG OTP_VERSION="25.2.3"
ARG DEBIAN_VERSION="bullseye-20230202-slim"
ARG IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"

FROM ${IMAGE}

# Install build dependencies
RUN apt-get update --yes && apt-get install --yes \
    # build-essential: dpkg-dev g++ gcc libc6-dev make
    build-essential \
    curl \
    file \
    git \
    less \
    locales \
    openssl \
    sudo \
    tzdata \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create docker user with non-root privileges
ARG USER_ID="1000"
RUN useradd dev --create-home --uid=${USER_ID}

USER dev

ENV PROJECT_ROOT="/app"

ENV MIX_HOME="${PROJECT_ROOT}/.mix"

# Bash history
ENV HISTFILE="${PROJECT_ROOT}/tmp/.bash_history"
# ignorespace + ignoredups
ENV HISTCONTROL="ignoreboth"

WORKDIR ${PROJECT_ROOT}

CMD ["/bin/bash"]
