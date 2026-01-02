WITH source AS (
    SELECT * FROM {{ source('raw_data', 'commandes') }}
),

cleaned AS (
    SELECT
        commandeid AS commande_id,
        clientid AS client_id,
        produitid AS produit_id,
        quantite,
        montanttotal AS montant_total,
        TO_DATE(datecommande) AS date_commande,
        TRIM(statut) AS statut,
        CURRENT_TIMESTAMP() AS dbt_updated_at
    FROM source
)

SELECT * FROM cleaned