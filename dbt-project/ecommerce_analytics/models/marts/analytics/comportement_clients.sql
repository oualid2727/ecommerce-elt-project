WITH fct AS (
    SELECT * FROM {{ ref('fct_commandes') }}
),

clients AS (
    SELECT * FROM {{ ref('dim_clients') }}
),

aggregated AS (
    SELECT
        c.client_id,
        c.nom_client,
        c.pays,
        c.region,
        c.date_inscription,
        COUNT(DISTINCT f.commande_id) AS nombre_commandes,
        SUM(f.montant_total) AS total_depense,
        AVG(f.montant_total) AS panier_moyen,
        MAX(f.date_commande) AS derniere_commande,
        MIN(f.date_commande) AS premiere_commande,
        DATEDIFF(day, MAX(f.date_commande), CURRENT_DATE()) AS jours_depuis_dernier_achat,
        CASE 
            WHEN COUNT(DISTINCT f.commande_id) >= 5 THEN 'VIP'
            WHEN COUNT(DISTINCT f.commande_id) >= 3 THEN 'Fidèle'
            WHEN COUNT(DISTINCT f.commande_id) >= 1 THEN 'Régulier'
            ELSE 'Nouveau'
        END AS segment_fidelite
    FROM fct f
    INNER JOIN clients c ON f.client_id = c.client_id
    GROUP BY 1, 2, 3, 4, 5
)

SELECT * FROM aggregated
ORDER BY total_depense DESC