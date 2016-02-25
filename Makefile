R_VERSION = "R-3.2.3"
FOLDER_VAR = "$(shell pwd)/var"
FOLDER_OUT = "$(shell pwd)/out"
FOLDER_PROJECTS = "$(shell pwd)/projects"

all: ready


ready: ready-projects ready-wurst-vector ready-wurst-imbiss ready-wurst-graph ready-wurst-cluster ready-wurst-merge ready-wurst-export
	
ready-projects:
	@set -e
	@echo "create projects folder"
	@mkdir -p $(FOLDER_PROJECTS)

ready-wurst-vector:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-vector
	@git clone https://github.com/AlexWoroschilow/wurst-update.git $(FOLDER_PROJECTS)/wurst-vector

ready-wurst-imbiss:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-imbiss
	@git clone https://github.com/AlexWoroschilow/wurst-imbiss.git $(FOLDER_PROJECTS)/wurst-imbiss

ready-wurst-graph:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-graph

ready-wurst-cluster:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-cluster
	@git clone https://github.com/AlexWoroschilow/wurst-cluster.git $(FOLDER_PROJECTS)/wurst-cluster

ready-wurst-merge:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-merge

ready-wurst-export:
	@mkdir -p $(FOLDER_PROJECTS)/wurst-export
