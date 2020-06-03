FROM gitlab/gitlab-runner:latest
LABEL maintainer="Nicolas Dhers <nicolas@rkcreation.fr>"

ENV COMPOSER_CACHE_DIR /cache/composer
ENV YARN_CACHE_FOLDER /cache/yarn
ENV NPM_CONFIG_CACHE /cache/npm
ENV bower_storage__packages /cache/bower
ENV GEM_SPEC_CACHE /cache/gem
ENV PIP_DOWNLOAD_CACHE /cache/pip

ADD runner.sh /runner.sh
RUN chmod +x /runner.sh

ENTRYPOINT ["/runner.sh"]

