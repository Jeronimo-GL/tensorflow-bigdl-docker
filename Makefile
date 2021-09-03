.DEFAULT_GOAL := help

# Variables
SHELL ?= /bin/bash

# Container related
PROJECT_BASE=/opt/project

# Spark related
BASE_DIRECTORY=/usr/local
SPARK_VERSION=spark-2.3.3-bin-hadoop2.7
SPARK_PATH=$(BASE_DIRECTORY)/$(SPARK_VERSION)

# BigDL
BIGDL_DIST=/opt/bigdl
BIGDL_PY_ZIP=$(BIGDL_DIST)/lib/bigdl-0.9.0-python-api.zip
BIGDL_JAR=$(BIGDL_DIST)/lib/bigdl-SPARK_2.3-0.9.0-jar-with-dependencies.jar
BIGDL_CONF=$(BIGDL_DIST)/conf/spark-bigdl.conf
JUPYTER_NET_OPTS="--ip=0.0.0.0 --allow-root --port=8080"
JUPYTER_CALL="notebook --notebook-dir=/opt/project/notebooks --no-browser --NotebookApp.token='' "
JUPYTER_OPTS= $(JUPYTER_CALL)$(JUPYTER_NET_OPTS)

# Docker relater
TARGET_IMAGE=jeronimogl/tf2bigdl:2.4.8
CONTAINER_NAME=spark_tf

# Generic
TIMESTAMP=$(shell date +"%Y%m%d%H%M%S")

PHONY: help


help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


# Commands
python-shell: ## Start python3
	@docker exec -ti \
		${CONTAINER_NAME} \
		python


spark-shell: ## Starts a spark-shell console
	@docker exec -ti \
		${CONTAINER_NAME} \
		${SPARK_PATH}/bin/spark-shell \
		  --properties-file ${BIGDL_CONF} \
		  --jars ${BIGDL_JAR} \
		  --conf spark.driver.extraJavaOptions=-Dderby.system.home=/tmp \
		  --conf spark.sql.warehouse.dir=/tmp \
		  --conf spark.driver.extraClassPath=${BIGDL_JAR} \
		  --conf spark.executor.extraClassPath=${BIGDL_JAR}

pyspark: ## Starts a spark-shell console
	@docker exec -ti \
		-e PYTHONPATH=${BIGDL_PY_ZIP} \
		${CONTAINER_NAME}\
		${SPARK_PATH}/bin/pyspark \
		  --properties-file ${BIGDL_CONF} \
		  --py-files ${BIGDL_PY_ZIP} \
		  --jars ${BIGDL_JAR} \
		  --conf spark.driver.extraJavaOptions=-Dderby.system.home=/tmp \
		  --conf spark.sql.warehouse.dir=/tmp \
		  --conf spark.driver.extraClassPath=${BIGDL_JAR} \
		  --conf spark.executor.extraClassPath=${BIGDL_JAR}

shell:  ## Shell to the container
	@docker exec -ti \
		${CONTAINER_NAME}\
		bash

docker-start: ## Start the container
	@docker run -d -ti \
		--rm \
		--name ${CONTAINER_NAME} \
		--net=host \
		-p 8888:8888 \
		-p 4040:4040 \
		-p 6006:6006 \
		-v ${PWD}:${PROJECT_BASE} \
		${TARGET_IMAGE}


# --allow-root
docker-stop: ## Stops the container
	@docker stop \
		${CONTAINER_NAME} 

lab: ## Launches jupyter-lab
	@docker exec -ti \
		${CONTAINER_NAME} \
		jupyter lab \
		--allow-root \
		--notebook-dir=/opt/project/notebooks

tensorboard: ## Starts tensorboard
	@echo http://localhost:6006;
	@docker exec -ti \
		${CONTAINER_NAME} \
		tensorboard --logdir  models/iris-graph/session


sbt-build: ## Builds the JAR file
	@docker exec -ti \
		${CONTAINER_NAME} \
		sbt package


docker-build:  ## Build the docker images
	docker build --no-cache -t ${TARGET_IMAGE} .


