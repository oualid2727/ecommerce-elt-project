WITH produits AS (
    SELECT * FROM {{ ref('stg_produits') }}
),

final AS (
    SELECT
        produit_id,
        nom_produit,
        categorie,
        prix,
        CASE 
            WHEN prix < 20 THEN 'Bas'
            WHEN prix BETWEEN 20 AND 50 THEN 'Moyen'
            WHEN prix BETWEEN 50 AND 100 THEN 'Élevé'
            ELSE 'Premium'
        END AS segment_prix,
        dbt_updated_at
    FROM produits
)

SELECT * FROM final