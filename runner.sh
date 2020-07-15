#!/usr/bin/env bash
set -x

pid=0
# token=()
gitlab_service_url=https://${GITLAB_HOST}

TOKEN=${GITLAB_RUNNER_TOKEN}
if [[ -z $TOKEN ]]; then
  echo "Env var GITLAB_RUNNER_TOKEN is empty, trying to use secret gitlab_runner_token..."
  TOKEN=$(cat /run/secrets/gitlab_runner_token)
  echo "Using gitlab_runner_token secret (${TOKEN})..."
else
  echo "Using GITLAB_RUNNER_TOKEN env var (${TOKEN})..."
fi

# SIGTERM-handler
unregister_runner() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  gitlab-runner unregister --url ${gitlab_service_url} --name "runner-$(hostname -f)"
  exit 143; # 128 + 15 -- SIGTERM
}

# setup handlers
# on callback, kill the last background process, which is `tail -f /dev/null` and execute the specified handler
# trap 'kill ${!}; unregister_runner' SIGTERM
trap unregister_runner HUP INT QUIT ABRT KILL ALRM TERM TSTP

# register runner
yes '' | gitlab-runner register --url ${gitlab_service_url} \
                                --registration-token ${TOKEN} \
                                --executor docker \
                                --name "runner-$(hostname -f)" \
                                --output-limit "20480" \
                                --docker-image "docker:latest" \
                                --docker-volumes "/certs/client" "/root/m2:/root/.m2" "/srv/cache:/cache:rw" \
                                --docker-privileged \
                                --docker-extra-hosts ${GITLAB_HOST}:${GITLAB_IP}

# assign runner token
# token=$(cat /etc/gitlab-runner/config.toml | grep token | awk '{print $3}' | tr -d '"')

# run multi-runner
gitlab-ci-multi-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner & pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
