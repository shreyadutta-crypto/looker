view: customer_stats {
  derived_table: {
    # REMOVE: datagroup_trigger or persist_for
    # This now runs as a subquery every time.
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

  dimension: user_id {
    primary_key: yes
    hidden: yes # Hide this because you'll join on it
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

  # Use the _raw version for calculations to avoid errors
  dimension_group: last_order {
    type: time
    timeframes: [raw, date, month, year]
    sql: ${TABLE}.last_order_date ;;
  }

  dimension: rfm_segment {
    type: string
    sql:
      CASE
        WHEN ${total_spend} > 500 THEN 'High Value'
        WHEN DATE_DIFF(CURRENT_DATE(), DATE(${last_order_raw}), DAY) > 90 THEN 'At Risk'
        WHEN ${total_orders} > 5 THEN 'Loyal Customer'
        ELSE 'Standard'
      END ;;
  }
}
