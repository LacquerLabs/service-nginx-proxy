.DEFAULT_GOAL := help

VERSION = 0.0.1
NAME = nginxproxy
PORT_INTERNAL = 80
PORT_EXTERNAL = 8000

build: ## Build it
	docker build --pull -t $(NAME) .

buildnocache: ## Build it without using cache
	docker build --pull -t $(NAME) --no-cache .

run: ## run it -v ${PWD}/code:/app/code
	docker run -p $(PORT_EXTERNAL):$(PORT_INTERNAL) -v /var/run/docker.sock:/tmp/docker.sock:ro --name $(NAME)_run --rm -id $(NAME)

runshell: ## run the container with an interactive shell
	docker run -p $(PORT_EXTERNAL):$(PORT_INTERNAL) -v /var/run/docker.sock:/tmp/docker.sock:ro --name $(NAME)_run --rm -it $(NAME) /bin/sh

connect: ## connect to it
	docker exec -it $(NAME)_run /bin/sh

watchlog: ## connect to it
	docker logs -f $(NAME)_run

kill: ## kill it
	docker kill $(NAME)_run

it: build run connect kill ## do it all

.PHONY: help

help: ## Helping devs since 2016
	@cat $(MAKEFILE_LIST) | grep -e "^[a-zA-Z_\-]*: *.*## *" | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo "For additional commands have a look at the README"


