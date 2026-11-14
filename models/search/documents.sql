{# 府省のデータセットの文書の一覧。1 行が 1 つの URL #}

SELECT
    'mlit' AS dataset,
    '国土交通省' AS publisher,
    'white_paper' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM mlit.white_paper.documents
UNION ALL
SELECT
    'mhlw' AS dataset,
    '厚生労働省' AS publisher,
    'plans' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM mhlw.plans.documents
UNION ALL
SELECT
    'mext' AS dataset,
    '文部科学省' AS publisher,
    'plans' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM mext.plans.documents
UNION ALL
SELECT
    'cao' AS dataset,
    '内閣府' AS publisher,
    'plans' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM cao.plans.documents
UNION ALL
SELECT
    'maff' AS dataset,
    '農林水産省' AS publisher,
    'plans' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM maff.plans.documents
UNION ALL
SELECT
    'mlit' AS dataset,
    '国土交通省' AS publisher,
    'plans' AS kind,
    url,
    sha256,
    title,
    page_count,
    fetched_at
FROM mlit.plans.documents
ORDER BY dataset, kind, url
