WITH clients AS (
    SELECT * FROM {{ ref('stg_clients') }}
),

final AS (
    SELECT
        client_id,
        nom_client,
        pays,
        date_inscription,
        DATEDIFF(day, date_inscription, CURRENT_DATE()) AS jours_depuis_inscription,
        CASE 
            WHEN pays IN ('France', 'Belgique', 'Suisse') THEN 'Europe Francophone'
            WHEN pays IN ('États-Unis', 'Canada') THEN 'Amérique du Nord'
            WHEN pays IN ('Espagne', 'Portugal') THEN 'Europe Ibérique'
            ELSE 'Autre'
        END AS region,
        dbt_updated_at
    FROM clients
)

SELECT * FROM final