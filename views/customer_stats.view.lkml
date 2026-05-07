view: customer_stats {
  derived_table: {
    # This makes it a PDT. Adjust the trigger logic to your needs.
    datagroup_trigger: ecommerce_default_datagroup
    publish_as_db_view: yes
    sql:
      SELECT
        user_id,
        SUM(sale_price) AS total_spend,
        COUNT(DISTINCT order_id) AS total_orders,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS last_order_date,
        SUM(sale_price) / NULLIF(COUNT(DISTINCT order_id), 0) AS average_order_value
      FROM order_items
      GROUP BY 1
      ;;
  }

  # --- Dimensions ---

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: total_spend {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_spend ;;
  }

  dimension: total_orders {
    type: number
    sql: ${TABLE}.total_orders ;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.first_order_date ;;
  }

  dimension_group: last_order {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}.last_order_date ;;
  }

  dimension: average_order_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.average_order_value ;;
  }

  dimension: rfm_segment {
    type: string
    description: "Categorizes users by their spending and recency"
    sql:
      CASE
        WHEN ${total_spend} > 500 THEN 'High Value'
        WHEN DATE_DIFF(CURRENT_DATE(), DATE(${last_order_date}), DAY) > 90 THEN 'At Risk'
        WHEN ${total_orders} > 5 THEN 'Loyal Customer'
        ELSE 'Standard'
      END ;;
  }
}
