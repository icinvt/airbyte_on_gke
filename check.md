# GKEおよびKubernetesの状態確認手順

## 1. GKEクラスタ情報の確認

クラスタの基本情報を確認するには次のコマンドを使用します：

```bash
gcloud container clusters describe airbyte-cluster --zone=asia-northeast1
```

これにより、クラスタの詳細情報（ノード数、マシンタイプ、ディスクサイズ、バージョンなど）を確認できます。

---

## 2. クラスタ内のノードの確認

クラスタ内のノード情報を確認するには次のコマンドを使用します：

```bash
kubectl get nodes
```

---

## 3. Kubernetesネームスペース内のリソース一覧

Airbyte関連のリソースを確認するため、ネームスペース `airbyte` のすべてのリソースをリスト表示します：

```bash
kubectl get all -n airbyte
```

これにより以下のリソースが一覧表示されます：
- Pod
- Service
- ReplicaSet
- Deployment
- その他関連リソース

---

## 4. サービスの詳細情報の確認

特定のサービス（例: `airbyte-airbyte-webapp-svc`）の詳細情報を確認するには次のコマンドを実行します：

```bash
kubectl describe service airbyte-airbyte-webapp-svc -n airbyte
```

これにより、サービスの設定（クラスタIP、外部IP、ポート情報など）を確認できます。

---

## 5. Airbyte Web UIのアクセス先確認

LoadBalancerが設定されているWeb UI用のサービスの外部IPを確認します：

```bash
kubectl get service airbyte-airbyte-webapp-svc -n airbyte
```

### 出力例：
```
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)       AGE
airbyte-airbyte-webapp-svc LoadBalancer   34.118.225.152   34.85.49.136   80:32118/TCP  7m39s
```

この場合、`EXTERNAL-IP`（例: `34.85.49.136`）がWeb UIのアクセスURLになります。

### ブラウザでアクセス：
```
http://34.85.49.136
```

---

## 6. Helmでデプロイされたリソースを確認

Helmを使用してデプロイされたAirbyteリリースのステータスを確認するには次のコマンドを実行します：

```bash
helm status airbyte -n airbyte
```

これにより、デプロイされたリソースの一覧と状況が確認できます。

---

## 7. ログの確認

各Podのログを確認するには以下のコマンドを使用します：

```bash
kubectl logs <POD_NAME> -n airbyte
```

### 例：webappのログを確認する場合

```bash
kubectl logs -n airbyte $(kubectl get pods -n airbyte -l "app.kubernetes.io/name=webapp" -o jsonpath="{.items[0].metadata.name}")
```