include Make-deploy.mk

%:
	@true
.PHONY: config deps lib test tmp coverage
ARGS = $(filter-out $@, $(MAKECMDGOALS))

shell:
	docker exec -it $(shell docker container ls | grep vsc-kaize_votes | cut --delimiter=' ' --fields=1 | head --lines=1) /bin/bash

iex:
	iex -S mix

s: shell

c: iex
