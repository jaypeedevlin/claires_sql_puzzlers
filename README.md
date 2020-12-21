# Solutions for Claire's SQL Puzzlers

These are solutions to [Claire Carrol's Advanced SQL challenges](https://github.com/clrcrl/advanced-sql).  The solutions are written in BigQuery SQL.

For fun, these solutions have been compiled as a [dbt](https://www.getdbt.com) project.

## Completed Puzzles:

- Subscription Price Changes ([instructions](https://github.com/clrcrl/advanced-sql#subscription-price-changes)): Found in `/models/subscription_price_changes`

## Installation Instructions

_Requires Python 3.6 >= 3.8_

1. `virtualenv -p <path to Python> venv`
2. `source venv/bin/activate`
3. `pip install -r requirements.txt`

You'll need to setup a profile in your `~/.dbt/profiles.yml` ([docs](https://docs.getdbt.com/reference/profiles.yml)), and when that's done you can test your installation using `dbt debug`.