# Pull base image.
FROM debian:jessie
MAINTAINER Eric Bailey <eric@ericb.me>

# Install LilyPond.
RUN apt-get update && \
    apt-get install -y --no-install-recommends lilypond

# Clean APT.
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Define mountable directories.
VOLUME ["/src"]

# Define working directory.
WORKDIR /src

# Define default command.
CMD ["lilypond", "--version"]
