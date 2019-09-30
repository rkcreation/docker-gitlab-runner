all: build
build: 
	docker build -t rkcreation/gitlab-runner . 
