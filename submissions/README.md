# submissions

Week4 실습 제출 폴더입니다. **본인 GitHub ID로 폴더를 만들어** 제출하세요.

```
submissions/
├── kdh1834/
│   ├── backend.tf              # CHANGE-ME 를 채운 상태. 버킷 이름은 본인 것
│   ├── variables.tf
│   ├── locals.tf
│   ├── network.tf
│   ├── compute.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── versions.tf
│   ├── example.tfvars
│   ├── count-demo/             # 과제③. count 를 for_each 로 옮긴 최종본
│   │   └── main.tf
│   ├── state-before.txt        # 과제③. 주소가 [0][1][2]
│   ├── state-after.txt         # 과제③. 주소가 ["alpha"]...
│   ├── plan-naive.txt          # 과제③. 재생성이 잡힌 plan
│   ├── plan-fixed.txt          # 과제③. 0 to add, 0 to change, 0 to destroy
│   ├── state-list.txt          # destroy 후 빈 출력 (마스킹 필수)
│   └── observations.md         # 워크북 [관찰 ✍️] 답안
└── {your-github-id}/
    └── ...
```

## 규칙

- 폴더 이름은 **본인 GitHub ID**. 사람마다 폴더가 달라서 PR이 충돌하지 않고 전부 머지됩니다.
- **`practice/`는 건드리지 마세요.** 거기는 다음 사람이 풀 `# TODO` 스켈레톤입니다.
- **`terraform.tfvars`(내 공인 IP) · `terraform.tfstate` · `*.backup` · `backend.hcl` · `*.pem`은 절대 커밋 금지.** `.gitignore`가 막고 있지만 푸시 전에 `git status`로 한 번 더 확인하세요.
- 증빙에서 **두 가지를 반드시 가리세요.**
  - **공인 IP** (`x.x.x.x`). 22번이 열려 있던 서버 주소이고 `my_ip`에 넣은 본인 주소입니다
  - **계정번호 12자리.** ARN 안에 들어 있습니다 (`arn:aws:dynamodb:ap-northeast-2:123456789012:table/...`)

> [!TIP]
> `my_ip`에 `sensitive = true`를 붙였으므로 `plan` 화면에는 공인 IP가 `(sensitive value)`로 가려집니다. 그래도 `terraform output -raw`나 state 파일에는 평문으로 남습니다. 캡처와 파일을 각각 확인하세요.

## `observations.md`에 넣을 것

실습워크북의 `[관찰 ✍️]` 문항입니다.

| 스텝 | 문항 |
|------|------|
| A-2 | `by_count` · `by_for_each` 주소 · `bravo` 삭제 후 plan 마지막 줄 · 교체되는 주소와 바뀌는 값 · for_each 쪽에서 손대는 개수 |
| A-6 | 일부러 넣은 잘못된 값 · 오류 첫 줄 · 내 `error_message`가 나왔는지 · plan 전인지 apply 중인지 |
| B-5 | `plan` 마지막 줄 · `state list` 줄 수 · 서브넷 두 줄 · `subnet_ids`의 key · `ssh_source_cidr` 화면 값 |
| B-6 | S3 객체 키 · `output`과 `output -raw`의 차이 · state 안에 평문인지 · `sensitive`가 막는 것과 못 막는 것 |
| B-7 | 세 번째 key 추가 후 plan 마지막 줄 · 기존 두 개에 `~`나 `-/+`가 붙었는지 · A-2와 비교 |
| C-3 | `Purpose=workload` 전부 0인지 · week3 버킷과 테이블이 남아 있는지 · count-demo state 가 비었는지 |

과제③의 세 문항은 [`assignment/ASSIGNMENT.md`](../assignment/ASSIGNMENT.md)에 있습니다.

## 마스킹 명령

`practice`에서 destroy **후에** 실행합니다(실습워크북 C-4). `ID`를 본인 GitHub ID로 바꾸세요.

```bash
ID=본인-github-id
echo "$ID"                  # 바꿨는지 눈으로 확인
mkdir -p "../submissions/$ID"

terraform state list > "../submissions/$ID/state-list.txt"

sed -E \
  -e 's/[0-9]{12}/<account-id>/g' \
  -e 's/([0-9]{1,3}\.){3}[0-9]{1,3}/x.x.x.x/g' \
  "../submissions/$ID/state-list.txt" > "../submissions/$ID/masked.txt"
mv "../submissions/$ID/masked.txt" "../submissions/$ID/state-list.txt"
```

커밋 직전에 확인합니다. 아무것도 안 나와야 정상입니다.

```bash
git diff --cached | grep -nE '([0-9]{1,3}\.){3}[0-9]{1,3}|[0-9]{12}|AKIA[0-9A-Z]{16}'
git status --porcelain | grep -E 'terraform\.tfvars|\.tfstate|\.pem'
```

저장한 뒤 **파일을 한 번 눈으로 읽고** 커밋하세요. 스크린샷은 명령으로 걸러지지 않으니 직접 가려야 합니다.

자세한 절차는 [실습워크북 C-4](../lecture/실습워크북.md)와 [과제 문서](../assignment/ASSIGNMENT.md).
