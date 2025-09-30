#!/usr/bin/env bash

SSH_CONFIG="$HOME/.ssh/config"
POLL_INTERVAL="${POLL_INTERVAL:-3}"
TIMEOUT="${TIMEOUT:-300}"

update_host() {
  local host="$1"
  local ip="$2"

  echo "Updating $SSH_CONFIG $host -> $ip"

  if awk -v host="$host" -v ip="$ip" '
    BEGIN{updated=0}
    # Host <host> 라인을 만나면 처리
    $1=="Host" && $2==host && updated==0 {
      print;                                # Host 라인 그대로
      if (getline nextline) {               # 다음 줄 확인
        if (nextline ~ /^[[:space:]]*HostName[[:space:]]+/) {
          sub(/^[[:space:]]*HostName[[:space:]]+.*/, "    HostName " ip, nextline)
          print nextline
        } else {
          print "    HostName " ip
          print nextline
        }
      } else {
        print "    HostName " ip
      }
      updated=1
      next
    }
    { print }
    END{
      if (updated==0) exit 2
    }
  ' "$SSH_CONFIG" > "$SSH_CONFIG.tmp"; then
    mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    echo "  -> Updated existing Host block."
  fi
}


for OUTPUT in $(aws ec2 describe-instances --filters "Name=instance-state-name,Values=stopped" --output text --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value | [0], `jenkins`)].InstanceId')
do
    aws ec2 start-instances --instance-ids ${OUTPUT}
done


INSTANCE_ID="$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=jenkins" "Name=instance-state-name,Values=pending,stopping,stopped,running" \
  --query 'sort_by(Reservations[].Instances[], &LaunchTime)[-1].InstanceId' --output text || true)"

STATE="$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].State.Name' --output text)"

if [[ "${STATE}" != "running" ]]; then
  echo "[INFO] INSTANCE STATUS: ${STATE} -> Trying bootup ec2"
  aws ec2 start-instances --instance-ids "${INSTANCE_ID}" >/dev/null
  echo "[INFO] running WAIT STATUS (waiter 사용)..."
  aws ec2 wait instance-running --instance-ids "${INSTANCE_ID}"
else
  echo "[INFO] Already running ......"
fi

echo "[INFO] Wait Public IP assign..."
deadline=$((SECONDS + TIMEOUT))
PUBLIC_IP=""
while :; do
  PUBLIC_IP="$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text || true)"
  if [[ -n "${PUBLIC_IP}" && "${PUBLIC_IP}" != "None" ]]; then
    echo "[INFO] Gocha Public IP : ${PUBLIC_IP}"
    break
  fi
  if (( SECONDS >= deadline )); then
    echo "[ERROR] ${TIMEOUT}s - Timeouted to lookup public IP."
    echo "        - 서브넷의 Auto-assign public IPv4가 꺼져 있거나, EIP 미연결일 수 있습니다."
    exit 2
  fi
  sleep "${POLL_INTERVAL}"
done



# DEBUG...
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*jenkins*" "Name=instance-state-name,Values=running,pending" \
  --query 'Reservations[].Instances[].{Name: Tags[?Key==`Name`]|[0].Value, PublicIP: PublicIpAddress}' \
  --output table

BACKUP_SUFFIX="$(date +'%Y%m%d-%H%M%S')"

AWS_ARGS=(ec2 describe-instances
  --filters "Name=tag:Name,Values=jenkins" "Name=instance-state-name,Values=running"
  --query "sort_by(Reservations[].Instances[] | [?PublicIpAddress!=null], &LaunchTime)[-1].PublicIpAddress"
  --output text
)

# /etc/hosts 백업
echo "[INFO] Created Backup for /etc/hosts : ~/Downloads/hosts.bak.${BACKUP_SUFFIX}"
cp /etc/hosts ~/Downloads/hosts.bak.${BACKUP_SUFFIX}



# ~/.ssh/config에 'jenkins' 라인이 이미 있는지 확인(주석 제외)
if grep -qE '^[[:space:]]*[^#].*\b'"jenkins"'\b' ~/.ssh/config; then
  echo "[INFO] Update exist 'jenkins' line to ${PUBLIC_IP}"
  # macOS sed: -i '' (백업은 위에서 이미 생성)
   sed -E -i '' -e "s/^([[:space:]]*)([0-9A-Fa-f:.]+)([[:space:]]+[^#]*[[:<:]]jenkins[[:>:]][^#]*)([[:space:]]*#.*)?$/\1${PUBLIC_IP}\3\4/" ~/.ssh/config
   update_host "jenkins" "$PUBLIC_IP"
else
  echo "[INFO] In the 'jenkins', there is no Jenkins line"
fi

# /etc/hosts 에 'jenkins' 라인이 이미 있는지 확인(주석 제외)
if grep -qE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts"; then
  echo "[INFO] Update existing 'jenkins' line to ${PUBLIC_IP}"
  # macOS sed: -i '' (백업은 위에서 이미 생성)
   sudo sed -E -i '' -e "s/^([[:space:]]*)([0-9A-Fa-f:.]+)([[:space:]]+[^#]*[[:<:]]jenkins[[:>:]][^#]*)([[:space:]]*#.*)?$/\1${PUBLIC_IP}\3\4/" /etc/hosts
else
  echo "[INFO] There is no Jenkins line"
fi


# 결과 표시
#grep -nE '^[[:space:]]*[^#].*\b'"jenkins"'\b' ~/.ssh/config || true
#grep -nE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts" || true

echo "[DONE]"
echo ""
echo ""















































#echo "[INFO] EC2(Name=jenkins) 의 Public IP 조회 중..."
#IP="$(aws "${AWS_ARGS[@]}" || true)"
#
#if [[ -z "${IP}" || "${IP}" == "None" ]]; then
#  echo "[ERROR] 실행 중(running)이며 Public IP가 있는 'jenkins' 인스턴스를 찾지 못했습니다."
#  exit 2
#fi
#
#echo "[INFO] 발견된 Public IP: ${IP}"
#
## /etc/hosts 백업
#echo "[INFO] /etc/hosts 백업 생성: ~/Downloads/hosts.bak.${BACKUP_SUFFIX}"
#cp /etc/hosts ~/Downloads/hosts.bak.${BACKUP_SUFFIX}
#
#
#
## /etc/hosts 에 'jenkins' 라인이 이미 있는지 확인(주석 제외)
#if grep -qE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts"; then
#  echo "[INFO] 기존 'jenkins' 라인을 ${IP}로 갱신합니다."
#  # macOS sed: -i '' (백업은 위에서 이미 생성)
#   sudo sed -E -i '' -e "s/^([[:space:]]*)([0-9A-Fa-f:.]+)([[:space:]]+[^#]*[[:<:]]jenkins[[:>:]][^#]*)([[:space:]]*#.*)?$/\1${IP}\3\4/" /etc/hosts
#else
#  echo "[INFO] 'jenkins'에 Jenkins 라인이 없습니다."
#fi
#
## 결과 표시
#echo "[INFO] 적용된 /etc/hosts 의 'jenkins' 항목:"
#grep -nE '^[[:space:]]*[^#].*\b'"jenkins"'\b' "/etc/hosts" || true
#
#echo "[DONE] hosts 업데이트 완료."
