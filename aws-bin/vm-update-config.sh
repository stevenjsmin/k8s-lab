#!/usr/bin/env bash

CONFIG="$HOME/.ssh/config"
BACKUP="$CONFIG.bak.$(date +%Y%m%d%H%M%S)"


# HostName 갱신 함수 (awk 사용: macOS/BSD sed 차이 회피)
update_host() {
  local host="$1"
  local ip="$2"

  echo "Updating $CONFIG $host -> $ip"

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
  ' "$CONFIG" > "$CONFIG.tmp"; then
    mv "$CONFIG.tmp" "$CONFIG"
    chmod 600 "$CONFIG"
    echo "  -> Updated existing Host block."
  fi
}


# AWS CLI에서 PublicIP와 Name을 탭으로 구분해 출력
instances=$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].[PublicIpAddress, Tags[?Key==`Name`].Value|[0]]' \
  --output text)

# 탭 기준으로 안전하게 파싱 (Name에 공백이 있어도 안전)
while IFS=$'\t' read -r ip name; do
  # 빈 라인/빈 값 방어
  [[ -z "${ip:-}" || -z "${name:-}" ]] && continue

  case "$name" in
    k8s-controlPlane|k8s-workNode1|k8s-workNode2|k8s-client|lab1|OpenShift-local)
      update_host "$name" "$ip"
      ;;
    *) : ;;  # 그 외 이름은 무시
  esac
done <<< "$instances"

