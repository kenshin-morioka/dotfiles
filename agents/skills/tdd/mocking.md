# モックすべきタイミング

モックは**システム境界**でのみ使用する：

- 外部API（決済、メール等）
- データベース（場合によって - テスト用DBの使用を優先）
- 時間/ランダム性
- ファイルシステム（場合によって）

モックしてはいけないもの：

- 自分自身のクラス/モジュール
- 内部のコラボレータ
- 自分がコントロールできるもの全般

## モックしやすい設計

システム境界では、モックしやすいインターフェースを設計する：

### 1. 依存性の注入を使用する

外部依存を内部で生成するのではなく、引数として渡す：

```typescript
// モックしやすい
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// モックしにくい
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

### 2. 汎用フェッチャーよりもSDK型インターフェースを優先する

条件分岐ロジックを持つ汎用関数ではなく、各外部操作に対して個別の関数を作成する：

```typescript
// 良い例: 各関数が独立してモック可能
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// 悪い例: モックに条件分岐ロジックが必要
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK型アプローチの利点：

- 各モックが1つの特定の形状を返す
- テストセットアップに条件分岐ロジックが不要
- テストがどのエンドポイントを実行するか明確に分かる
- エンドポイントごとの型安全性
