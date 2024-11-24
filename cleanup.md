# リソース削除手順

## 1. Kubernetes関連リソースの削除

### ネームスペース全体を削除
Airbyte関連リソースが存在する `airbyte` ネームスペースを削除します。

```bash
kubectl delete namespace airbyte
```

---

## 2. GKEクラスタの削除

作成したGKEクラスタを削除します。

```bash
gcloud container clusters delete airbyte-cluster \
    --zone=asia-northeast1
```

---

## 3. 永続ディスクの削除（必要に応じて）

GKEの削除後も、Kubernetesが作成した永続ディスク（Persistent Disks）が残る場合があります。それらを手動で削除します。

### 永続ディスクの確認
以下のコマンドで、作成された永続ディスクを確認します：

```bash
gcloud compute disks list --zones=asia-northeast1-a
```

### 永続ディスクの削除
確認後、削除する場合は以下を実行します：

```bash
gcloud compute disks delete <DISK_NAME> --zone=asia-northeast1-a
```

---

## 4. Load Balancerの削除（必要に応じて）

GKEで作成されたロードバランサ（外部IPアドレス）が残る場合があります。それを削除します。

### 関連リソースの確認

#### フォワーディングルール（`<FORWARDING_RULE_NAME>`）の確認
```bash
gcloud compute forwarding-rules list --filter="region:(asia-northeast1)"
```

出力例：
```
NAME                  REGION          IP_ADDRESS      IP_PROTOCOL  TARGET
k8s-fw-abcdef123456   asia-northeast1 34.85.49.136    TCP          k8s-target-pool
```

#### ターゲットプール（`<TARGET_POOL_NAME>`）の確認
```bash
gcloud compute target-pools list --filter="region:(asia-northeast1)"
```

出力例：
```
NAME                  REGION          SESSION_AFFINITY
k8s-target-pool       asia-northeast1 NONE
```

#### 予約された外部IP（`<ADDRESS_NAME>`）の確認
```bash
gcloud compute addresses list --filter="region:(asia-northeast1)"
```

出力例：
```
NAME                  REGION          ADDRESS          STATUS
k8s-static-ip         asia-northeast1 34.85.49.136     RESERVED
```

### リソースの削除

#### フォワーディングルールの削除：
```bash
gcloud compute forwarding-rules delete <FORWARDING_RULE_NAME> --region=asia-northeast1
```

#### ターゲットプールの削除：
```bash
gcloud compute target-pools delete <TARGET_POOL_NAME> --region=asia-northeast1
```

#### 予約された外部IPアドレスの削除：
```bash
gcloud compute addresses delete <ADDRESS_NAME> --region=asia-northeast1
```

---

## 5. Helmのリリース削除（必要に応じて）

Helmでデプロイしたリリースが残っている場合は削除します。

```bash
helm uninstall airbyte -n airbyte
```

---

## 6. 確認

すべてのリソースが削除されたことを以下で確認します。

### クラスタの確認
```bash
gcloud container clusters list
```

### 永続ディスクの確認
```bash
gcloud compute disks list
```

### ロードバランサの確認
```bash
gcloud compute forwarding-rules list --filter="region:(asia-northeast1)"
```

### ターゲットプールの確認
```bash
gcloud compute target-pools list --filter="region:(asia-northeast1)"
```

### 外部IPアドレスの確認
```bash
gcloud compute addresses list --filter="region:(asia-northeast1)"
```