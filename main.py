"""府省のデータセットが持つ文書のページを 1 つにまとめ、全文検索の索引を作る。"""

import logging

from dbt.cli.main import dbtRunner

logging.basicConfig(level=logging.INFO, format="%(message)s", force=True)


def main():
    dbt = dbtRunner()
    for args in (["deps"], ["build"], ["docs", "generate"]):
        if not dbt.invoke(args).success:
            raise SystemExit(f"dbt {args[0]} failed")


if __name__ == "__main__":
    main()
