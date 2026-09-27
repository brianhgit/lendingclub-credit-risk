select distinct sub_grade, grade
from {{ ref('stg_loans') }}
