# 良いテストと悪いテスト

## 良いテスト

**インテグレーション型**: 内部のモックではなく、実際のインターフェースを通じてテストする。

```typescript
// 良い例: 観測可能な振る舞いをテスト
test("有効なカートでチェックアウトできる", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特徴：

- ユーザー/呼び出し元が関心を持つ振る舞いをテスト
- パブリックAPIのみを使用
- 内部リファクタリングに耐える
- 「何を」するかを記述し、「どのように」ではない
- テストごとに1つの論理的なアサーション

## 悪いテスト

**実装詳細テスト**: 内部構造に結合している。

```typescript
// 悪い例: 実装の詳細をテスト
test("checkoutがpaymentService.processを呼ぶ", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危険信号：

- 内部のコラボレータをモックしている
- プライベートメソッドをテストしている
- 呼び出し回数/順序をアサートしている
- 振る舞いが変わっていないのにリファクタリングでテストが壊れる
- テスト名が「何を」ではなく「どのように」を記述している
- インターフェースではなく外部手段で検証している

```typescript
// 悪い例: インターフェースを迂回して検証
test("createUserがデータベースに保存する", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// 良い例: インターフェースを通じて検証
test("createUserでユーザーが取得可能になる", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```
