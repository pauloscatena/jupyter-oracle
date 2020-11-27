FROM ubuntu:20.04

WORKDIR /app
ADD . /app
# Update apt definitions
RUN apt-get update -y

# Install wget 
RUN apt-get install -y wget
RUN apt-get install -y unzip

# Install python
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes:ppa
RUN apt-get update

RUN apt-get update && apt-get -y update
RUN apt-get install -y build-essential python3.8 python3-pip python3-dev
RUN pip3 -q install pip --upgrade

# Install PIP
RUN apt-get install -y python3-pip

# Install Jupyter
RUN pip3 install jupyter

# Install python packages for Jupyter
RUN pip3 install ipython-sql
RUN pip3 install cx_oracle

# Download and install Oracle Instant Client
RUN wget https://download.oracle.com/otn_software/linux/instantclient/19800/instantclient-basic-linux.x64-19.8.0.0.0dbru.zip
RUN mkdir /opt/oracle
RUN unzip instantclient-basic-linux.x64-19.8.0.0.0dbru.zip -d /opt/oracle 
RUN export PATH="$PATH:/opt/oracle/instantclient_19_8"
RUN export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/oracle/instantclient_19_8"

# Delete Oracle installation files
RUN rm instantclient-basic-linux.x64-19.8.0.0.0dbru.zip


# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

# Switches to a non-root user and changes the ownership of the /app folder"
RUN useradd appuser && chown -R appuser /app
USER appuser

EXPOSE 8888/tcp
#CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]
#CMD ["jupyter", "notebook", "--port=8888"]
