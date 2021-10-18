FROM ubuntu:21.10

RUN apt-get update; \
    apt-get install -y wget unzip gcc vim

RUN cd ~

# Install java
RUN apt-get install -y openjdk-8-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


# Install Scala
ENV SCALA_DEB=scala-2.12.15.deb
ENV SCALA_URL=www.scala-lang.org/files/archive/${SCALA_DEB}

RUN  apt-get remove scala-library scala; \
     wget ${SCALA_URL}; \
     dpkg -i ${SCALA_DEB}; \
     rm ${SCALA_DEB}
ENV SCALA_HOME=/usr/share/scala

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
ENV SPARK_DEST_DIR=/usr/local/spark

RUN wget ${SPARK_URL}; \
    tar -xvf ${SPARK_FILE}; \
    mv ${SPARK_VERSION} /usr/local/; \
    ln -s /usr/local/${SPARK_VERSION}/ $SPARK_DEST_DIR; \
    export SPARK_HOME=$SPARK_DEST_DIR; \
    rm ${SPARK_FILE};
ENV SPARK_HOME=$SPARK_DEST_DIR
    


# Install bigDL
ENV BIGDL_ZIP=dist-spark-3.0.0-scala-2.12.10-all-0.13.0-dist.zip
ENV BIGDL_URL=https://repo1.maven.org/maven2/com/intel/analytics/bigdl/dist-spark-3.0.0-scala-2.12.10-all/0.13.0/${BIGDL_ZIP}

RUN wget ${BIGDL_URL};  \
     unzip ${BIGDL_ZIP} -d /opt/bigdl; \
     rm ${BIGDL_ZIP}; \
     cp /opt/bigdl/lib/* $SPARK_DEST_DIR/jars/; \
     export BIGDL_HOME=/opt/bigdl

# Install python
RUN apt-get -y install python3-pip; 


# Install python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt


# Instal toree for jupyter
ENV TOREE_URL=https://dist.apache.org/repos/dist/dev/incubator/toree/0.5.0-incubating-rc4/toree-pip/toree-0.5.0.tar.gz
RUN pip install --upgrade $TOREE_URL; \
    jupyter toree install \
    --interpreters=Scala,SQL \
    --spark_home=$SPARK_DEST_DIR ; \
    pip install notebook ; \
    pip install --upgrade pyspark


ENV POLYNOTE_URL=https://github.com/polynote/polynote/releases/download/0.4.2/polynote-dist.tar.gz
RUN cd /opt; \
    wget ${POLYNOTE_URL}; \
    tar -zxvpf polynote-dist.tar.gz; \
    rm polynote-dist.tar.gz; \
    cd polynote; \
    pip3 install -r requirements.txt;


RUN beakerx install

ENV PATH=${PATH}:$JAVA_HOME:$SCALA_HOME:$SPARK_HOME
WORKDIR /opt/project

