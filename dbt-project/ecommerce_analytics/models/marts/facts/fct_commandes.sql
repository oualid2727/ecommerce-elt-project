WITH commandes AS (
    SELECT * FROM {{ ref('stg_commandes') }}
),

paiements AS (
    SELECT * FROM {{ ref('stg_paiements') }}
),

temps AS (
    SELECT * FROM {{ ref('dim_temps') }}
),

joined AS (
    SELECT
        c.commande_id,
        c.client_id,
        c.produit_id,
        t.date_id,
        c.date_commande,
        c.quantite,
        c.montant_total,
        c.statut AS statut_commande,
        p.statut_paiement,
        p.timestamp_paiement,
        CASE 
            WHEN c.statut = 'Validée' AND p.statut_paiement = 'Réussi' THEN TRUE 
            ELSE FALSE 
        END AS est_commande_completee,
        c.dbt_updated_at
    FROM commandes c
    LEFT JOIN paiements p ON c.commande_id = p.commande_id
    LEFT JOIN temps t ON c.date_commande = t.date_jour
)

SELECT * FROM joined