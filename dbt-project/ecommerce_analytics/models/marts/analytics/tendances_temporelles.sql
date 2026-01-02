WITH fct AS (
    SELECT * FROM {{ ref('fct_commandes') }}
),

temps AS (
    SELECT * FROM {{ ref('dim_temps') }}
),

aggregated AS (
    SELECT
        t.annee,
        t.trimestre,
        t.mois,
        t.nom_mois,
        t.semaine,
        COUNT(DISTINCT f.commande_id) AS nombre_commandes,
        SUM(f.montant_total) AS chiffre_affaires,
        AVG(f.montant_total) AS panier_moyen,
        SUM(CASE WHEN f.statut_commande = 'Validée' THEN 1 ELSE 0 END) AS commandes_validees,
        SUM(CASE WHEN f.statut_commande = 'Annulée' THEN 1 ELSE 0 END) AS commandes_annulees,
        SUM(CASE WHEN f.statut_commande = 'En attente' THEN 1 ELSE 0 END) AS commandes_en_attente
    FROM fct f
    INNER JOIN temps t ON f.date_id = t.date_id
    GROUP BY 1, 2, 3, 4, 5
)

SELECT * FROM aggregated
ORDER BY annee DESC, mois DESC