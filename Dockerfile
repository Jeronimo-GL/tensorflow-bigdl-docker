FROM ubuntu:20.04

RUN apt-get update; \
    apt-get install -y wget unzip gcc vim

RUN cd ~

# Install java
RUN apt-get install -y openjdk-11-jdk


# Install Scala
ENV SCALA_DEB=scala-2.12.10.deb
ENV SCALA_URL=www.scala-lang.org/files/archive/${SCALA_DEB}

RUN  apt-get remove scala-library scala; \
     wget ${SCALA_URL}; \
     dpkg -i ${SCALA_DEB}; \
     rm ${SCALA_DEB}

# Install sbt
RUN apt-get -y install gnupg2
RUN echo  "deb https://repo.scala-sbt.org/scalasbt/debian all main/" | tee -a /etc/apt/sources.list.d/sbt.list
RUN echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823; 
RUN apt-get update;
RUN apt-get -y install sbt
    

# Install spark
ENV SPARK_URL=https://archive.apache.org/dist/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz  
ENV SPARK_FILE=spark-3.1.2-bin-hadoop2.7.tgz
ENV SPARK_VERSION=spark-3.1.2-bin-hadoop2.7

RUN wget ${SPARK_URL}; \
    tar -xvf ${SPARK_FILE}; \
    mv ${SPARK_VERSION} /usr/local/; \
    ln -s /usr/local/${SPARK_VERSION}/ /usr/local/spark; \
    export SPARK_HOME=/usr/local/spark; \
    rm ${SPARK_FILE};
    


# Install bigDL
ENV BIGDL_ZIP=dist-spark-3.0.0-scala-2.12.10-all-0.13.0-dist.zip
ENV BIGDL_URL=https://repo1.maven.org/maven2/com/intel/analytics/bigdl/dist-spark-3.0.0-scala-2.12.10-all/0.13.0/${BIGDL_ZIP}

RUN wget ${BIGDL_URL};  \
     unzip ${BIGDL_ZIP} -d /opt/bigdl; \
     rm ${BIGDL_ZIP}; \
     cp /opt/bigdl/lib/* /usr/local/spark/jars/; \
     export BIGDL_HOME=/opt/bigdl

# Install python
RUN apt-get -y install python3-pip; 


# Install python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt


# Instal toree for jupyter
RUN pip install --upgrade toree; \
    jupyter toree install \
    --interpreters=Scala,SQL \
    --spark_home=/usr/local/spark --sys-prefix ;\
	pip install notebook

ENV POLYNOTE_URL=https://github.com/polynote/polynote/releases/download/0.4.2/polynote-dist.tar.gz
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
RUN cd /opt; \
    wget ${POLYNOTE_URL}; \
    tar -zxvpf polynote-dist.tar.gz; \
    rm polynote-dist.tar.gz; \
    cd polynote; \
    pip3 install -r requirements.txt;

RUN beakerx install
WORKDIR /opt/project

