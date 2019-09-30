# docker-gitlab-runner

Docker gitlab runner with automatic registration/deregistration based on docker run/stop.

DinD mode

Use in `.gitlab-ci.yml` :

```
image: docker:stable
variables:
  DOCKER_HOST: tcp://docker:2375/
  DOCKER_DRIVER: overlay2
services:
  - docker:dind
```

Needs secrets `gitlab_runner_token`