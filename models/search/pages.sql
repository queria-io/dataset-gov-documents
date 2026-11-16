{# 文書のページ。同じ中身の PDF（sha256 が同じ）が複数のデータセットにあっても 1 回だけ持つ #}

WITH all_pages AS (
    SELECT sha256, page, page_label, text FROM mlit.white_paper.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM mhlw.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM mext.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM cao.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM maff.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM mlit.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM cas.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM env.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM soumu.plans.pages
    UNION ALL
    SELECT sha256, page, page_label, text FROM meti.plans.pages
),

first_url AS (
    -- 移転した文書は、シートの URL ではなく取得した URL（移転先）でページを開く
    SELECT sha256, min(fetched_url) AS url
    FROM {{ ref('documents') }}
    GROUP BY sha256
)

SELECT DISTINCT ON (p.sha256, p.page)
    -- page_bigrams が sha256 の代わりに持つ番号。sha256 とページの順に 1 から振る
    dense_rank() OVER (ORDER BY p.sha256, p.page)::INTEGER AS page_id,
    p.sha256,
    p.page,
    p.page_label,
    p.text,
    length(regexp_replace(p.text, '\s+', '', 'g'))::INTEGER AS chars,
    u.url || '#page=' || p.page AS page_url
FROM all_pages AS p
JOIN first_url AS u USING (sha256)
ORDER BY p.sha256, p.page
