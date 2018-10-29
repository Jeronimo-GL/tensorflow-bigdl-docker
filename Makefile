.DEFAULT_GOAL := help

# Variables
SHELL ?= /bin/bash

# Spark
BASE_DIRECTORY=/usr/local
SPARK_VERSION=spark-2.1.2-bin-hadoop2.7
SPARK_PATH=$(BASE_DIRECTORY)/$(SPARK_VERSION)

# BigDL
BIGDL_DIST=/opt/bigdl

# Docker
TARGET_IMAGE=jeronimogl/tf2bigdl:2.1.2
CONTAINER_NAME=spark_tf

# Container
PROJECT_BASE=/opt/project
TB_LOGDIR=/opt/logdir

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
		${CONTAINER_NAME}\
		${SPARK_PATH}/bin/spark-shell


shell:  ## Shell to the container
	@docker exec -ti \
		${CONTAINER_NAME}\
		bash

docker-start: ## Start the container
	@docker run -d -ti \
		--rm \
		--name ${CONTAINER_NAME} \
		-p 8080:8080 \
		-p 4040:4040 \
		-p 6006:6006 \
		-v ${PWD}:${PROJECT_BASE} \
		${TARGET_IMAGE}

docker-stop: ## Stops the container
	@docker stop \
		${CONTAINER_NAME} 

jupyter: ## launches jupyter notebook
	@echo http://localhost:8080;
	@docker exec -ti \
		${CONTAINER_NAME} \
		jupyter notebook --ip=0.0.0.0 --port=8080 --allow-root --notebook-dir=${PROJECT_BASE}/notebooks --NotebookApp.token=

tensorboard: ## Starts tensorboard
	@echo http://localhost:6006;
	@docker exec -ti \
		${CONTAINER_NAME} \
		tensorboard --logdir ${TB_LOGDIR}

sbt-build: ## Builds the JAR file
	@docker exec -ti \
		${CONTAINER_NAME} \
		sbt package


docker-build:  ## Build the docker images
	docker build -t ${TARGET_IMAGE} .


