select distinct purpose, replace(purpose, '_', ' ') as purpose_label
from {{ ref('stg_loans') }}
