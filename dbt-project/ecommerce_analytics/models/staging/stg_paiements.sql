WITH source AS (
    SELECT * FROM {{ source('raw_data', 'raw_paiements') }}
),

cleaned AS (
    SELECT
        commande_id,
        client_id,
        TO_TIMESTAMP(timestamp) AS timestamp_paiement,
        TRIM(statut_paiement) AS statut_paiement,
        CURRENT_TIMESTAMP() AS dbt_updated_at
    FROM source
)

SELECT * FROM cleaned