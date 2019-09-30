#!/usr/bin/env bash
set -x

pid=0
token=()
gitlab_service_url=https://${GITLAB_HOST}

TOKEN=${GITLAB_RUNNER_TOKEN:-}

if [[ -e $TOKEN ]]; then
  TOKEN=$(cat /run/secrets/gitlab_register_token)
fi

# SIGTERM-handler
unregister_runner() {
  if [ $pid -ne 0 ]; then
    kill -SIGTERM "$pid"
    wait "$pid"
  fi
  gitlab-runner unregister -u ${gitlab_service_url} -t ${TOKEN}
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
                                --docker-volumes /root/m2:/root/.m2 \
                                --docker-privileged \
                                --docker-extra-hosts ${GITLAB_HOST}:${GITLAB_IP}

# assign runner token
token=$(cat /etc/gitlab-runner/config.toml | grep token | awk '{print $3}' | tr -d '"')

# run multi-runner
gitlab-ci-multi-runner run --user=gitlab-runner --working-directory=/home/gitlab-runner & pid="$!"

# wait forever
while true
do
  tail -f /dev/null & wait ${!}
done
