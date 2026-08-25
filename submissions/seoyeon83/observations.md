#### A-2 기록

- `by_count` 세 줄을 그대로 옮겨 적기: `terraform_data.by_count[0]` / `terraform_data.by_count[1]` / `terraform_data.by_count[2]`
- `by_for_each` 세 줄을 그대로 옮겨 적기: `terraform_data.by_for_each["alpha"]` / `terraform_data.by_for_each["bravo"]` / `terraform_data.by_for_each["charlie"]`
- `"bravo"` 삭제 후 plan 마지막 줄: `Plan: 1 to add, 0 to change, 3 to destroy.`
- 교체(`-/+`)되는 `by_count`의 주소와 그 주소에서 바뀌는 값: `terraform_data.by_count[1]`. `input`과 `triggers_replace`가 `"bravo"` → `"charlie"`로 바뀜
- `by_for_each` 쪽에서 손대는 것은 몇 개이고 무엇인가: 1개. `terraform_data.by_for_each["bravo"]`만 삭제됨. `alpha`·`charlie`는 그대로

#### A-6 기록

- 일부러 넣은 잘못된 값: `primary_subnet_key=b` (subnets에 없는 key) · `my_ip=1.2.3.4/32` (이미 CIDR 표기인데 또 붙임)
- 오류 첫 줄: `Error: Invalid value for variable` (두 경우 모두 동일)
- 내가 적은 `error_message`가 그대로 나왔는가: 예. `primary_subnet_key`는 "primary_subnet_key 는 다음 중 하나여야 합니다: a, c", `my_ip`는 "my_ip는 1.2.3.4 처럼 순수 IPv4여야 합니다. /32나 CIDR을 넣지 마세요. (curl -4 ifconfig.me)"가 그대로 출력됨
- 이 오류는 plan 이 시작되기 전에 났는가, apply 도중에 났는가: plan 시작 전. `Planning failed`로 끝나고 AWS에는 아무 요청도 가지 않음. apply는 시도조차 되지 않음

#### B-5 기록

- `plan` 마지막 줄: `Plan: 9 to add, 0 to change, 0 to destroy.`
- `state list` 줄 수: 11줄 (리소스 9 + 데이터 소스 2)
- `aws_subnet.public`으로 시작하는 두 줄: `aws_subnet.public["a"]` / `aws_subnet.public["c"]`
- `terraform output subnet_ids`가 찍은 key 두 개: `a` / `c`
- `terraform output ssh_source_cidr`이 화면에 찍은 값: `<sensitive>`

#### B-6 기록

- S3 객체 키 전체: `week04/app/terraform.tfstate` (버킷 `boaz26-w3-seoyeon83-tfstate`)
- `terraform output`과 `terraform output -raw`에서 값이 각각 보였는가: 이름 없이 전체 목록을 뽑는 `terraform output`에서는 `<sensitive>`로 가려짐 / `-raw`에서는 원본 공인 IP가 그대로 나옴. (참고: output 이름을 직접 지정하면 `-raw` 없이도 가려지지 않는 것을 별도로 확인함)
- state 안에 평문으로 들어 있었는가: 예. `state pull` 결과에서 공인 IP를 검색하니 2줄에서 매치됨
- `sensitive`가 막는 것과 못 막는 것을 한 문장으로: `sensitive`는 `terraform output`으로 전체 목록을 볼 때와 plan·apply 화면 출력에서만 값을 가리고, state 파일에 저장되는 평문이나 output 이름을 직접 지정한 조회는 막지 못한다

#### B-7 기록

- 세 번째 key 추가 후 plan 마지막 줄: `Plan: 2 to add, 0 to change, 0 to destroy.`
- 기존 `["a"]` · `["c"]`에 `~`나 `-/+`가 붙었는가: 아니오. plan diff에 전혀 나타나지 않았고 output도 "(2 unchanged attributes hidden)"으로만 표시됨
- A-2의 `count` 쪽 결과와 비교해 한 문장: `count`였다면 중간에 끼어든 항목 때문에 뒤 인덱스가 밀려 기존 리소스가 교체됐겠지만(A-2에서 `charlie`가 `[2]`에서 `[1]`로 밀리며 `-/+` 발생), `for_each`는 주소가 key로 고정되어 기존 `a`·`c`는 전혀 건드리지 않고 `b`만 새로 추가됨

#### C-3 기록

- `Purpose=workload` 항목들이 전부 0인가: 예. `check-leftover.sh` 결과 EC2·EBS·EIP·NAT·workload VPC 전부 0
- week3의 S3 버킷과 DynamoDB 테이블은 남아 있는가: 예. `boaz26-w3-seoyeon83-tfstate`(week04/ 객체 1개) · `boaz26-w3-seoyeon83-tflock` 둘 다 유지됨
- `count-demo`의 `state list`는 비었는가: 아니오, 비어 있지 않음(의도한 상태). `submissions/seoyeon83/count-demo`는 과제③ 결과물(`for_each`로 옮긴 `terraform_data.by_count["alpha"|"bravo"|"charlie"]` 3개)을 증빙으로 남겨둔 것이라 일부러 destroy하지 않았음. `terraform_data`는 로컬 리소스라 과금은 없음

#### 과제③ 기록

- 3번의 순진한 전환에서 몇 개가 재생성으로 잡혔는지, 왜인지: 6개(3 destroy + 3 create)가 잡힘. `for_each`로 바꾼 리소스는 `count` 시절의 주소(`[0]` `[1]` `[2]`)와 완전히 다른 리소스로 취급되어, plan 이유도 `(because resource does not use count)`로 나옴. 기존 인덱스 3개는 삭제 대상, 새 key(`"alpha"` `"bravo"` `"charlie"`) 3개는 생성 대상이 됨
- 4번에서 고른 방법과 그 방법이 무엇을 바꾸는지: `moved` 블록(`terraform state mv` 대신 코드에 적어두는 방법)을 골랐음. `plan-fixed.txt`가 `0 to add, 0 to change, 0 to destroy`였고, apply 로그도 `0 added, 0 changed, 0 destroyed`였다. `state-before.txt`와 `state-after.txt`의 리소스 `id`(예: `6ecd9743-...`)가 그대로 유지된 것도 확인함. 즉 **실제 리소스는 전혀 건드리지 않고 state 안의 주소만 옮김**. 코드에 남아 있어서 PR 리뷰에서 "왜 재생성이 안 났는지"가 diff만 봐도 보인다는 장점이 있음
- 지금 운영 중인 서비스였다면 3번을 그대로 apply 했을 때 무슨 일이 일어났을지: `terraform_data`가 아니라 실제 인프라(EC2·DB 등)였다면 기존 3개가 destroy된 뒤 새 3개가 create됐을 것이다. 즉 서비스 중단과, 상태가 있는 리소스라면(DB 볼륨 등) 데이터 유실까지 이어졌을 것이다
