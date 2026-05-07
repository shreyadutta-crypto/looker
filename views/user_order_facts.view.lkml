view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id,
        COUNT(DISTINCT order_id) AS lifetime_order_count,
        SUM(sale_price) AS lifetime_revenue,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS latest_order_date,
        # Standard SQL DATEDIFF - adjust syntax if using BigQuery (DATE_DIFF)
        DATE_DIFF(day, MIN(created_at), MAX(created_at)) AS customer_lifespan_days
      FROM order_items
      GROUP BY 1
    ;;
  }

  # --- DIMENSIONS ---
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

  # --- MEASURES ---
  measure: average_cltv {
    type: average
    sql: ${lifetime_revenue} ;;
    value_format_name: usd
  }

  measure: average_purchase_frequency {
    type: average
    sql: ${lifetime_order_count} ;;
    value_format: "0.##"
  }

  measure: average_customer_lifespan_days {
    type: average
    sql: ${customer_lifespan_days} ;;
    value_format: "0"
  }
}
