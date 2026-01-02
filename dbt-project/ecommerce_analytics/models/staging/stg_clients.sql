WITH source AS (
    SELECT * FROM {{ source('raw_data', 'clients') }}
),

cleaned AS (
    SELECT
        client_id AS client_id,      
        TRIM(nom_client) AS nom_client,
        TRIM(pays) AS pays,
        date_inscription AS date_inscription,
        CURRENT_TIMESTAMP() AS dbt_updated_at
    FROM source
)

SELECT * FROM cleaned
