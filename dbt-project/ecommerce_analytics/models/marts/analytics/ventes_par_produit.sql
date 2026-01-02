WITH fct AS (
    SELECT * FROM {{ ref('fct_commandes') }}
),

produits AS (
    SELECT * FROM {{ ref('dim_produits') }}
),

aggregated AS (
    SELECT
        p.produit_id,
        p.nom_produit,
        p.categorie,
        p.segment_prix,
        COUNT(DISTINCT f.commande_id) AS nombre_commandes,
        SUM(f.quantite) AS quantite_totale,
        SUM(f.montant_total) AS chiffre_affaires,
        AVG(f.montant_total) AS panier_moyen,
        SUM(CASE WHEN f.est_commande_completee THEN f.montant_total ELSE 0 END) AS ca_valide
    FROM fct f
    INNER JOIN produits p ON f.produit_id = p.produit_id
    GROUP BY 1, 2, 3, 4
)

SELECT * FROM aggregated
ORDER BY chiffre_affaires DESC