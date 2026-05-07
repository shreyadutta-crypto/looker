view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id,
        COUNT(DISTINCT order_id) AS lifetime_order_count,
        SUM(sale_price) AS lifetime_revenue,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS latest_order_date,
        DATEDIFF('day', MIN(created_at), MAX(created_at)) AS customer_lifespan_days
      FROM order_items
      GROUP BY 1
    ;;
    # Optional: Update this daily to keep performance high
      datagroup_trigger: ecommerce_default_datagroup
      indexes: ["user_id"]
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

    # --- MEASURES (For your Dashboard Tiles) ---

    ### Requirement 4 & 5: Average CLTV
    measure: average_cltv {
      description: "The average total revenue generated per customer"
      type: average
      sql: ${lifetime_revenue} ;;
      value_format_name: usd
    }

    ### Requirement 4: Purchase Frequency
    measure: average_purchase_frequency {
      description: "Average number of orders placed per customer"
      type: average
      sql: ${lifetime_order_count} ;;
      value_format: "0.##"
    }

    ### Requirement 5: Average Lifespan
    measure: average_customer_lifespan_days {
      description: "Average days between a customer's first and last order"
      type: average
      sql: ${customer_lifespan_days} ;;
      value_format: "0"
    }
  }
