{{ config(
    materialized='incremental',
    unique_key='date_id'
) }}

WITH date_spine AS (
    -- Generate dates from 2023-01-01 to 2025-12-31
    SELECT
        DATEADD(day, SEQ4(), '2023-01-01') AS date_jour
    FROM TABLE(GENERATOR(ROWCOUNT => 1096))
),

final AS (
    SELECT
        TO_CHAR(date_jour, 'YYYYMMDD')::INTEGER AS date_id,
        date_jour,
        YEAR(date_jour) AS annee,
        QUARTER(date_jour) AS trimestre,
        MONTH(date_jour) AS mois,
        MONTHNAME(date_jour) AS nom_mois,
        WEEK(date_jour) AS semaine,
        DAY(date_jour) AS jour,
        DAYNAME(date_jour) AS nom_jour,
        DAYOFWEEK(date_jour) AS jour_semaine,
        CASE WHEN DAYOFWEEK(date_jour) IN (0, 6) THEN TRUE ELSE FALSE END AS est_weekend
    FROM date_spine
)

SELECT * FROM final
{% if is_incremental() %}
WHERE date_jour > (SELECT MAX(date_jour) FROM {{ this }})
{% endif %}