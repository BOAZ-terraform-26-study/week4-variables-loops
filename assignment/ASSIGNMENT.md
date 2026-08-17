# Week4 과제③ (다음 리뷰: Week5)

| 항목 | 내용 |
|------|------|
| 마감 | TBD |
| 배점 | TBD |
| 리뷰 | Week5 과제 리뷰 5분 |

## 목표

이미 `count`로 만들어 apply 까지 끝낸 리소스를 `for_each`로 옮깁니다. 재생성 없이 옮기는 것이 조건입니다.

실습 A-2에서 목록 가운데를 지웠을 때 `count` 쪽이 교체되는 것을 봤습니다. 그러면 이미 운영 중인 코드를 `for_each`로 바꾸려고 할 때도 같은 일이 일어납니다. 그냥 바꾸면 리소스가 전부 지워지고 다시 만들어집니다. 이 과제는 그 상태에서 빠져나오는 방법을 찾는 것입니다.

무과금 샌드박스에서 합니다. AWS 자격증명도 필요 없습니다.

## 코드로 해야 하는 것

1. `practice/count-demo/`를 `submissions/{본인-github-id}/count-demo/`로 복사합니다.
2. `terraform_data.by_count`를 `count`인 상태로 `apply` 합니다. `terraform state list`를 `state-before.txt`로 저장합니다. 주소가 `[0]` `[1]` `[2]`여야 합니다.
3. `by_count`를 `for_each = toset(var.names)`로 바꿉니다. 이 상태로 `plan`을 떠서 `plan-naive.txt`로 저장합니다. 여기서 몇 개가 지워지고 몇 개가 새로 만들어지는지 보세요.
4. 재생성이 일어나지 않도록 고칩니다. `plan`이 `Plan: 0 to add, 0 to change, 0 to destroy.`가 되어야 합니다. 그 출력을 `plan-fixed.txt`로 저장합니다.
5. `apply` 한 뒤 `terraform state list`를 `state-after.txt`로 저장합니다. 주소가 `["alpha"]` 형태여야 하고, 리소스는 새로 만들어지지 않았어야 합니다.
6. 실습에서 만든 `practice/` 스택은 `destroy` 되어 있어야 합니다.

> [!TIP]
> 4번의 방법은 두 가지입니다. 명령으로 state 주소를 옮기는 방법과, 코드에 옮긴 사실을 적어두는 방법입니다. 뒤쪽이 PR 로 리뷰하기 좋습니다. 어느 쪽을 골랐는지 `observations.md`에 적으세요.
> 힌트가 필요하면 `terraform state mv --help`와 Terraform 문서의 [Refactoring](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)을 보세요.

> [!IMPORTANT]
> 3번의 `plan`은 반드시 `apply`를 한 뒤에 떠야 합니다. state 가 비어 있으면 그냥 생성 계획만 나와서 차이가 보이지 않습니다.

> [!CAUTION]
> 이 과제는 `terraform_data`로만 합니다. AWS 리소스로 연습하지 마세요. 실수하면 요금이 나갑니다.

## 증빙

`submissions/{본인-github-id}/`에 넣습니다.

- [ ] `count-demo/`의 `.tf` 파일 (최종본)
- [ ] `state-before.txt` · `state-after.txt`. 주소 형식이 `[0]`에서 `["alpha"]`로 바뀐 것이 보여야 합니다
- [ ] `plan-naive.txt` · `plan-fixed.txt`. 앞은 재생성이 잡히고 뒤는 `0 to add, 0 to change, 0 to destroy`
- [ ] `state-list.txt` : 실습 C-4에서 저장한 `practice/` destroy 후 빈 출력 (마스킹 완료)
- [ ] `observations.md` : 실습워크북의 `[관찰 ✍️]` 답안 (A-2 · A-6 · B-5 · B-6 · B-7 · C-3)
- [ ] `observations.md`에 아래 세 가지를 추가로 적습니다
  - 3번의 순진한 전환에서 몇 개가 재생성으로 잡혔는지, 왜인지
  - 4번에서 고른 방법과 그 방법이 무엇을 바꾸는지 (실제 인프라를 건드리는가, state 만 건드리는가)
  - 지금 운영 중인 서비스였다면 3번을 그대로 apply 했을 때 무슨 일이 일어났을지
- [ ] 로그와 스크린샷의 계정번호 12자리 · 공인 IP 를 가렸습니다

## 제출

브랜치는 `week4/{본인-github-id}`이고, `submissions/{본인-github-id}/` 아래에 넣어 PR 을 올립니다.

> [!CAUTION]
> `terraform.tfvars` · `terraform.tfstate` · `*.backup` · `backend.hcl` · `.pem` 파일은 올리지 않습니다. `.gitignore`가 막고 있지만 푸시 전에 `git status`로 한 번 더 확인하세요. 마스킹 명령은 실습워크북 C-4에 있습니다.
>
> `practice/`를 직접 고쳐 올리지 마세요. 머지되는 순간 다음 사람의 빈칸이 사라집니다.

## 다음 주 예습

`module` 블록, `source`, 모듈의 input 과 output

## 심화 (심화 ⭐)

- `-backend-config=backend.hcl` 파일로 backend 값 분리 (실습워크북 B-8)
- `terraform console`로 `merge()`의 우선순위와 `for` 표현식을 직접 확인 (실습워크북 B-9)
- `practice/`의 `aws_subnet.public` 을 `count`로 바꿔보고, `for_each`로 되돌릴 때 무엇이 필요한지 `plan`으로만 확인 (apply 하지 마세요)

## 리뷰 방식

Week5 과제 리뷰 5분에 대표 PR 을 함께 봅니다. `plan-naive.txt`와 `plan-fixed.txt`를 나란히 놓고 읽습니다.
