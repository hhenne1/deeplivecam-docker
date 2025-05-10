
#FROM jlesage/baseimage-gui:debian-12-v4.7.1
FROM jlesage/baseimage-gui:ubuntu-22.04-v4.7.1
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    python3.10 python3-pip python3-venv git ffmpeg python3-tk wget && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
RUN dpkg -i cuda-keyring_1.0-1_all.deb
RUN apt-get update
RUN apt-get -y install cuda

COPY deeplivecam-code/ /deeplivecam/
COPY model-dls/ /deeplivecam/models/
COPY startapp.sh /startapp.sh
WORKDIR /deeplivecam


ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"


RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install gfpgan basicsr 
RUN pip3 install -r requirements.txt

RUN chmod 777 -R /root
RUN chmod 777 -R /deeplivecam
RUN chmod 777 -R /opt

EXPOSE 5800
EXPOSE 5900

# Define a healthcheck.
HEALTHCHECK --interval=60s --timeout=30s --retries=3 \
    CMD curl -f http://localhost:8500/ || exit 1

# Add volumes
#VOLUME /deeplivecam/outputs

# Copy the start script
COPY startapp.sh /startapp.sh
RUN set-cont-env APP_NAME "DeepLiveCam"


# Startup
#CMD ["python3", "run.py", "--execution-provider", "cuda"]