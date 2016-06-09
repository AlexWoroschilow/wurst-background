R_VERSION = "R-3.2.3"
FOLDER_VAR = "$(shell pwd)/var"
FOLDER_OUT = "$(shell pwd)/out"
FOLDER_SOURCE = "$(shell pwd)/source"
FOLDER_BUILD = "$(shell pwd)/build"

all: ready

test:
	@echo $(R_VERSION)
	@echo $(FOLDER_VAR)
	@echo $(FOLDER_OUT)
	@echo $(FOLDER_SOURCE)
	@echo $(FOLDER_BUILD)

clean:
	@set -e
	@rm -rf $(FOLDER_SOURCE)
	@rm -rf $(FOLDER_BUILD)

ready:
	@set -e
	@echo "create var folder"
	@mkdir -p $(FOLDER_VAR)
	@echo "create out folder"
	@mkdir -p $(FOLDER_OUT)
	@echo "install latest version of R"
	@mkdir -p $(FOLDER_SOURCE)
	@wget -c --directory-prefix=$(FOLDER_SOURCE) https://cran.r-project.org/src/base/R-3/$(R_VERSION).tar.gz
	@tar -xvf $(FOLDER_SOURCE)/$(R_VERSION).tar.gz -C $(FOLDER_SOURCE)
	@echo "install igraph package"
	@ cd $(FOLDER_SOURCE)/$(R_VERSION);  \
		./configure prefix="$(FOLDER_BUILD)"
	@make -C $(FOLDER_SOURCE)/$(R_VERSION)
	@make install -C $(FOLDER_SOURCE)/$(R_VERSION)
	@$(FOLDER_BUILD)/bin/Rscript -e 'install.packages("igraph", repos="http://cran.rstudio.com/")'
	@echo "done"
	
