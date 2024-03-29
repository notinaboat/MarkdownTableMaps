PACKAGE := $(shell basename $(PWD))

all: README.md

README.md: src/$(PACKAGE).jl
	julia --project -e "using $(PACKAGE); $(PACKAGE).readme_docs_generate()"
