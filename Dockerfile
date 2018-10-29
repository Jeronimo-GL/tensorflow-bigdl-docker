FROM ubuntu:18.04

RUN apt-get update; \
    apt-get install -y wget unzip

RUN cd ~

# Install java
RUN apt-get install -y openjdk-8-jdk


# Install Scala
RUN  apt-get remove scala-library scala; \
     wget www.scala-lang.org/files/archive/scala-2.11.8.deb; \
     dpkg -i scala-2.11.8.deb; \
     rm scala-2.11.8.deb

# Install sbt
RUN apt-get -y install gnupg2
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823; 
RUN apt-get update;
RUN apt-get -y install sbt
    

# Install spark
RUN wget https://archive.apache.org/dist/spark/spark-2.1.2/spark-2.1.2-bin-hadoop2.7.tgz; \
    tar -xvf spark-2.1.2-bin-hadoop2.7.tgz; \
    mv spark-2.1.2-bin-hadoop2.7 /usr/local/; \
    ln -s /usr/local/spark-2.1.2-bin-hadoop2.7/ /usr/local/spark; \
    export SPARK_HOME=/usr/local/spark; \
    rm spark-2.1.2-bin-hadoop2.7.tgz;
    
    
# Install bigDL
RUN wget https://repo1.maven.org/maven2/com/intel/analytics/bigdl/dist-spark-2.1.1-scala-2.11.8-all/0.7.0/dist-spark-2.1.1-scala-2.11.8-all-0.7.0-dist.zip; \
     unzip dist-spark-2.1.1-scala-2.11.8-all-0.7.0-dist.zip -d /opt/bigdl; \
     rm dist-spark-2.1.1-scala-2.11.8-all-0.7.0-dist.zip; \
     cp /opt/bigdl/lib/* /usr/local/spark-2.1.2-bin-hadoop2.7/jars/

RUN apt-get install -y gcc


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

