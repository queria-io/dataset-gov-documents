{# 府省のデータセットの文書の一覧。1 行が 1 つの URL #}

{#- (データセット, 府省, fetched_url 列があるか)。fetched_url が無いデータセットはシートの URL から取得している -#}
{%- set plans = [
    ('mlit', '国土交通省', false),
    ('mhlw', '厚生労働省', false),
    ('mext', '文部科学省', false),
    ('cao', '内閣府', false),
    ('maff', '農林水産省', false),
    ('cas', '内閣官房', true),
    ('env', '環境省', false),
    ('soumu', '総務省', false),
] %}

SELECT
    'mlit' AS dataset,
    '国土交通省' AS publisher,
    'white_paper' AS kind,
    url,
    url AS fetched_url,
    sha256,
    title,
    page_count,
    fetched_at
FROM mlit.white_paper.documents
{%- for name, publisher, has_fetched_url in plans %}
UNION ALL
SELECT
    '{{ name }}' AS dataset,
    '{{ publisher }}' AS publisher,
    'plans' AS kind,
    url,
    {{ 'fetched_url' if has_fetched_url else 'url' }} AS fetched_url,
    sha256,
    title,
    page_count,
    fetched_at
FROM {{ name }}.plans.documents
{%- endfor %}
ORDER BY dataset, kind, url
