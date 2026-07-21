# Week 4. 변수와 반복 (variables / for_each) `[대면]`

> 📘 **[이번 주 강의자료(핸즈온 워크북) PDF »](./lecture/강의자료.pdf)** — 실습은 이 문서를 위에서 아래로 따라가며 진행합니다.

> 이번 주가 끝나면: **하드코딩을 variable/locals로 걷어내고, `for_each`로 여러 리소스를 반복 생성할 수 있다.**

## 0. 메타 정보
| 항목 | 내용 |
|------|------|
| 일시 | 2026-MM-DD · 60분 |
| 방식 | **대면** (멘토링 정기모임 병행) |
| 선행 | week3 완료 · 과제② 제출 |
| 산출물 | 실습 PR + 워크북 (지난 과제 리뷰 O) |

## 1. 학습 목표 (측정 가능)
- [ ] variable 타입(string/number/bool/list/map/object)과 `default`/`validation`/`sensitive`를 쓸 수 있다
- [ ] `locals`로 공통 값을 계산하고 `merge()`로 태그를 합칠 수 있다
- [ ] `for_each`로 map/set을 순회해 N개 리소스를 만들 수 있다
- [ ] `for_each`가 `count`보다 안전한 이유를 설명할 수 있다

## 2. 사전 예습 (필수)
- HashiCorp: [Variables](https://developer.hashicorp.com/terraform/language/values/variables), [for_each](https://developer.hashicorp.com/terraform/language/meta-arguments/for_each) (15분)
- 예습 체크: "list로 count를 쓰다 중간 원소를 지우면 왜 위험한지" 안다

## 3. 진행 타임박스 (60분)
| 시간 | 구성 | 내용 |
|------|------|------|
| 0~10분 | 회고 | 랜덤 지목 |
| 10~15분 | 과제② 리뷰 | 대표 PR 공유 |
| 15~58분 | 실습 45분 | 하드코딩 제거 → subnet for_each → 태그 공통화 |
| 58~60분 | 마무리 | 5주차 예고 |

## 4. 실습 개요 — 하드코딩 제거 + subnet 반복 생성
week2/3의 인프라를 변수화하고, **public subnet을 AZ별로 `for_each`**로 생성합니다.
```hcl
variable "subnet_cidrs" {
  type = map(string)
  default = {
    "ap-northeast-2a" = "10.0.1.0/24"
    "ap-northeast-2c" = "10.0.2.0/24"
  }
}
resource "aws_subnet" "public" {
  for_each          = var.subnet_cidrs
  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-${each.key}" })
}
```
> **EC2는 계속 1대만!** for_each로 EC2를 여러 대 만들면 프리티어 초과 위험. 반복 예시는 subnet/tag 같은 무과금 리소스로.

```bash
cd practice
terraform init && terraform apply
terraform output      # subnet_ids 맵 확인
terraform destroy
```

## 5. 체크포인트 (DoD)
- [ ] 하드코딩 값이 variable/locals로 빠짐
- [ ] subnet이 AZ 수만큼 `for_each`로 생성됨
- [ ] `output`이 `for` 표현식으로 맵 형태 출력
- [ ] **`destroy` 완료 확인**

## 6. 트러블슈팅 FAQ
| 증상 | 원인 | 해결 |
|------|------|------|
| `for_each` argument error | list를 넣음 | map 또는 `toset(list)` 사용 |
| 변수 값 물어봄 | tfvars 없음/default 없음 | `terraform.tfvars` 작성 |
| count로 만든 리소스 재생성됨 | 중간 인덱스 삭제 | for_each로 전환 (안정적 key) |

## 7. 심화 도전과제 (Optional ⭐)
- L2: `validation` 블록으로 CIDR 형식 검증, `sensitive = true` output
- L3-⭐: `object` 타입 변수로 subnet 설정을 묶고, `for` 표현식으로 가공

## 8. 다음 주 예고 & 준비물
- Week5(대면): 모듈화 — 지금 변수화한 코드를 재사용 모듈로 추출
- 예습: `module` 블록, `source`, 모듈 input/output

---
> ⚠️ **비용 주의**: for_each는 무과금 리소스만. **EC2 1대 고정.** 실습 종료 = `destroy`.
> **공통 규칙**: 자격증명/secret 커밋 금지 · `destroy` 확인 · 코드는 PR로
