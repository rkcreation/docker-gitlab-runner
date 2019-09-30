FROM gitlab/gitlab-runner:latest
MAINTAINER Nicolas Dhers <nicolas@rkcreation.fr>

ADD runner.sh /runner.sh
RUN chmod +x /runner.sh

ENTRYPOINT ["/runner.sh"]

