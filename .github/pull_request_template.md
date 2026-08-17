## 이번 주 실습/과제 PR

- 주차: week4 (변수와 반복)
- GitHub ID:
- 제출 경로: `submissions/<본인-github-id>/`

### DoD 체크리스트
- [ ] `terraform init` 성공. week3 버킷의 `week04/app/terraform.tfstate` 키로 초기화됐습니다
- [ ] `terraform plan`이 `Plan: 9 to add, 0 to change, 0 to destroy.`
- [ ] `terraform apply` 성공. `state list` 11줄 (리소스 9 + 데이터 소스 2)
- [ ] `terraform output`의 `subnet_ids`가 `{ "a" = "subnet-...", "c" = "subnet-..." }` 맵으로 나옵니다
- [ ] `my_ip`에 `sensitive = true`를 붙여 plan 출력에서 공인 IP가 `(sensitive value)`로 가려집니다
- [ ] `count-demo`에서 가운데 항목을 지운 plan 결과를 기록했습니다 (`Plan: 1 to add, 0 to change, 3 to destroy.`)
- [ ] `subnets` 맵에서 항목 하나를 지웠을 때 나머지 서브넷이 재생성되지 않는 것을 plan으로 확인했습니다
- [ ] **`terraform destroy` 완료.** `scripts/check-leftover.sh`에서 `Purpose=workload`가 전부 0인 것을 확인했습니다
- [ ] `count-demo`도 `terraform destroy` 했습니다
- [ ] week3에서 만든 S3·DynamoDB는 **지우지 않았습니다** (7주차까지 유지)
- [ ] `git diff`로 자격증명 · `terraform.tfvars` · `*.tfstate` · `state.json` · `*.pem`이 커밋되지 않았는지 확인
- [ ] 스크린샷과 로그의 계정번호 12자리 · 공인 IP를 가렸습니다
- [ ] `submissions/<id>/observations.md`에 `[관찰 ✍️]` 답을 적었습니다 (A-2 · A-6 · B-4 · B-6 · C-3)
- [ ] `practice/` 아래 파일을 고치지 않았습니다 (`git diff --name-only origin/main`으로 확인)

### 오늘 만든 것 (요약)


### 막힌 지점 / 질문


### destroy 확인
`practice/`에서 실행한 `terraform state list` 출력:
```
(빈 출력이어야 함)
```

`scripts/check-leftover.sh` 결과 중 `[1] Purpose=workload` 부분:
```
(전부 0 이어야 함. week3 의 S3·DynamoDB 는 [2]에 남아 있는 것이 정상입니다)
```
