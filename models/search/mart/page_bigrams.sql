{# 全文検索用の索引。ページの本文を空白・改行を除いて 2 文字ずつ区切り、ページごとの出現回数（tf）を数える。
   BM25 などの順位付けは検索する側で tf と pages.chars から計算する。
   ページは pages の page_id で指す（sha256 を繰り返し持つと大きくなるため） #}

WITH chars AS (
    SELECT page_id, regexp_replace(text, '\s+', '', 'g') AS t
    FROM {{ ref('pages') }}
),

-- range と結合すると 2-gram の行ごとに本文を持ち回って一時ファイルが本文の文字数倍になるので、
-- ページの中でリストにしてから展開する
grams AS (
    SELECT page_id, unnest(list_transform(range(1, length(t)), lambda i: substr(t, i, 2))) AS gram
    FROM chars
)

SELECT
    page_id,
    gram,
    count(*)::INTEGER AS tf
FROM grams
GROUP BY ALL
ORDER BY gram, page_id
