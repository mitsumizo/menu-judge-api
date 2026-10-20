# マイルストーン

このリポジトリのコードは、全部自分の手で書く。AI は使わない。調べていいのは公式 docs と Google。

## 毎日の 1 時間

| 時間 | やること |
|---|---|
| 10 分 | 前日に書いた一番大事な関数を、白紙から書き直す（見ないで） |
| 40 分 | その日の課題 |
| 10 分 | その日のコードを、英語で声に出して説明する（「今日の説明」の問い） |

ルール:

- 15 分詰まったら、ヒントを 1 回だけもらう
- テストが落ちたら、最初の 1 手は `print(r.status_code, r.json())`
- テストを先に書いて、落ちるのを見てから実装する
- 1 日の終わりに `make test` と `make lint` が通って、コミットしている
- 各週の最後の日は模擬テスト（新しい課題・45 分・ヒントなし）

参考: [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)、[Pydantic Models](https://docs.pydantic.dev/latest/concepts/models/)、[asyncio](https://docs.python.org/3/library/asyncio.html)

---

## Week 1 — 基本（今日つまずいたところ全部）

### Day 1: health とモデル
- [ ] `app/main.py` に app を作る。`GET /health` が `{"status": "ok"}` を返す
- [ ] `Dish`（`name`、`description`、`spiciness` 1〜5、`allergens` のリスト）
- [ ] `MenuCreate`（`name` 必須・1〜100 文字、`note` 任意）
- [ ] `MenuUpdate`（**全部の項目を省略できる**）
- [ ] `Menu`（`id`、`name`、`note`、`dishes`）

完了の条件:
- [ ] `GET /health` のテスト
- [ ] `MenuUpdate()` が引数なしで作れることのテスト
- [ ] `MenuCreate(name="")` が `ValidationError` になることのテスト

今日の説明: "Why can `MenuUpdate` be created with no arguments, but `MenuCreate` can't?"

### Day 2: 作る・1 件取る
- [ ] メモリ上の保存先（dict）
- [ ] `POST /menus` → `201` と作った `Menu`
- [ ] `GET /menus/{id}` → `200`。無ければ `404`

完了の条件:
- [ ] 作った直後に GET して、同じ値が返るテスト
- [ ] 存在しない id で `404` のテスト
- [ ] `name` が無い body で `422` のテスト。**`r.json()` の `loc` と `msg` を assert する**

今日の説明: "What does a 422 response body tell you, and where do you look first?"

### Day 3: 一覧・削除
- [ ] `GET /menus?limit=&offset=`（`limit` は 1〜50、既定 10）
- [ ] `DELETE /menus/{id}` → `204`。無ければ `404`

完了の条件:
- [ ] 3 件作って `limit=2` で 2 件返るテスト
- [ ] `limit=0` と `limit=51` で `422` のテスト
- [ ] 削除したあと GET で `404` のテスト

今日の説明: "Why 204 and not 200 for delete?"

### Day 4: 更新（Capsa の課題 1 そのもの）
- [ ] `PATCH /menus/{id}`: 送った項目だけ変える
- [ ] `PUT /menus/{id}`: 全体を置き換える

完了の条件:
- [ ] PATCH で `note` だけ送ると、`name` は変わらないテスト（**更新後に GET して確かめる**）
- [ ] PATCH で空の body `{}` を送ったときの動きを決めて、テストにする
- [ ] PUT で `note` を省くと、`note` が消えるテスト
- [ ] 存在しない id で `404` のテスト

今日の説明: "What's the difference between PUT and PATCH? How did you make PATCH change only the sent fields?"

### Day 5: 画像の upload ＋ 模擬テスト
- [ ] `POST /menus/{id}/image`（`UploadFile`）
- [ ] JPEG と PNG 以外は `415`、5MB を超えたら `413`
- [ ] 解析は偽物（いつも同じ `Dish` を 2 つ返す関数）で、その場で `dishes` に入れる

完了の条件:
- [ ] PNG を送ると `dishes` が 2 つになるテスト
- [ ] テキストファイルで `415`、大きすぎるファイルで `413` のテスト

模擬テスト（45 分）: Claude に新しい課題をもらう

今日の説明: "How did you check the file type, and why can't you trust the filename?"

---

## Week 2 — 構造（Callum が最初に説明した形）

### Day 6: Router に分ける
- [ ] `app/api/menus.py` に `APIRouter` を作って、`main.py` から `include_router` する
- [ ] テストは 1 行も変えずに全部通る

今日の説明: "Why split routes into routers?"

### Day 7: domain と infrastructure
- [ ] `app/domain/models.py`（`Menu`、`Dish`）
- [ ] `app/domain/repositories.py`: `MenuRepository` を `typing.Protocol` で定義する（`add`、`get`、`list`、`update`、`delete`）
- [ ] `app/infrastructure/in_memory.py`: `InMemoryMenuRepository`
- [ ] endpoint は dict を直接さわらず、repository だけを使う

完了の条件:
- [ ] `InMemoryMenuRepository` 単体のテスト（API を通さない）
- [ ] `make lint`（mypy strict）が通る

今日の説明: "What's the difference between a Protocol and an abstract base class?"

### Day 8: Depends と lifespan
- [ ] `lifespan` で repository を 1 つ作る
- [ ] `Depends(get_repository)` で endpoint に渡す
- [ ] `tests/conftest.py` に、毎回まっさらな repository を使う fixture を作る（`app.dependency_overrides`）

完了の条件:
- [ ] テストの順番を変えても、全部通る（前のテストのデータが残っていない）

今日の説明: "How does `dependency_overrides` help testing?"

### Day 9: 解析を差し替えられるようにする
- [ ] `app/domain/analyzer.py`: `MenuAnalyzer` の Protocol（画像の bytes → `list[Dish]`）
- [ ] `FakeMenuAnalyzer`（テスト用）と `ClaudeMenuAnalyzer`（本物）
- [ ] API キーは環境変数から読む。テストでは本物を絶対に呼ばない

完了の条件:
- [ ] テストは `FakeMenuAnalyzer` だけで通る
- [ ] 手元で `make run` して、本物のメニュー写真で 1 回動かす

今日の説明: "How do you keep tests from calling the real LLM API?"

### Day 10: エラーの形をそろえる ＋ 模擬テスト
- [ ] domain の例外（`MenuNotFound` など）を作る。repository はそれを投げる
- [ ] `exception_handler` で HTTP の `404` に変える。エラーの body の形をそろえる
- [ ] LLM の返事が壊れていた（JSON にならない）ときは `502`

完了の条件:
- [ ] すべての `404` が同じ形の body を返すテスト
- [ ] 偽物の analyzer に壊れた返事をさせて `502` のテスト

模擬テスト（45 分）

今日の説明: "Why does the repository raise a domain error instead of an HTTPException?"

---

## Week 3 — 非同期（Capsa の課題 2 に近い形）

### Day 11: async def と def
- [ ] `MenuAnalyzer` を async にする
- [ ] 実験: 解析の中で `time.sleep(2)` と `await asyncio.sleep(2)` を入れて、同時に 3 回呼んだときの合計時間を測る。結果を `docs/notes.md` に書く

今日の説明: "What happens to the event loop when you call a blocking function inside `async def`?"

### Day 12: 202 と status
- [ ] `Menu` に `status`（`pending`・`processing`・`done`・`failed`）を足す
- [ ] `POST /menus/{id}/image` は `202` と `pending` をすぐ返す
- [ ] 解析は `BackgroundTasks` で動かす

完了の条件:
- [ ] 202 の直後は `pending`、解析のあとは `done` になるテスト

今日の説明: "Why return 202 instead of waiting for the result?"

### Day 13: 自分で worker を作る
- [ ] `BackgroundTasks` をやめて、`asyncio.Queue` と worker にする
- [ ] worker は `lifespan` で起動して、終了時に止める

完了の条件:
- [ ] 3 件まとめて upload して、全部 `done` になるテスト
- [ ] アプリを止めたときに、worker が止まる

今日の説明: "When would you choose a queue and a worker over `BackgroundTasks`? What would you use in production?"

### Day 14: retry と同時実行数
- [ ] 一時的なエラー（偽物が 2 回失敗して 3 回目に成功）は、待つ時間を倍にしながら retry
- [ ] 回数の上限を超えたら `failed`。入力のエラーは retry しない
- [ ] `asyncio.Semaphore` で、同時に解析する数を 2 までにする

完了の条件:
- [ ] 2 回失敗して 3 回目で `done` のテスト
- [ ] 上限を超えて `failed` のテスト
- [ ] 同時に動いた数の最大が 2 だったことのテスト

今日の説明: "Why exponential backoff? Which errors should not be retried?"

### Day 15: 状態のエッジケース ＋ 模擬テスト
- [ ] 解析中に DELETE されたらどうするか決めて、実装する
- [ ] `pending` か `processing` のときにもう一度 upload されたら `409`
- [ ] 解析中に PATCH で `name` を変えても、解析の結果で上書きされない

完了の条件:
- [ ] 上の 3 つのテスト

模擬テスト（45 分）: Capsa の課題 2 を想像して再現したもの

今日の説明: "Name the edge cases for an endpoint that starts async work." （入力・存在・状態の 3 段で）

---

## Week 4 — 本番寄り

### Day 16: SQLite
- [ ] `SqlMenuRepository`（SQLAlchemy）を作る。**Protocol はそのまま、実装だけ増やす**
- [ ] 設定で in-memory と SQLite を切り替える

今日の説明: "What did the Protocol let you change without touching the endpoints?"

### Day 17: 両方の実装で同じテスト
- [ ] repository の fixture を parametrize して、全部のテストを両方の実装で回す

### Day 18: 関連と N+1
- [ ] `dishes` を別の表にする（menu 1 : dish 多）
- [ ] 一覧で `echo=True` にして N+1 を目で見る → `selectinload` で直す

完了の条件:
- [ ] 10 件の一覧で SELECT が 2 回だけになったことを確かめる

今日の説明: "What is N+1, and how did you fix it?"

### Day 19: フロントとつなぐ
- [ ] CORS を設定する
- [ ] `menu-judge-next` から、この API を呼ぶようにする（upload → `pending` → `done` を画面で見る）

### Day 20: 仕上げ
- [ ] README に構成図と設計の理由を書く
- [ ] 5 分の英語の "Walk me through your code." を録音する。書き起こして、自分で採点する

---

## 記録

| Day | 日付 | できた | 詰まったところ |
|---|---|---|---|
| 1 | | | |
