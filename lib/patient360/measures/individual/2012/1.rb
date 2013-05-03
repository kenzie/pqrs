# Individual 2012 #1

title "Diabetes Mellitus: Hemoglobin A1c Poor Control in Diabetes Mellitus"
description "Percentage of patients aged 18 through 75 years with diabetes mellitus who had most recent hemoglobin A1c greater than 9.0%"

# denominator

denominator_question :icd9_code, :label => 'ICD-9 Code', :collection => %w[250.00 250.01 250.02 250.03 250.10 250.11 250.12 250.13 250.20 250.21 250.22 250.23 250.30 250.31 250.32 250.33 250.40 250.41 250.42 250.43 250.50 250.51 250.52 250.53 250.60 250.61 250.62 250.63 250.70 250.71 250.72 250.73 250.80 250.81 250.82 250.83 250.90 250.91 250.92 250.93 357.2 362.01 362.02 362.03 362.04 362.05 362.06 362.07 366.41 648.00 648.01 648.02 648.03 648.04]
denominator_question :cpt2_code, :label => 'CPT-II Code', :collection => %w[97802 97803 97804 99201 99202 99203 99204 99205 99212 99213 99214 99215 99304 99305 99306 99307 99308 99309 99310 99324 99325 99326 99327 99328 99334 99335 99336 99337 99341 99342 99343 99344 99345 99347 99348 99349 99350 G0270 G0271]

denominator_validation :age do |denominator|
  (18..75).cover? denominator[:patient_age]
end

denominator_validation :ffs do |denominator|
  denominator[:patient_is_fee_for_service] == true
end

# numerator

numerator_question :q1, :label => "Most recent Hemoglobin A1c level", :as => :numeric
numerator_question :q2, :label => "Hemoglobin A1c test not performed?", :as => :boolean, :wrapper => :checkbox

numerator_validation do |numerator|
  if numerator[:q1] && numerator[:q1] > 9.0
    ["1234F", :pass]
  elsif numerator[:q1] && numerator[:q1].between?(7.0, 9.0)
    ["1234F-2P", :exclude]
  elsif numerator[:q1] && numerator[:q1] < 7.0
    ["1234F-3P", :exclude]
  elsif numerator[:q2]
    ["1234F-8P", :fail]
  end
end