.DEFAULT_GOAL := help

# Variables
SHELL ?= /bin/bash

# Container related
PROJECT_BASE=/opt/project

# Spark related
SPARK_PATH=/usr/local/spark

# BigDL
BIGDL_DIST=/opt/bigdl
BIGDL_PY_ZIP=$(BIGDL_DIST)/lib/bigdl-0.13.0-python-api.zip
BIGDL_JAR=$(BIGDL_DIST)/lib/bigdl-SPARK_3.0-0.13.0-jar-with-dependencies.jar
BIGDL_CONF=$(BIGDL_DIST)/conf/spark-bigdl.conf


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

polynote: ## Launches polynote
	@docker exec -ti \
		${CONTAINER_NAME} \
		python3 /opt/polynote/polynote.py


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
	docker build -t ${TARGET_IMAGE} .


