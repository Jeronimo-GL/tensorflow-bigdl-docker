FROM ubuntu:18.04

RUN apt-get update; \
    apt-get install -y wget unzip gcc vim

RUN cd ~

# Install java
RUN apt-get install -y openjdk-8-jdk


# Install Scala
ENV SCALA_DEB=scala-2.11.8.deb
ENV SCALA_URL=www.scala-lang.org/files/archive/${SCALA_DEB}

RUN  apt-get remove scala-library scala; \
     wget ${SCALA_URL}; \
     dpkg -i ${SCALA_DEB}; \
     rm ${SCALA_DEB}

# Install sbt
RUN apt-get -y install gnupg2
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823; 
RUN apt-get update;
RUN apt-get -y install sbt
    

# Install spark
ENV SPARK_URL=https://archive.apache.org/dist/spark/spark-2.2.2/spark-2.2.2-bin-hadoop2.7.tgz
ENV SPARK_FILE=spark-2.2.2-bin-hadoop2.7.tgz
ENV SPARK_VERSION=spark-2.2.2-bin-hadoop2.7

RUN wget ${SPARK_URL}; \
    tar -xvf ${SPARK_FILE}; \
    mv ${SPARK_VERSION} /usr/local/; \
    ln -s /usr/local/${SPARK_VERSION}/ /usr/local/spark; \
    export SPARK_HOME=/usr/local/spark; \
    rm ${SPARK_FILE};
    
    
# Install bigDL
ENV BIGDL_ZIP=dist-spark-2.2.0-scala-2.11.8-all-0.10.0-dist.zip
ENV BIGDL_URL=https://repo1.maven.org/maven2/com/intel/analytics/bigdl/dist-spark-2.2.0-scala-2.11.8-all/0.10.0/${BIGDL_ZIP}

RUN wget ${BIGDL_URL};  \
     unzip ${BIGDL_ZIP} -d /opt/bigdl; \
     rm ${BIGDL_ZIP}; \
     cp /opt/bigdl/lib/* /usr/local/spark/jars/; \
     export BIGDL_HOME=/opt/bigdl

# Install python
RUN apt-get -y install python3; \
    ln -s /usr/bin/python3 /usr/bin/python; \
    apt-get -y install python3-pip; \
    ln -s /usr/bin/pip3 /usr/bin/pip
    

# Install python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt


# Instal toree for jupyter
RUN pip install --upgrade toree; \
	jupyter toree install --spark_home=/usr/local/spark --sys-prefix ;\
	pip install notebook


WORKDIR /opt/project

