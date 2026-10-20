# API 一覧（ドメインごと）

作る endpoint の一覧。中身は自分で書く。Day は `MILESTONES.md` の日。

## system

| Method | Path      | すること             | 成功                   | エラー | Day |
| ------ | --------- | -------------------- | ---------------------- | ------ | --- |
| GET    | `/health` | 生きているか確認する | 200 `{"status": "ok"}` |        | 1   |

## menus（メニューの CRUD）

| Method | Path                    | すること                       | 成功             | エラー   | Day |
| ------ | ----------------------- | ------------------------------ | ---------------- | -------- | --- |
| POST   | `/menus`                | メニューを作る                 | 201 `Menu`       | 422      | 2   |
| GET    | `/menus/{id}`           | 1 件取る                       | 200 `Menu`       | 404      | 2   |
| GET    | `/menus?limit=&offset=` | 一覧（`limit` 1〜50、既定 10） | 200 `list[Menu]` | 422      | 3   |
| DELETE | `/menus/{id}`           | 削除する                       | 204              | 404      | 3   |
| PATCH  | `/menus/{id}`           | 送った項目だけ変える           | 200 `Menu`       | 404, 422 | 4   |
| PUT    | `/menus/{id}`           | 全体を置き換える               | 200 `Menu`       | 404, 422 | 4   |

## analysis（画像の upload と解析）

| Method | Path                | すること                                                                       | 成功                                         | エラー                            | Day       |
| ------ | ------------------- | ------------------------------------------------------------------------------ | -------------------------------------------- | --------------------------------- | --------- |
| POST   | `/menus/{id}/image` | 画像を upload して解析する（Day 5 はその場で、Day 12 から非同期）              | 200 `Menu` → 202 `Menu`（`status: pending`） | 404, 409（解析中）, 413, 415, 502 | 5, 12, 15 |
| GET    | `/menus/{id}`       | 解析の状態は `Menu.status` で見る（`pending`・`processing`・`done`・`failed`） | 200                                          | 404                               | 12        |

## モデル

| ドメイン | モデル        | 項目                                                    |
| -------- | ------------- | ------------------------------------------------------- |
| menus    | `MenuCreate`  | `name`（必須、1〜100 文字）、`note`（任意）             |
| menus    | `MenuUpdate`  | 全部省略できる                                          |
| menus    | `Menu`        | `id`、`name`、`note`、`dishes`、`status`（Day 12〜）    |
| analysis | `Dish`        | `name`、`description`、`spiciness`（1〜5）、`allergens` |
| 共通     | エラーの body | 形をそろえる（Day 10）                                  |

## ドメインごとの部品（Week 2 から）

| ドメイン | domain（interface）              | infrastructure（実装）                                  |
| -------- | -------------------------------- | ------------------------------------------------------- |
| menus    | `MenuRepository`（Protocol）     | `InMemoryMenuRepository`、`SqlMenuRepository`（Day 16） |
| analysis | `MenuAnalyzer`（Protocol）       | `FakeMenuAnalyzer`、`ClaudeMenuAnalyzer`                |
| analysis | 解析の queue と worker（Day 13） | `asyncio.Queue`                                         |
