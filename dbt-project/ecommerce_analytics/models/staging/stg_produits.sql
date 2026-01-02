WITH source AS (
    SELECT * FROM {{ source('raw_data', 'produits') }}
),

cleaned AS (
    SELECT
        produitid AS produit_id,
        TRIM(nomproduit) AS nom_produit,
        TRIM(categorie) AS categorie,
        prix,
        CURRENT_TIMESTAMP() AS dbt_updated_at
    FROM source
)

SELECT * FROM cleaned