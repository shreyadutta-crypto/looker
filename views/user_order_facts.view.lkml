view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id,
        COUNT(DISTINCT order_id) AS lifetime_order_count,
        SUM(sale_price) AS lifetime_revenue,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS latest_order_date,
        -- Correct BigQuery Syntax: DATE_DIFF(end, start, unit)
        DATE_DIFF(CAST(MAX(created_at) AS DATE), CAST(MIN(created_at) AS DATE), DAY) AS customer_lifespan_days
      FROM order_items
      GROUP BY 1
    ;;
  }

  dimension: user_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.lifetime_order_count ;;
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
    value_format_name: usd
  }

  dimension: customer_lifespan_days {
    type: number
    sql: ${TABLE}.customer_lifespan_days ;;
  }

  # --- KPI MEASURES FOR TILES ---

  measure: average_cltv {
    label: "Average CLTV"
    type: average
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }

  measure: average_purchase_frequency {
    label: "Avg Purchase Frequency"
    type: average
    sql: ${lifetime_order_count} ;;
    value_format: "0.##"
  }

  measure: average_customer_lifespan_days {
    label: "Avg Customer Lifespan (Days)"
    type: average
    sql: ${customer_lifespan_days} ;;
    value_format: "0"
  }
}
