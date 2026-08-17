#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# check-leftover.sh: destroy 후 계정에 과금되는 리소스가 남았는지 확인합니다.
#
#   "terraform state list 가 비었다" ≠ "계정이 비었다"
#   콘솔 클릭 대신 이 스크립트 한 번으로 확인하세요. (실습워크북 C-3)
#
# week4도 week3과 같은 방식입니다:
#   week3에서 만든 S3 버킷과 DynamoDB 테이블은 7주차까지 남겨 둡니다.
#   그래서 Purpose 태그로 두 부류를 갈라서 봅니다.
#     Purpose = workload         → 오늘 반드시 0개여야 합니다
#     Purpose = terraform-state  → 남아 있어야 정상입니다
#
# 사용법:
#   ./scripts/check-leftover.sh
#   REGION=us-east-1 ./scripts/check-leftover.sh
# ---------------------------------------------------------------------------
set -uo pipefail

R="${REGION:-ap-northeast-2}"
# providers.tf 의 default_tags 와 같은 값입니다.
# 다른 프로젝트 리소스나 기본 VPC를 "남았다"고 오탐하지 않기 위한 필터입니다.
STUDY_TAG="${STUDY_TAG:-boaz-terraform-26}"
FOUND=0

hr() { printf '%s\n' "----------------------------------------------------------"; }

if ! command -v aws >/dev/null 2>&1; then
  echo "aws CLI 가 없습니다. 콘솔에서 직접 확인하세요. (실습워크북 C-3 대체 절차)"
  exit 2
fi

echo "리전: $R"
echo "필터: tag:Study = $STUDY_TAG  (다르게 쓰려면 STUDY_TAG=... 로 실행)"
echo "계정: $(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo '자격증명 실패')"
hr

check() {
  local label="$1" count="$2" detail="$3"
  if [ "$count" = "0" ] || [ -z "$count" ] || [ "$count" = "None" ]; then
    printf '  OK    %-30s 0\n' "$label"
  else
    printf '  남음  %-30s %s\n' "$label" "$count"
    [ -n "$detail" ] && printf '%s\n' "$detail"
    FOUND=1
  fi
}

echo "[1] 오늘 지웠어야 하는 것 (Purpose=workload)"
hr

# 살아있는 EC2 인스턴스. terminated 는 제외합니다(이미 죽은 것).
# 태그로 좁히지 않습니다. 콘솔에서 손으로 띄운 인스턴스도 잡아야 하기 때문입니다.
LIVE=$(aws ec2 describe-instances --region "$R" \
  --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'length(Reservations[].Instances[])' --output text 2>/dev/null)
LIVE_D=$(aws ec2 describe-instances --region "$R" \
  --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
  --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' \
  --output text 2>/dev/null)
check "EC2 인스턴스 (과금!)" "$LIVE" "$LIVE_D"

# 붙은 데 없는 EBS 볼륨. GB-월로 계속 과금됩니다.
# stop 은 destroy 가 아닙니다. 인스턴스를 멈춰도 이 볼륨 요금은 계속 나갑니다.
VOL=$(aws ec2 describe-volumes --region "$R" --filters Name=status,Values=available \
  --query 'length(Volumes)' --output text 2>/dev/null)
VOL_D=$(aws ec2 describe-volumes --region "$R" --filters Name=status,Values=available \
  --query 'Volumes[].[VolumeId,Size,VolumeType,CreateTime]' --output text 2>/dev/null)
check "미사용 EBS 볼륨 (과금!)" "$VOL" "$VOL_D"

# Elastic IP. 유휴 상태에서도 시간당 과금됩니다. 이번 실습은 아예 만들지 않습니다.
EIP=$(aws ec2 describe-addresses --region "$R" --query 'length(Addresses)' --output text 2>/dev/null)
EIP_D=$(aws ec2 describe-addresses --region "$R" \
  --query 'Addresses[].[PublicIp,AllocationId,AssociationId]' --output text 2>/dev/null)
check "Elastic IP (과금!)" "$EIP" "$EIP_D"

# NAT Gateway. 이번 실습에서는 아예 만들지 않아야 합니다.
NAT=$(aws ec2 describe-nat-gateways --region "$R" \
  --filter Name=state,Values=pending,available,deleting \
  --query 'length(NatGateways)' --output text 2>/dev/null)
NAT_D=$(aws ec2 describe-nat-gateways --region "$R" \
  --filter Name=state,Values=pending,available,deleting \
  --query 'NatGateways[].[NatGatewayId,State,VpcId]' --output text 2>/dev/null)
check "NAT Gateway (과금!)" "$NAT" "$NAT_D"

# app 스택이 만든 VPC. 무료지만 리전당 5개 제한이라 다음 주 VpcLimitExceeded 를 예방합니다.
VPC=$(aws ec2 describe-vpcs --region "$R" \
  --filters "Name=tag:Study,Values=$STUDY_TAG" "Name=tag:Purpose,Values=workload" \
  --query 'length(Vpcs)' --output text 2>/dev/null)
VPC_D=$(aws ec2 describe-vpcs --region "$R" \
  --filters "Name=tag:Study,Values=$STUDY_TAG" "Name=tag:Purpose,Values=workload" \
  --query 'Vpcs[].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output text 2>/dev/null)
check "workload VPC (무료·개수제한)" "$VPC" "$VPC_D"

hr
echo "[2] 7주차까지 남겨 두는 것 (week3 에서 만든 state 저장소)"
echo "    여기는 0개가 아니어야 정상입니다. 이번 주 state가 그 버킷 안에 들어 있습니다."
hr

# state 버킷. 버킷 목록은 리전 필터가 없으므로 이름으로 찾습니다.
BUCKETS=$(aws s3api list-buckets \
  --query 'Buckets[?ends_with(Name, `-tfstate`)].Name' --output text 2>/dev/null)
if [ -n "${BUCKETS// /}" ]; then
  printf '  유지  %-30s %s\n' "state S3 버킷" "$BUCKETS"
  for b in $BUCKETS; do
    n=$(aws s3api list-objects-v2 --bucket "$b" --prefix "week04/" \
      --query 'length(Contents)' --output text 2>/dev/null)
    printf '        └ week04/ 객체 %s개 (state가 원격에 있으면 1개)\n' "${n:-0}"
  done
else
  printf '  확인  %-30s 없음. week3 의 bootstrap 을 apply 하지 않았거나 이미 지웠습니다\n' "state S3 버킷"
fi

TABLES=$(aws dynamodb list-tables --region "$R" \
  --query 'TableNames[?ends_with(@, `-tflock`)]' --output text 2>/dev/null)
if [ -n "${TABLES// /}" ]; then
  printf '  유지  %-30s %s\n' "잠금 DynamoDB 테이블" "$TABLES"
  for t in $TABLES; do
    n=$(aws dynamodb scan --region "$R" --table-name "$t" \
      --query 'Count' --output text 2>/dev/null)
    printf '        └ 항목 %s개 (잠금 항목은 apply 중에만. 나머지는 state 체크섬)\n' "${n:-?}"
  done
else
  printf '  확인  %-30s 없음\n' "잠금 DynamoDB 테이블"
fi

hr
if [ "$FOUND" = "0" ]; then
  echo "  workload 전부 0. 정리 완료. 오늘 실습 끝!"
else
  echo "  workload 에 남은 것이 있습니다. practice/ 에서 terraform destroy 를 다시 실행하세요."
  echo "  EBS/EIP/NAT 검사는 계정 전체를 보므로 다른 프로젝트 것이 잡혔을 수도 있습니다."
  echo "  출력된 ID의 Name 태그로 내 것인지 확인하세요."
fi

# 리전 착각 대비 스윕
hr
echo "다른 리전에 실수로 만든 것이 없는지:"
for r in ap-northeast-2 us-east-1 ap-northeast-1; do
  n=$(aws ec2 describe-instances --region "$r" \
    --filters "Name=instance-state-name,Values=pending,running,stopping,stopped" \
    --query 'length(Reservations[].Instances[])' --output text 2>/dev/null)
  printf '  %-18s 살아있는 인스턴스 %s\n' "$r" "${n:-?}"
done
