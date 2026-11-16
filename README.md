# 府省の文書の全文検索

府省のデータセットが持つ文書（PDF）のページを 1 つにまとめ、2 文字ずつ区切った索引で全文検索できるようにした Queria のデータセット（`queria/gov_documents`）です。

## 収録している文書

| データセット | 種類（`kind`） | 内容 |
| --- | --- | --- |
| `mlit` | `white_paper` | 国土交通白書（令和3年版から） |
| `mlit`・`mhlw`・`mext`・`cao`・`maff`・`cas`・`env`・`soumu`・`meti` | `plans` | 行政事業レビューのシートが「関係する計画・通知等」に挙げる、その府省のサイトの PDF |

ページの本文の取り出し（文字化けの修正を含む）は、元の府省のデータセットで行っています。このデータセットはそれをまとめて索引を作るだけで、文書を取得しません。

## テーブル

| テーブル | 内容 |
| --- | --- |
| `search.documents` | 1 行が 1 つのデータセットの 1 つの URL。府省・種類・題名・sha256・ページ数 |
| `search.pages` | 1 行が 1 ページ。本文・文字数・PDF の該当ページの URL |
| `search.page_bigrams` | 1 行が 1 ページ × 2 文字の組。出現回数を持ち、全文検索の索引に使う |

行政事業レビューの事業と結び付けるときは、`queria/rssystem` の `review.related_plans` の `plan_url` と `search.documents` の `url` を結合します。

## 使い方

「医療的ケア児」を含むページを、BM25 の順に並べる:

```sql
WITH q AS (
    SELECT DISTINCT substr(w, i, 2) AS gram
    FROM (SELECT '医療的ケア児' AS w), range(1, length(w)) AS r(i)
),
hits AS (SELECT b.* FROM gov_documents.search.page_bigrams AS b JOIN q USING (gram)),
df AS (SELECT gram, count(*) AS df FROM hits GROUP BY gram),
stats AS (SELECT count(*) AS n, avg(chars) AS avgdl FROM gov_documents.search.pages)
SELECT d.publisher, d.title, p.page, p.page_url,
    sum(ln(1 + (s.n - df.df + 0.5) / (df.df + 0.5)) * h.tf * 2.2
        / (h.tf + 1.2 * (0.25 + 0.75 * p.chars / s.avgdl))) AS score
FROM hits AS h
JOIN df USING (gram)
JOIN gov_documents.search.pages AS p USING (page_id)
JOIN (SELECT DISTINCT ON (sha256) * FROM gov_documents.search.documents ORDER BY sha256, dataset, kind, url) AS d USING (sha256)
CROSS JOIN stats AS s
GROUP BY ALL
HAVING count(*) = (SELECT count(*) FROM q)
ORDER BY score DESC
LIMIT 5;
```

## 出典と利用条件

- 各文書は、国土交通省・厚生労働省・文部科学省・内閣府・農林水産省・内閣官房・環境省・総務省・経済産業省のウェブサイトのコンテンツです。各府省のウェブサイトの利用規約（公共データ利用規約 第1.0版 などの政府標準利用規約）に従います。使うときは、文書ごとに出典と加工したことを書いてください
- 図表には府省以外の著作物が含まれることがあります。このデータセットは本文の文字だけを持ち、PDF の原本は保存していません

## ビルド

```bash
git submodule update --init
uv sync
bash scripts/build.sh
```

dbt build が、`queria/mlit`・`queria/mhlw`・`queria/mext`・`queria/cao`・`queria/maff`・`queria/cas`・`queria/env`・`queria/soumu`・`queria/meti` の公開データを読んでテーブルを作り直します。GitHub Actions の Sync は main への push と毎月 15 日に動きます。
