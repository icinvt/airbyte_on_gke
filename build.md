# 前提条件

## Google Cloudの準備
- Google Cloud Projectを作成
- Kubernetes Engine APIを有効化
- gcloud CLIをインストール済み
- GOOGLE_APPLICATION_CREDENTIALSの設定（gcloud auth application-default loginで再認証）

## 必要なツール
- `kubectl`
- `Helm`
- `gcloud CLI`

---

# 手順

## 1. プラグインのインストール

以下のコマンドでプラグインをインストールします：

```bash
gcloud components install gke-gcloud-auth-plugin
```

インストールが完了したら、次のコマンドで有効化を確認します：

```bash
gcloud components list
```

---

## 2. Google Kubernetes Engine（GKE）の設定

クラスタの作成と接続設定を行います：

```bash
gcloud container clusters create airbyte-cluster \
    --zone=asia-northeast1 \
    --num-nodes=1 \
    --machine-type=e2-medium \
    --disk-size=50
```

> **メモ**: クォータが増加された場合、以下のコマンドでノード数を再設定してください：

```bash
gcloud container clusters resize airbyte-cluster \
    --zone=asia-northeast1 \
    --node-pool=default-pool \
    --num-nodes=3
```

次に、クラスタに接続します：

```bash
gcloud container clusters get-credentials airbyte-cluster \
    --zone=asia-northeast1
```

このコマンドにより、`kubectl` がGKEクラスタの作成と接続のための設定を行います。

---

## 3. Helmの設定

Airbyteをデプロイするために、Helmを使用します。

### Helmリポジトリの追加

```bash
helm repo add airbyte https://airbytehq.github.io/helm-charts
helm repo update
```

---

## 4. Airbyteのインストール

AirbyteをGKEクラスタにデプロイします。

### ネームスペースの作成

```bash
kubectl create namespace airbyte
```

### Airbyteのデプロイ

```bash
helm install airbyte airbyte/airbyte -n airbyte
```

上記でデフォルト設定が使用されますが、設定をカスタマイズする場合は`values.yaml`を作成し、それを適用します。

以下は基本的なカスタマイズ例です。

```yaml
webapp:
  service:
  type: LoadBalancer
database:
  externalDatabase:
  enabled: false
```

カスタマイズしたい場合、以下のコマンドでインストールします。

```bash
helm install airbyte airbyte/airbyte -n airbyte -f values.yaml
```

これでAirbyteがクラスタ内にデプロイされます。

---

## 5. Web UIへのアクセス

AirbyteのWeb UIにアクセスするには、LoadBalancerサービスの外部IPを取得します：

```bash
kubectl patch service airbyte-airbyte-webapp-svc -n airbyte \
  -p '{"spec": {"type": "LoadBalancer"}}'
```

このコマンドを実行すると、GKEのロードバランサーが作成され、外部IPアドレスが割り当てられます。

次に、外部IPを確認します：

```bash
kubectl get services -n airbyte
```

`airbyte-webapp` という名前のサービスの外部IPが表示されます。このIPをブラウザで開いてアクセスしてください。（表示されない場合は数分待って再度確認してください）

---

## 6. Google Cloud CLIの更新（オプション）

表示されているCLI更新通知を処理するには、以下のコマンドを実行してください：

```bash
gcloud components update
```

これにより、最新のGoogle Cloud CLIを使用できます。


---

## 7. ストレージとデータベースの設定（オプション）
データの永続化やスケーラビリティのために、Google Cloud StorageやCloud SQLを設定するのが推奨されます。

- **Google Cloud Storageの設定**
  Airbyteのバックアップやログを保存するために、GCSバケットを作成して設定します。

- **Cloud SQLの使用**
  AirbyteのデフォルトではPostgreSQLが使用されます。外部データベースを使用したい場合は、Cloud SQLインスタンスを作成して接続します。

---

## 8. メンテナンスとスケール
- **ノードのスケール**
  ```bash
  gcloud container clusters resize airbyte-cluster --node-pool default-pool --num-nodes=5
  ```

- **アップグレード**
  Helmを使用してAirbyteをアップグレードします。
  ```bash
  helm repo update
  helm upgrade airbyte airbyte/airbyte -n airbyte
  ```

---

AirbyteがGoogle CloudでKubernetes上に正常にデプロイされた後、各種コネクタの設定や同期ジョブの作成を行うことができます。
```