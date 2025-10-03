def amino_acids
  [
    :alanine,
    :arginine,
    :aspartic_acid,
    :cystine,
    :glutamic_acid,
    :glycine,
    :histidine,
    :isoleucine,
    :leucine,
    :lysine,
    :methionine,
    :phenylalanine,
    :proline,
    :serine,
    :threonine,
    :tryptophan,
    :tyrosine,
    :valine
  ]
end

def mix(profile_1, weight_1, profile_2, weight_2)
  resulting_profile = {}

  amino_acids.each do |amino_acid|
    amount_1 = profile_1[amino_acid] || 0
    amount_2 = profile_2[amino_acid] || 0

    resulting_profile[amino_acid] = amount_1 * weight_1 + amount_2 * weight_2
  end

  resulting_profile
end

def std_dev(profile_1, profile_2)
  resulting_profile = {}

  amino_acids.each do |amino_acid|
    amount_1 = profile_1[amino_acid] || 0
    amount_2 = profile_2[amino_acid] || 0

    resulting_profile[amino_acid] = Math.sqrt((amount_1 - amount_2) ** 2)
  end

  resulting_profile.values.sum
end

def find_ideal_ratio(mix_profile_1, mix_profile_2, match_profile)
  steps = 0.step(1, 0.01).map {|n| n.round(2)}.to_a

  results = []

  steps.each do |step|
    weight_1 = step
    weight_2 = (1 - step).round(2)

    mixed_profile = mix(mix_profile_1, weight_1, mix_profile_2, weight_2)

    std_dev = std_dev(mixed_profile, match_profile)

    results << {
      std_dev:,
      weight_1:,
      weight_2:,
      mixed_profile:
    }
  end

  results.sort_by {|result| result[:std_dev]}
end

rice = {
  alanine: 3.98,
  arginine: 7.06,
  aspartic_acid: 7.2,
  cystine: 1.49,
  glutamic_acid: 15.68,
  glycine: 3.52,
  histidine: 1.96,
  isoleucine: 4.53,
  leucine: 7.42,
  lysine: 3.12,
  methionine: 2.33,
  phenylalanine: 4.68,
  proline: 4.14,
  serine: 4.33,
  threonine: 3.15,
  tryptophan: 0.94,
  tyrosine: 4.79,
  valine: 4.69,
}

pea = {
  alanine: 3.09,
  arginine: 8.50,
  aspartic_acid: 8.58,
  cystine: 0.81,
  glutamic_acid: 14.60,
  glycine: 3.13,
  histidine: 2.35,
  isoleucine: 3.64,
  leucine: 7.22,
  lysine: 6.15,
  methionine: 0.96,
  phenylalanine: 4.24,
  proline: 3.60,
  serine: 4.53,
  threonine: 3.19,
  tryptophan: 0.60,
  tyrosine: 3.16,
  valine: 3.51,
}

whey = {
  alanine:	4.1,
  arginine:	2.1,
  aspartic_acid:	8.7,
  cystine:	1.9,
  glutamic_acid:	13.9,
  glycine:	1.5,
  histidine:	1.5,
  isoleucine:	4.9,
  leucine:	8.6,
  lysine:	7.2,
  methionine:	1.6,
  phenylalanine:	2.6,
  proline:	4.7,
  serine:	4.2,
  threonine:	5.7,
  tryptophan:	1.5,
  tyrosine:	2.8,
  valine:	4.6,
}

pp find_ideal_ratio(rice, pea, whey).map {|result| result.slice(:std_dev, :weight_1, :weight_2)}